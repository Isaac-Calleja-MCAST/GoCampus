/// Seasonal monthly membership pricing for the GoCampus demo.
class MonthlyMembership {
  const MonthlyMembership._();

  static const double scholasticPrice = 7.00;
  static const double summerExamPrice = 10.00;

  /// June to September uses the summer and exam-season membership price.
  static double priceFor(DateTime month) {
    return isSummerOrExamSeason(month) ? summerExamPrice : scholasticPrice;
  }

  static bool isSummerOrExamSeason(DateTime date) {
    return date.month >= DateTime.june && date.month <= DateTime.september;
  }

  static DateTime monthStart(DateTime date) => DateTime(date.year, date.month);

  static bool isSameMonth(DateTime first, DateTime second) {
    return first.year == second.year && first.month == second.month;
  }

  static String storageKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month';
  }
}
