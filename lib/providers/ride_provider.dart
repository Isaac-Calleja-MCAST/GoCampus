import 'package:flutter/material.dart';
// import 'package:hive_flutter/hive_flutter.dart';
import '../models/carpool_pool.dart'; // Import the correct model

class RideProvider with ChangeNotifier {
  // Use the new model name here
  final List<CarpoolPool> _activePools = [
    CarpoolPool(
      id: 'p1',
      originLocality: 'Birkirkara',
      destination: 'MCAST Paola',
      lectureTime: DateTime.now().add(const Duration(hours: 1)),
      studentEmails: ['student1@mcast.edu.mt', 'student2@mcast.edu.mt'],
    ),
  ];

  List<CarpoolPool> get activePools => [..._activePools];

  // This fixes the 'loadRides' error in home_screen.dart
  Future<void> loadRides() async {
    // Hive logic will go here later
    notifyListeners();
  }

  void joinOrCreatePool(String email, String locality, String dest, DateTime time) {
    try {
      // 1. Check if a pool ALREADY exists for this exact town, campus, and time
      final existingPool = _activePools.firstWhere(
        (p) => p.originLocality == locality && 
               p.destination == dest && 
               p.lectureTime.hour == time.hour && // Match by hour
               p.lectureTime.minute == time.minute &&
               !p.isFull
      );
      
      // 2. If found, add student to the list
      if (!existingPool.studentEmails.contains(email)) {
        existingPool.studentEmails.add(email);
      }
      
    } catch (e) {
      // 3. If no matching pool exists, CREATE a new one
      _activePools.add(CarpoolPool(
        id: DateTime.now().toString(),
        originLocality: locality,
        destination: dest,
        lectureTime: time,
        studentEmails: [email],
      ));
    }
    notifyListeners();
  }
}