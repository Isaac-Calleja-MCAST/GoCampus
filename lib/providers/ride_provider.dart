import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart';

class RideProvider with ChangeNotifier {
  final List<CarpoolPool> _allPools = [];

  List<CarpoolPool> get allPools => [..._allPools];

  // Load all pools from the phone's memory
  Future<void> loadPools() async {
    var box = await Hive.openBox('poolsBox');
    if (box.isNotEmpty) {
      _allPools.clear();
      for (var item in box.values) {
        _allPools.add(CarpoolPool.fromMap(item));
      }
    }
    notifyListeners();
  }

  // Helper function to save the current list to Hive
  Future<void> _saveToHive() async {
    var box = await Hive.openBox('poolsBox');
    await box.clear(); // Clear the old list
    for (var pool in _allPools) {
      await box.add(pool.toMap()); // Save each pool as a map
    }
  }

  void joinOrCreatePool({
    required String email,
    required Locality origin,
    required Locality destination,
    required DateTime time,
    required Region region,
  }) {
    try {
      final existingPool = _allPools.firstWhere((p) {
        final result = MatchingEngine.checkCompatibility(
          userOrigin: origin,
          poolOrigin: p.originLocality,
          userDestination: destination,
          poolDestination: p.destination,
          userDepartureTime: time,
          poolDepartureTime: p.lectureTime,
        );
        return result.compatible && !p.isFull;
      });

      if (!existingPool.studentEmails.contains(email)) {
        existingPool.studentEmails.add(email);
      }
      
    } catch (e) {
      // 3. FIX FOR Missing Arguments error
      _allPools.add(CarpoolPool(
        id: DateTime.now().toString(),
        originLocality: origin,
        destination: destination,
        lectureTime: time,
        studentEmails: [email],
        leadStudentEmail: email,
        region: region,
        status: PoolStatus.recruiting,
      ));
    }
    _saveToHive();
    notifyListeners();
  }

  void submitAddress(String poolId, String email, String address) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index != -1) {
      final p = _allPools[index];
      final updatedAddresses = Map<String, String>.from(p.studentAddresses);
      updatedAddresses[email] = address;

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
}