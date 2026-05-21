import 'package:flutter_test/flutter_test.dart';
import 'package:go_campus/models/timetable_entry.dart';

void main() {
  group('TimetableEntry import', () {
    test('parses weekday and 24-hour time lines', () {
      final entries = TimetableEntry.parseImport(
        'Monday,08:00\nThursday,10:30',
      );

      expect(entries, hasLength(2));
      expect(entries.first.weekday, DateTime.monday);
      expect(entries.first.startTime, '08:00');
      expect(entries.last.label, 'Thursday at 10:30');
    });

    test('rejects invalid timetable lines', () {
      expect(
        () => TimetableEntry.parseImport('Monday at 08:00'),
        throwsFormatException,
      );
    });
  });
}
