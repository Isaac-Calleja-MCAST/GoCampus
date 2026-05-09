import 'package:flutter/material.dart';
import '../models/carpool_pool.dart';

class RideProvider with ChangeNotifier {
  final List<CarpoolPool> _allPools = [];

  List<CarpoolPool> get allPools => [..._allPools];

  // Logic to find a match or create a new pool
  void joinOrCreatePool({
    required String email,
    required String origin,
    required String dest,
    required DateTime time,
    required Region region,
  }) {
    try {
      // 1. Try to find an existing pool that matches
      final existingPool = _allPools.firstWhere((p) =>
          p.originLocality == origin &&
          p.destination == dest &&
          p.region == region &&
          p.status == PoolStatus.recruiting && // Only join if still recruiting
          p.lectureTime.difference(time).inMinutes.abs() <= 15 && // 15 min window
          !p.isFull);

      // 2. If found, add the student
      if (!existingPool.studentEmails.contains(email)) {
        existingPool.studentEmails.add(email);
      }
      
    } catch (e) {
      // 3. If NO match found, CREATE a new pool
      // The person who creates it is automatically the Lead Student
      _allPools.add(CarpoolPool(
        id: DateTime.now().toString(),
        originLocality: origin,
        destination: dest,
        lectureTime: time,
        studentEmails: [email],
        leadStudentEmail: email, // Set the creator as the Leader
        region: region,
        status: PoolStatus.recruiting,
      ));
    }
    notifyListeners();
  }

  // FUNCTION: Student submits their specific house address
  void submitAddress(String poolId, String email, String address) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index != -1) {
      final p = _allPools[index];
      
      // We create a new Map and add the new address
      final updatedAddresses = Map<String, String>.from(p.studentAddresses);
      updatedAddresses[email] = address;

      // Update the pool in the list
      _allPools[index] = CarpoolPool(
        id: p.id,
        originLocality: p.originLocality,
        destination: p.destination,
        lectureTime: p.lectureTime,
        studentEmails: p.studentEmails,
        studentAddresses: updatedAddresses,
        leadStudentEmail: p.leadStudentEmail,
        region: p.region,
        status: updatedAddresses.length == p.studentEmails.length 
            ? PoolStatus.awaitingPayment 
            : PoolStatus.collectingAddresses,
        fetchedPrice: p.fetchedPrice,
      );
      notifyListeners();
    }
  }

  Future<void> loadRides() async {
    notifyListeners();
  }
}