import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';

class ReportService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Submit a new report
  Future<String?> submitReport({
    required String photoUrl,
    required String wasteType,
    required String description,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('submitReport failed: no signed-in user');
        return null;
      }

      final docRef = await _db.collection('reports').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'Anonymous',
        'photoUrl': photoUrl,
        'wasteType': wasteType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'status': 'pending',
        'pointsAwarded': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Award 10 points for submitting
      await _db.collection('users').doc(user.uid).set({
        'totalReports': FieldValue.increment(1),
        'totalPoints': FieldValue.increment(10),
      }, SetOptions(merge: true));

      return docRef.id;
    } catch (e) {
      debugPrint('submitReport failed: $e');
      return null;
    }
  }

  // Get all reports (for map)
  Stream<List<ReportModel>> getAllReports() {
    return _db
        .collection('reports')
        .snapshots()
        .map((snap) => _sortNewestFirst(snap.docs));
  }

  // Get current user's reports
  Stream<List<ReportModel>> getMyReports() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('reports')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) => _sortNewestFirst(snap.docs));
  }

  List<ReportModel> _sortNewestFirst(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final reports =
        docs.map((d) => ReportModel.fromMap(d.data(), d.id)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return reports;
  }
}
