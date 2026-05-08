import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ride.dart';

class RideProvider with ChangeNotifier {
  List<Ride> _rides = [];
  List<Ride> get rides => [..._rides];

  // This will be our "Home Screen" list
  Future<void> loadRides() async {
    var box = await Hive.openBox('ridesBox');
    // Logic to pull from Hive will go here
    notifyListeners();
  }

  void addRide(Ride ride) async {
    _rides.add(ride);
    var box = await Hive.openBox('ridesBox');
    // Save to Hive logic
    await box.add({
      'driver': ride.driverName,
      'to': ride.toLocation,
      'time': ride.departureTime.toIso8601String(),
      'seats': ride.availableSeats,
    });
    notifyListeners();
  }
}