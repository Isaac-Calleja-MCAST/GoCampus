class CarpoolPool {
  final String id;
  final String originLocality;
  final String destination;
  final DateTime lectureTime;
  final List<String> studentEmails;
  final int maxCapacity;

  static const double baseRideCost = 12.00;
  static const double platformFee = 0.50;

  CarpoolPool({
    required this.id,
    required this.originLocality,
    required this.destination,
    required this.lectureTime,
    required this.studentEmails,
    this.maxCapacity = 4,
  });

  double get pricePerStudent {
    if (studentEmails.isEmpty) return baseRideCost + platformFee;
    return (baseRideCost / studentEmails.length) + platformFee;
  }

  // This fixes the 'savings' error in home_screen.dart
  double get savings => baseRideCost - pricePerStudent;

  bool get isFull => studentEmails.length >= maxCapacity;
}