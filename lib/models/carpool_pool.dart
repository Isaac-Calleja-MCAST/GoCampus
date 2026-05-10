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

  // Convert Pool object to a Map for Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originLocality': originLocality.index, // Save Enum as a number
      'destination': destination.index,
      'lectureTime': lectureTime.toIso8601String(),
      'studentEmails': studentEmails,
      'studentAddresses': studentAddresses,
      'leadStudentEmail': leadStudentEmail,
      'region': region.index,
      'status': status.index,
      'fetchedPrice': fetchedPrice,
    };
  }

  // Create a Pool object from a Hive Map
  factory CarpoolPool.fromMap(Map<dynamic, dynamic> map) {
    return CarpoolPool(
      id: map['id'],
      originLocality: Locality.values[map['originLocality']],
      destination: Locality.values[map['destination']],
      lectureTime: DateTime.parse(map['lectureTime']),
      studentEmails: List<String>.from(map['studentEmails']),
      studentAddresses: Map<String, String>.from(map['studentAddresses']),
      leadStudentEmail: map['leadStudentEmail'],
      region: Region.values[map['region']],
      status: PoolStatus.values[map['status']],
      fetchedPrice: map['fetchedPrice'],
    );
  }
}