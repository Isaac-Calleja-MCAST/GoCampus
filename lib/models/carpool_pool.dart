enum Region { malta, gozo }

class CarpoolPool {
  final String id;
  final String originLocality;
  final String destination;
  final DateTime lectureTime;
  final List<String> studentEmails;
  final Region region; // NEW
  final int maxCapacity;

  static const double baseRideCost = 12.00;
  static const double platformFee = 0.50;

  CarpoolPool({
    required this.id,
    required this.originLocality,
    required this.destination,
    required this.lectureTime,
    required this.studentEmails,
    required this.region, // NEW
    this.maxCapacity = 4,
  });

  double get pricePerStudent => (baseRideCost / studentEmails.length) + platformFee;
  double get savings => baseRideCost - pricePerStudent;
  bool get isFull => studentEmails.length >= maxCapacity;
}