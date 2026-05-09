import 'package:flutter/material.dart';
import '../models/carpool_pool.dart';

class RideProvider with ChangeNotifier {
  final List<CarpoolPool> _allPools = [];

  // Retrieve all pools; we will filter them in the UI based on the User Session
  List<CarpoolPool> get allPools => [..._allPools];

  Future<void> loadRides() async {
    notifyListeners();
  }

  void joinOrCreatePool({
    required String email,
    required String origin,
    required String dest,
    required DateTime time,
    required Region region,
  }) {
    try {
      final existingPool = _allPools.firstWhere((p) =>
          p.originLocality == origin &&
          p.destination == dest &&
          p.region == region &&
          p.lectureTime.difference(time).inMinutes.abs() <= 10 &&
          !p.isFull);

      if (!existingPool.studentEmails.contains(email)) {
        existingPool.studentEmails.add(email);
      }
    } catch (e) {
      _allPools.add(CarpoolPool(
        id: DateTime.now().toString(),
        originLocality: origin,
        destination: dest,
        lectureTime: time,
        studentEmails: [email],
        region: region,
      ));
    }
    notifyListeners();
  }
}