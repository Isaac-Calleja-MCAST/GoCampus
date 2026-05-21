import '../data/route_logic.dart';
import 'timetable_entry.dart';

/// Shared student profile data used for timetable recommendations.
class StudentProfile {
  const StudentProfile({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.homeTown,
    required this.campus,
    this.timetable = const [],
  });

  final String email;
  final String firstName;
  final String lastName;
  final Locality homeTown;
  final String campus;
  final List<TimetableEntry> timetable;

  String get displayName => '$firstName $lastName'.trim();

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'homeTown': homeTown.index,
      'campus': campus,
      'timetable': timetable.map((entry) => entry.toMap()).toList(),
    };
  }

  factory StudentProfile.fromMap(Map<String, dynamic> map) {
    final rawTimetable = map['timetable'] as List<dynamic>? ?? const [];
    return StudentProfile(
      email: map['email'] as String,
      firstName: map['firstName'] as String? ?? '',
      lastName: map['lastName'] as String? ?? '',
      homeTown: Locality.values[map['homeTown'] as int],
      campus: map['campus'] as String? ?? '',
      timetable: rawTimetable
          .map((entry) => TimetableEntry.fromMap(Map<String, dynamic>.from(entry)))
          .toList(growable: false),
    );
  }
}
