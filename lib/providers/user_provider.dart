import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/carpool_pool.dart';
import '../models/monthly_membership.dart';
import '../models/student_profile.dart';
import '../models/timetable_entry.dart';
import '../data/route_logic.dart';
import '../services/firestore_service.dart';

class UserProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  String? _userEmail;
  bool _isLoggedIn = false;
  Region _selectedRegion = Region.malta;
  
  // NEW: User Preferences for Seamless UX
  Locality? _homeTown;
  String? _targetCollege;
  String? _firstName;
  String? _lastName;
  List<TimetableEntry> _timetable = const [];
  DateTime? _membershipMonth;
  String? _membershipOwnerEmail;

  String? get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  Region get selectedRegion => _selectedRegion;
  
  // Getters for auto-fill logic
  Locality? get homeTown => _homeTown;
  String? get targetCollege => _targetCollege;
  String get displayName {
    final name = '${_firstName ?? ''} ${_lastName ?? ''}'.trim();
    return name.isEmpty ? (_userEmail ?? 'Student') : name;
  }
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  List<TimetableEntry> get timetable => List.unmodifiable(_timetable);
  DateTime? get membershipMonth => _membershipMonth;

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
    _firstName = box.get('firstName');
    _lastName = box.get('lastName');
    final rawTimetable = box.get('timetableEntries');
    if (rawTimetable is List) {
      _timetable = rawTimetable
          .map((entry) => TimetableEntry.fromMap(Map<String, dynamic>.from(entry)))
          .toList(growable: false);
    }
    final savedMembershipMonth = box.get('membershipMonth');
    if (savedMembershipMonth is String) {
      _membershipMonth = DateTime.tryParse(savedMembershipMonth);
    }
    _membershipOwnerEmail = box.get('membershipOwnerEmail');

    notifyListeners();
  }

  // Updated login to include these preferences
  Future<void> login(
    String email, {
    Locality? town,
    String? college,
    String? firstName,
    String? lastName,
  }) async {
    _userEmail = email;
    _homeTown = town ?? _homeTown;
    _targetCollege = college ?? _targetCollege;
    _firstName = firstName ?? _firstName;
    _lastName = lastName ?? _lastName;
    _isLoggedIn = true;

    var box = await Hive.openBox('userBox');
    await box.put('email', email);
    if (town != null) await box.put('homeTownIndex', town.index);
    if (college != null) await box.put('targetCollege', college);
    if (firstName != null) await box.put('firstName', firstName);
    if (lastName != null) await box.put('lastName', lastName);
    await _syncProfile();
    
    notifyListeners();
  }

  Future<void> setRegion(Region region) async {
    _selectedRegion = region;
    var box = await Hive.openBox('userBox');
    await box.put('region', region == Region.gozo ? 'gozo' : 'malta');
    notifyListeners();
  }

  Future<void> saveTimetable(List<TimetableEntry> entries) async {
    _timetable = entries;
    var box = await Hive.openBox('userBox');
    await box.put(
      'timetableEntries',
      entries.map((entry) => entry.toMap()).toList(),
    );
    await _syncProfile();
    notifyListeners();
  }

  bool hasMembershipFor(DateTime rideDate) {
    final membershipMonth = _membershipMonth;
    return membershipMonth != null &&
        _membershipOwnerEmail == _userEmail &&
        MonthlyMembership.isSameMonth(membershipMonth, rideDate);
  }

  Future<void> buyMembershipFor(DateTime month) async {
    final userEmail = _userEmail;
    if (userEmail == null) return;

    _membershipMonth = MonthlyMembership.monthStart(month);
    _membershipOwnerEmail = userEmail;
    var box = await Hive.openBox('userBox');
    await box.put('membershipMonth', _membershipMonth!.toIso8601String());
    await box.put('membershipOwnerEmail', userEmail);
    notifyListeners();
  }

  StudentProfile? get currentProfile {
    final email = _userEmail;
    final town = _homeTown;
    final campus = _targetCollege;
    final firstName = _firstName;
    final lastName = _lastName;
    if (email == null ||
        town == null ||
        campus == null ||
        firstName == null ||
        lastName == null) {
      return null;
    }

    return StudentProfile(
      email: email,
      firstName: firstName,
      lastName: lastName,
      homeTown: town,
      campus: campus,
      timetable: _timetable,
    );
  }

  Future<void> _syncProfile() async {
    final profile = currentProfile;
    if (profile != null) {
      try {
        await _firestore.syncProfile(profile);
      } catch (error) {
        debugPrint('Profile sync failed: $error');
      }
    }
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
