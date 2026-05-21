/// One recurring start time from a student's weekly timetable.
class TimetableEntry {
  const TimetableEntry({
    required this.weekday,
    required this.hour,
    required this.minute,
  });

  final int weekday;
  final int hour;
  final int minute;

  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get weekdayName => weekdayNames[weekday - DateTime.monday];

  String get startTime {
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  String get label => '$weekdayName at $startTime';

  bool startsWith(TimetableEntry other) {
    return weekday == other.weekday &&
        hour == other.hour &&
        minute == other.minute;
  }

  Map<String, dynamic> toMap() {
    return {
      'weekday': weekday,
      'hour': hour,
      'minute': minute,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      weekday: map['weekday'] as int,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
    );
  }

  static List<TimetableEntry> parseImport(String text) {
    final entries = <TimetableEntry>[];
    final lines = text.split(RegExp(r'\r?\n'));

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      final parts = line.split(',');
      if (parts.length != 2) {
        throw const FormatException('Use one line per day and time.');
      }

      final weekday = _parseWeekday(parts[0].trim());
      final timeParts = parts[1].trim().split(':');
      if (timeParts.length != 2) {
        throw const FormatException('Use 24-hour times such as 08:00.');
      }

      final hour = int.tryParse(timeParts[0]);
      final minute = int.tryParse(timeParts[1]);
      if (hour == null ||
          minute == null ||
          hour < 0 ||
          hour > 23 ||
          minute < 0 ||
          minute > 59) {
        throw const FormatException('Use valid 24-hour timetable times.');
      }

      entries.add(TimetableEntry(weekday: weekday, hour: hour, minute: minute));
    }

    if (entries.isEmpty) {
      throw const FormatException('Add at least one timetable line.');
    }

    entries.sort((first, second) {
      final dayOrder = first.weekday.compareTo(second.weekday);
      if (dayOrder != 0) return dayOrder;
      final hourOrder = first.hour.compareTo(second.hour);
      if (hourOrder != 0) return hourOrder;
      return first.minute.compareTo(second.minute);
    });
    return entries;
  }

  static int _parseWeekday(String value) {
    final normalized = value.toLowerCase();
    for (var index = 0; index < weekdayNames.length; index++) {
      final name = weekdayNames[index].toLowerCase();
      if (name == normalized || name.startsWith(normalized)) {
        return DateTime.monday + index;
      }
    }
    throw const FormatException('Use weekday names such as Monday.');
  }
}
