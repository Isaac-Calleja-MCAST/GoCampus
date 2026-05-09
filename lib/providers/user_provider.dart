import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/carpool_pool.dart'; // To access the Region enum

class UserProvider with ChangeNotifier {
  String? _userEmail;
  bool _isLoggedIn = false;
  Region _selectedRegion = Region.malta; // Default is Malta

  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  Region get selectedRegion => _selectedRegion;

  // Load session and saved region preference
  Future<void> loadSession() async {
    var box = await Hive.openBox('userBox');
    _userEmail = box.get('email');
    _isLoggedIn = _userEmail != null;
    
    // Retrieve saved region from memory
    final savedRegion = box.get('region');
    if (savedRegion != null) {
      _selectedRegion = savedRegion == 'gozo' ? Region.gozo : Region.malta;
    }
    notifyListeners();
  }

  Future<void> login(String email) async {
    _userEmail = email;
    _isLoggedIn = true;
    var box = await Hive.openBox('userBox');
    await box.put('email', email);
    notifyListeners();
  }

  // Set and persist the region choice (Malta vs Gozo)
  Future<void> setRegion(Region region) async {
    _selectedRegion = region;
    var box = await Hive.openBox('userBox');
    await box.put('region', region == Region.gozo ? 'gozo' : 'malta');
    notifyListeners();
  }

  Future<void> logout() async {
    _userEmail = null;
    _isLoggedIn = false;
    notifyListeners(); 
    var box = await Hive.openBox('userBox');
    await box.clear();
  }
}