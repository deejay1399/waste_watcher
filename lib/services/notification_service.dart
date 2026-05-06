import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();

  static const _channelId = 'waste_watcher_channel';
  static const _channelName = 'Waste Watcher Alerts';

  static Future<void> init() async {
    try {
      // 1. Setup local notifications
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _local
          .initialize(const InitializationSettings(android: android, iOS: ios))
          .timeout(const Duration(seconds: 5));

      // 2. Create Android notification channel
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Waste report status updates',
        importance: Importance.high,
      );

      // 3. Register the channel
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = _local
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(channel);

      // 4. Request notification permission on Android 13+
      await androidPlugin?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Notification init error: $e');
    }
  }

  // Listen to Firestore for status changes
  static void listenToReportChanges() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('reports')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data()!;
              final status = data['status'] as String?;
              final notifiedKey = 'notified_$status';
              final alreadyNotified = data[notifiedKey] as bool? ?? false;

              if (!alreadyNotified && status != null && status != 'pending') {
                final reportId = change.doc.id;
                String title = 'Waste Watcher Update';
                String message = 'Your report status has been updated.';

                switch (status) {
                  case 'in_progress':
                    title = '🚛 Cleanup In Progress!';
                    message =
                        'A cleanup team has been assigned to your report.';
                    break;
                  case 'resolved':
                    title = '✅ Report Resolved! +20 pts';
                    message =
                        'Your waste report has been cleaned. You earned 20 points!';
                    break;
                }

                // Store notification and show local notification
                storeNotification(
                  reportId: reportId,
                  title: title,
                  message: message,
                  type: status,
                );
                _showStatusNotification(status);

                // Mark as notified
                change.doc.reference.update({notifiedKey: true});

                // Award points if resolved
                if (status == 'resolved') {
                  _awardPoints(data, change.doc.id);
                }
              }
            }
          }
        });
  }

  static Future<void> _showStatusNotification(String? status) async {
    try {
      String title = 'Waste Watcher Update';
      String body = 'Your report status has been updated.';

      switch (status) {
        case 'in_progress':
          title = '🚛 Cleanup In Progress!';
          body = 'A cleanup team has been assigned to your report.';
          break;
        case 'resolved':
          title = '✅ Report Resolved! +20 pts';
          body = 'Your waste report has been cleaned. You earned 20 points!';
          break;
      }

      // Show local notification
      await _local.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Show notification error: $e');
    }
  }

  // Store notification in Firestore
  static Future<void> storeNotification({
    required String reportId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .add({
            'userId': user.uid,
            'reportId': reportId,
            'title': title,
            'message': message,
            'type': type,
            'read': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      debugPrint('Store notification error: $e');
    }
  }

  // Get unread notification count
  static Stream<int> getUnreadCount() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(0);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Get all notifications for current user
  static Stream<List<AppNotification>> getNotifications() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint('Mark as read error: $e');
    }
  }

  // Mark all notifications as read
  static Future<void> markAllAsRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final unread = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      for (var doc in unread.docs) {
        await doc.reference.update({'read': true});
      }
    } catch (e) {
      debugPrint('Mark all as read error: $e');
    }
  }

  // Delete notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      debugPrint('Delete notification error: $e');
    }
  }

  static Future<void> _awardPoints(
    Map<String, dynamic> data,
    String docId,
  ) async {
    try {
      final pointsAwarded = data['pointsAwarded'] ?? 0;
      if (pointsAwarded > 0) return;

      final uid = data['userId'] as String?;
      if (uid == null) return;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'totalPoints': FieldValue.increment(20),
        'totalResolved': FieldValue.increment(1),
      });

      await FirebaseFirestore.instance.collection('reports').doc(docId).update({
        'pointsAwarded': 20,
      });
    } catch (e) {
      debugPrint('Award points error: $e');
    }
  }
}
