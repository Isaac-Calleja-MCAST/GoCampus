import 'package:flutter_test/flutter_test.dart';
import 'package:go_campus/models/monthly_membership.dart';

void main() {
  group('MonthlyMembership', () {
    test('uses scholastic pricing outside June to September', () {
      expect(MonthlyMembership.priceFor(DateTime(2026, 5)), 7);
      expect(MonthlyMembership.priceFor(DateTime(2026, 10)), 7);
    });

    test('uses summer and exam pricing from June to September', () {
      expect(MonthlyMembership.priceFor(DateTime(2026, 6)), 10);
      expect(MonthlyMembership.priceFor(DateTime(2026, 9)), 10);
    });

    test('matches membership coverage by month and year', () {
      expect(
        MonthlyMembership.isSameMonth(DateTime(2026, 7, 1), DateTime(2026, 7, 31)),
        isTrue,
      );
      expect(
        MonthlyMembership.isSameMonth(DateTime(2026, 7), DateTime(2027, 7)),
        isFalse,
      );
    });
  });
}
