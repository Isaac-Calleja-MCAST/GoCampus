import 'package:flutter/material.dart';
import '../models/carpool_pool.dart';

class RideProvider with ChangeNotifier {
  final List<CarpoolPool> _allPools = [
    // Mock Malta Pool
    CarpoolPool(
      id: 'p1',
      originLocality: 'Birkirkara',
      destination: 'MCAST Paola',
      lectureTime: DateTime.now().add(const Duration(hours: 1)),
      studentEmails: ['student1@mcast.edu.mt', 'student2@mcast.edu.mt'],
      region: Region.malta,
    ),
    // Mock Gozo Pool
    CarpoolPool(
      id: 'p2',
      originLocality: 'Nadur',
      destination: 'MCAST Gozo',
      lectureTime: DateTime.now().add(const Duration(hours: 2)),
      studentEmails: ['student3@mcast.edu.mt'],
      region: Region.gozo,
    ),
  ];

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