/// Validates the lightweight student-email rule used by the demo login flow.
class StudentEmailValidator {
  const StudentEmailValidator._();

  static const Set<String> _localStudentDomains = {
    'mcast.edu.mt',
    'um.edu.mt',
  };

  /// Accepts the local demo domains and international domains ending in `.edu`.
  static bool isAllowed(String email) {
    final normalized = email.trim().toLowerCase();
    final atIndex = normalized.lastIndexOf('@');
    if (atIndex <= 0 || atIndex == normalized.length - 1) return false;

    final domain = normalized.substring(atIndex + 1);
    return _localStudentDomains.contains(domain) || domain.endsWith('.edu');
  }

  /// A user-facing validation result for the demo login form.
  static String? errorMessage(String email) {
    if (email.trim().isEmpty) return 'Enter your student email.';
    if (isAllowed(email)) return null;
    return 'Use an MCAST, UoM, or .edu student email.';
  }
}
