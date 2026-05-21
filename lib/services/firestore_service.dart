// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/carpool_pool.dart';
import '../models/student_profile.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Get a "Live Stream" of pools
  // This is the magic! It tells Flutter to "Watch" the database for changes.
  Stream<List<CarpoolPool>> getPoolsStream() {
    return _db.collection('pools').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Convert the Firestore Map back into our CarpoolPool model
        return CarpoolPool.fromMap(doc.data());
      }).toList();
    });
  }

  // 2. Save or Update a pool in the cloud
  Future<void> syncPool(CarpoolPool pool) async {
    await _db.collection('pools').doc(pool.id).set(pool.toMap());
  }

  // 3. Delete a pool (when it becomes empty)
  Future<void> deletePool(String poolId) async {
    await _db.collection('pools').doc(poolId).delete();
  }

  Stream<List<StudentProfile>> getProfilesStream() {
    return _db.collection('studentProfiles').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => StudentProfile.fromMap(doc.data())).toList();
    });
  }

  Future<void> syncProfile(StudentProfile profile) async {
    await _db.collection('studentProfiles').doc(profile.email).set(profile.toMap());
  }
}
