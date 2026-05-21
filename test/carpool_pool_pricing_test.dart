import 'package:flutter_test/flutter_test.dart';
import 'package:go_campus/data/route_logic.dart';
import 'package:go_campus/models/carpool_pool.dart';

void main() {
  group('CarpoolPool platform fee', () {
    test('uses the scholastic fee outside June to September', () {
      expect(CarpoolPool.platformFeeFor(DateTime(2026, 5, 31)), 1);
      expect(CarpoolPool.platformFeeFor(DateTime(2026, 10, 1)), 1);
    });

    test('uses the summer and exam-season fee from June to September', () {
      expect(CarpoolPool.platformFeeFor(DateTime(2026, 6, 1)), 2);
      expect(CarpoolPool.platformFeeFor(DateTime(2026, 9, 30)), 2);
    });

    test('adds the fee after the driver fare is split', () {
      final pool = CarpoolPool(
        id: 'summer-pool',
        originLocality: Locality.msida,
        destination: Locality.valletta,
        lectureTime: DateTime(2026, 7, 10),
        studentEmails: const ['a@campus.edu', 'b@campus.edu'],
        leadStudentEmail: 'a@campus.edu',
        region: Region.malta,
        fetchedPrice: 12,
      );

      expect(pool.totalRideCost, 12);
      expect(pool.fareSharePerStudent, 6);
      expect(pool.platformFee, 2);
      expect(pool.pricePerStudent, 8);
      expect(pool.pricePerStudentFor(hasMonthlyMembership: true), 6);
      expect(pool.feeFor(hasMonthlyMembership: true), 0);
    });
  });
}
