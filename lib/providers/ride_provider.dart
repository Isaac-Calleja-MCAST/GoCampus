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
    // Logic as discussed before
    notifyListeners();
  }
}