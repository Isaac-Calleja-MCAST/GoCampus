import 'package:flutter_test/flutter_test.dart';
import 'package:go_campus/services/student_email_validator.dart';

void main() {
  group('StudentEmailValidator', () {
    test('accepts local demo student domains', () {
      expect(StudentEmailValidator.isAllowed('student@mcast.edu.mt'), isTrue);
      expect(StudentEmailValidator.isAllowed('student@um.edu.mt'), isTrue);
    });

    test('accepts international dot edu domains', () {
      expect(StudentEmailValidator.isAllowed('foreign@campus.edu'), isTrue);
      expect(StudentEmailValidator.isAllowed('FOREIGN@CAMPUS.EDU'), isTrue);
    });

    test('rejects non-student email domains', () {
      expect(StudentEmailValidator.isAllowed('student@gmail.com'), isFalse);
      expect(StudentEmailValidator.isAllowed('not-an-email'), isFalse);
    });
  });
}
