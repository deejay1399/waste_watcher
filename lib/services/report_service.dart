import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      final user = _auth.currentUser!;
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
      await _db.collection('users').doc(user.uid).update({
        'totalReports': FieldValue.increment(1),
        'totalPoints': FieldValue.increment(10),
      });

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  // Get all reports (for map)
  Stream<List<ReportModel>> getAllReports() {
    return _db
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ReportModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }

  // Get current user's reports
  Stream<List<ReportModel>> getMyReports() {
    final uid = _auth.currentUser!.uid;
    return _db
        .collection('reports')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ReportModel.fromMap(d.data(), d.id))
              .toList(),
        );
  }
}
