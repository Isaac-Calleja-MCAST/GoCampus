import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart';

class UserProvider with ChangeNotifier {
  String? _userEmail;
  bool _isLoggedIn = false;
  Region _selectedRegion = Region.malta;
  
  // NEW: User Preferences for Seamless UX
  Locality? _homeTown;
  String? _targetCollege;

  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  Region get selectedRegion => _selectedRegion;
  
  // Getters for auto-fill logic
  Locality? get homeTown => _homeTown;
  String? get targetCollege => _targetCollege;

  Future<void> loadSession() async {
    var box = await Hive.openBox('userBox');
    _userEmail = box.get('email');
    _isLoggedIn = _userEmail != null;
    
    final savedRegion = box.get('region');
    if (savedRegion != null) {
      _selectedRegion = savedRegion == 'gozo' ? Region.gozo : Region.malta;
    }

    // Load preferences
    final int? townIndex = box.get('homeTownIndex');
    if (townIndex != null) {
      _homeTown = Locality.values[townIndex];
    }
    _targetCollege = box.get('targetCollege');

    notifyListeners();
  }

  // Updated login to include these preferences
  Future<void> login(String email, {Locality? town, String? college}) async {
    _userEmail = email;
    _homeTown = town;
    _targetCollege = college;
    _isLoggedIn = true;

    var box = await Hive.openBox('userBox');
    await box.put('email', email);
    if (town != null) await box.put('homeTownIndex', town.index);
    if (college != null) await box.put('targetCollege', college);
    
    notifyListeners();
  }

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
    // FIX: Only clear the email, keep 'homeTownIndex' and 'targetCollege'
    await box.delete('email'); 
  }
}