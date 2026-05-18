import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart';
import '../services/firestore_service.dart';
import '../main.dart';

class RideProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final List<CarpoolPool> _allPools = [];

  List<CarpoolPool> get allPools => [..._allPools];

  void startRealtimeSync() {
    _firestore.getPoolsStream().listen((updatedPools) {
      // 1. Create a list for the UI
      List<CarpoolPool> validPools = [];

      for (var pool in updatedPools) {
        if (pool.isExpired) {
          // 2. AUTO-DELETE: Tell Firestore to remove this old data
          _firestore.deletePool(pool.id);
          debugPrint("CLEANUP: Deleted expired pool ${pool.id}");
        } else {
          // 3. KEEP: It's still a valid upcoming ride
          validPools.add(pool);
        }
      }

      _allPools.clear();
      _allPools.addAll(validPools);
      
      _saveToHive(); 
      notifyListeners();
    });
  }

  CarpoolPool? getActivePoolForUser(String email) {
    try {
      return _allPools.firstWhere((p) => p.studentEmails.contains(email) && p.status != PoolStatus.booked);
    } catch (e) {
      return null;
    }
  }

  Future<void> _notify(String title, String body) async {
    const android = AndroidNotificationDetails('gocampus', 'Alerts', importance: Importance.max, priority: Priority.high);
    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecond % 100000, 
      title: title, 
      body: body, 
      notificationDetails: const NotificationDetails(android: android),
    );
  }

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

  void joinOrCreatePool({
    required String email,
    required Locality origin,
    required Locality destination,
    required DateTime time,
    required Region region,
  }) {
    try {
      final existingPool = _allPools.firstWhere((p) {
        // Now returns a simple bool
        return MatchingEngine.checkCompatibility(
          userOrigin: origin,
          poolOrigin: p.originLocality,
          userDestination: destination,
          poolDestination: p.destination,
          userDepartureTime: time,
          poolDepartureTime: p.lectureTime,
        ) && !p.isFull && p.status == PoolStatus.recruiting;
      });

      if (!existingPool.studentEmails.contains(email)) {
        existingPool.studentEmails.add(email);
        _notify("Passenger Joined!", "Someone joined your carpool to ${destination.name}");
        
        // FIX: Using the helper method to resolve the warning
        if (existingPool.isFull) {
          _updateStatus(existingPool.id, PoolStatus.collectingAddresses);
        }
        _firestore.syncPool(existingPool);
      }
    } catch (e) {
      final newPool = CarpoolPool(
        id: DateTime.now().toString(),
        originLocality: origin,
        destination: destination,
        lectureTime: time,
        studentEmails: [email],
        leadStudentEmail: email,
        region: region,
        status: PoolStatus.recruiting,
      );
      _allPools.add(newPool);
      _firestore.syncPool(newPool);
    }
    _saveToHive();
    notifyListeners();
  }

  void manualJoin(String poolId, String email) {
    final index = _allPools.indexWhere((p) => p.id == poolId);
    if (index != -1 && !_allPools[index].isFull) {
      if (!_allPools[index].studentEmails.contains(email)) {
        _allPools[index].studentEmails.add(email);
        if (_allPools[index].studentEmails.length == 4) {
          _updateStatus(poolId, PoolStatus.collectingAddresses);
        }
        _firestore.syncPool(_allPools[index]);
        _saveToHive();
        _notify("New Joiner", "Someone joined your carpool manually.");
        notifyListeners();
      }
    }
  }

  void leavePool(String poolId, String email) {
    final i = _allPools.indexWhere((p) => p.id == poolId);
    if (i == -1) return;
    
    final pool = _allPools[i];
    
    // Principle #26: Create a new list (Immutability)
    final updatedEmails = List<String>.from(pool.studentEmails)..remove(email);

    if (updatedEmails.isEmpty) {
      // DELETE CASE: Remove from local list AND cloud
      _allPools.removeAt(i);
      _firestore.deletePool(poolId);
    } else {
      // UPDATE CASE: Shift lead and reset status
      String lead = pool.leadStudentEmail == email ? updatedEmails.first : pool.leadStudentEmail;
      _allPools[i] = pool.copyWith(
        studentEmails: updatedEmails, 
        leadStudentEmail: lead, 
        status: PoolStatus.recruiting
      );
      _firestore.syncPool(_allPools[i]);
    }
    
    _saveToHive();
    notifyListeners(); // Triggers the AuthGate/Consumer to react
  }

  void voteToStartEarly(String poolId, String email) {
    final i = _allPools.indexWhere((p) => p.id == poolId);
    if (i == -1) return;
    final p = _allPools[i];
    final votes = List<String>.from(p.readyToStartEmails);
    if (!votes.contains(email)) votes.add(email);
    bool start = votes.length == p.studentEmails.length && p.studentEmails.length > 1;
    _allPools[i] = p.copyWith(readyToStartEmails: votes, status: start ? PoolStatus.collectingAddresses : p.status);
    _firestore.syncPool(_allPools[i]);
    _saveToHive();
    notifyListeners();
  }

  void submitAddress(String poolId, String email, String addr) {
    final i = _allPools.indexWhere((p) => p.id == poolId);
    if (i == -1) return;
    final adds = Map<String, String>.from(_allPools[i].studentAddresses)..[email] = addr;
    _allPools[i] = _allPools[i].copyWith(studentAddresses: adds);
    if (_allPools[i].allAddressesCollected) _allPools[i] = _allPools[i].copyWith(status: PoolStatus.awaitingPayment);
    _firestore.syncPool(_allPools[i]);
    _saveToHive();
    notifyListeners();
  }

  void processPayment(String poolId, String email) {
    final i = _allPools.indexWhere((p) => p.id == poolId);
    if (i == -1) return;
    final paid = List<String>.from(_allPools[i].paidStudentEmails)..add(email);
    _allPools[i] = _allPools[i].copyWith(paidStudentEmails: paid);
    if (_allPools[i].isFullyFunded) {
      _allPools[i] = _allPools[i].copyWith(status: PoolStatus.booked, driverName: "Joseph (Bolt)", licensePlate: "ABC-123");
      _notify("Ride Booked!", "The car is on its way.");
    }
    _firestore.syncPool(_allPools[i]);
    _saveToHive();
    notifyListeners();
  }

  void _updateStatus(String id, PoolStatus s) {
    final i = _allPools.indexWhere((p) => p.id == id);
    if (i != -1) {
      _allPools[i] = _allPools[i].copyWith(status: s);
    }
  }
}