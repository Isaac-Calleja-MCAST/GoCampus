import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart';
import '../main.dart'; // To access the global notification plugin

class RideProvider with ChangeNotifier {
  final List<CarpoolPool> _allPools = [];

  List<CarpoolPool> get allPools => [..._allPools];

  // --- SESSION HELPERS ---

  CarpoolPool? getActivePoolForUser(String email) {
    try {
      return _allPools.firstWhere(
        (pool) => pool.studentEmails.contains(email) && pool.status != PoolStatus.booked,
      );
    } catch (e) {
      return null;
    }
  }

  // --- HARDWARE NOTIFICATIONS (Priority #9) ---

  Future<void> _triggerNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'gocampus_alerts', 
      'Ride Notifications',
      channelDescription: 'Alerts for pool matches and status changes',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond % 100000, // Unique ID
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  // --- PERSISTENCE (Hive) ---

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

  Future<void> _saveToHive() async {
    var box = await Hive.openBox('poolsBox');
    await box.clear();
    for (var pool in _allPools) {
      await box.add(pool.toMap());
    }
  }

  // --- POOL OPERATIONS ---

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
        return result.compatible && !p.isFull && p.status == PoolStatus.recruiting;
      });

      if (!existingPool.studentEmails.contains(email)) {
        existingPool.studentEmails.add(email);
        
        _triggerNotification("Passenger Joined!", "A new student joined your pool to ${destination.name}");

        if (existingPool.studentEmails.length == 4) {
          _updatePoolStatus(existingPool.id, PoolStatus.collectingAddresses);
          _triggerNotification("Car Full!", "Match complete. Please enter your pickup address.");
        }
      }
    } catch (e) {
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

  void manualJoin(String poolId, String email) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index != -1 && !_allPools[index].isFull) {
      if (!_allPools[index].studentEmails.contains(email)) {
        _allPools[index].studentEmails.add(email);
        
        _triggerNotification("New Joiner", "Someone joined your carpool manually.");

        if (_allPools[index].studentEmails.length == 4) {
          _updatePoolStatus(poolId, PoolStatus.collectingAddresses);
        }
        _saveToHive();
        notifyListeners();
      }
    }
  }

  void leavePool(String poolId, String email) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index == -1) return;

    final pool = _allPools[index];
    final updatedEmails = List<String>.from(pool.studentEmails)..remove(email);

    if (updatedEmails.isEmpty) {
      _allPools.removeAt(index);
    } else {
      String newLead = pool.leadStudentEmail;
      if (email == pool.leadStudentEmail) {
        newLead = updatedEmails.first;
      }

      final updatedAddresses = Map<String, String>.from(pool.studentAddresses)..remove(email);
      final updatedVotes = List<String>.from(pool.readyToStartEmails)..remove(email);

      _allPools[index] = CarpoolPool(
        id: pool.id,
        originLocality: pool.originLocality,
        destination: pool.destination,
        lectureTime: pool.lectureTime,
        studentEmails: updatedEmails,
        studentAddresses: updatedAddresses,
        readyToStartEmails: updatedVotes,
        leadStudentEmail: newLead,
        region: pool.region,
        status: PoolStatus.recruiting, 
      );
      
      _triggerNotification("Passenger Left", "Someone left the pool. Recruiting for a replacement.");
    }
    
    _saveToHive();
    notifyListeners();
  }

  void voteToStartEarly(String poolId, String email) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index == -1) return;
    
    final pool = _allPools[index];
    final updatedVotes = List<String>.from(pool.readyToStartEmails);
    if (!updatedVotes.contains(email)) {
      updatedVotes.add(email);
    }

    bool allAgreed = updatedVotes.length == pool.studentEmails.length && pool.studentEmails.length > 1;

    _allPools[index] = CarpoolPool(
      id: pool.id,
      originLocality: pool.originLocality,
      destination: pool.destination,
      lectureTime: pool.lectureTime,
      studentEmails: pool.studentEmails,
      studentAddresses: pool.studentAddresses,
      readyToStartEmails: updatedVotes,
      leadStudentEmail: pool.leadStudentEmail,
      region: pool.region,
      status: allAgreed ? PoolStatus.collectingAddresses : pool.status,
      fetchedPrice: pool.fetchedPrice,
    );

    if (allAgreed) {
      _triggerNotification("Start Early Agreed!", "Everyone is ready. Enter your house addresses.");
    } else {
      _triggerNotification("Vouch Received", "Someone wants to start the ride early.");
    }

    _saveToHive();
    notifyListeners();
  }

  void submitAddress(String poolId, String email, String address) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index == -1) return;

    final updatedAddresses = Map<String, String>.from(_allPools[index].studentAddresses);
    updatedAddresses[email] = address;

    _allPools[index] = CarpoolPool(
      id: _allPools[index].id,
      originLocality: _allPools[index].originLocality,
      destination: _allPools[index].destination,
      lectureTime: _allPools[index].lectureTime,
      studentEmails: _allPools[index].studentEmails,
      studentAddresses: updatedAddresses,
      readyToStartEmails: _allPools[index].readyToStartEmails,
      leadStudentEmail: _allPools[index].leadStudentEmail,
      region: _allPools[index].region,
      status: updatedAddresses.length == _allPools[index].studentEmails.length 
          ? PoolStatus.awaitingPayment 
          : PoolStatus.collectingAddresses,
      fetchedPrice: _allPools[index].fetchedPrice,
    );

    if (_allPools[index].status == PoolStatus.awaitingPayment) {
      _triggerNotification("Ready for Payment", "All addresses collected! Lead student is fetching the quote.");
    }
    
    _saveToHive();
    notifyListeners();
  }

  Future<void> fetchFinalBoltPrice(String poolId) async {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index == -1) return;

    await Future.delayed(const Duration(seconds: 2));

    double basePrice = 10.00;
    double pricePerStop = 1.50;
    double finalPrice = basePrice + (_allPools[index].studentAddresses.length * pricePerStop);

    final p = _allPools[index];
    _allPools[index] = CarpoolPool(
      id: p.id,
      originLocality: p.originLocality,
      destination: p.destination,
      lectureTime: p.lectureTime,
      studentEmails: p.studentEmails,
      studentAddresses: p.studentAddresses,
      readyToStartEmails: p.readyToStartEmails,
      leadStudentEmail: p.leadStudentEmail,
      region: p.region,
      status: PoolStatus.awaitingPayment,
      fetchedPrice: finalPrice,
    );

    _triggerNotification("Quote Received", "The Bolt price has been verified. You can now pay your share.");

    _saveToHive();
    notifyListeners();
  }

  // --- PRIVATE HELPERS ---
  
  void _updatePoolStatus(String id, PoolStatus newStatus) {
    final i = _allPools.indexWhere((p) => p.id == id);
    if (i != -1) {
      final p = _allPools[i];
      _allPools[i] = CarpoolPool(
        id: p.id, originLocality: p.originLocality, destination: p.destination,
        lectureTime: p.lectureTime, studentEmails: p.studentEmails,
        studentAddresses: p.studentAddresses, readyToStartEmails: p.readyToStartEmails,
        leadStudentEmail: p.leadStudentEmail, region: p.region,
        status: newStatus, fetchedPrice: p.fetchedPrice,
      );
    }
  }
}