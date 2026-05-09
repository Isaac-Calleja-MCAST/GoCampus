import '../data/route_logic.dart';
enum Region { malta, gozo }
enum PoolStatus { recruiting, collectingAddresses, awaitingPayment, booked }

class CarpoolPool {
  final String id;
  final Locality originLocality;
  final Locality destination; 
  final DateTime lectureTime;
  final List<String> studentEmails;
  final Map<String, String> studentAddresses; 
  final String leadStudentEmail;
  final Region region;
  final PoolStatus status;
  final double? fetchedPrice;

  static const double platformFee = 0.50;

  CarpoolPool({
    required this.id,
    required this.originLocality,
    required this.destination,
    required this.lectureTime,
    required this.studentEmails,
    this.studentAddresses = const {},
    required this.leadStudentEmail,
    required this.region,
    this.status = PoolStatus.recruiting,
    this.fetchedPrice,
  });

  // LOGIC HELPERS
  
  // FIX FOR ERROR: Added this getter back
  bool get isFull => studentEmails.length >= 4;

  double get pricePerStudent {
    double total = fetchedPrice ?? 12.00; 
    return (total / studentEmails.length) + platformFee;
  }

  // DYNAMIC SAVINGS: Calculated based on the real cost of the car
  double get savings {
    double total = fetchedPrice ?? 12.00;
    return total - pricePerStudent;
  }
}