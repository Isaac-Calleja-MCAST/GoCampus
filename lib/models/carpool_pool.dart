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
  final List<String> readyToStartEmails;

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
    this.readyToStartEmails = const [],
  });

  CarpoolPool copyWith({
    PoolStatus? status, 
    String? leadStudentEmail, 
    List<String>? readyToStartEmails,
    Map<String, String>? studentAddresses,
    double? fetchedPrice,
  }) {
    return CarpoolPool(
      id: id,
      originLocality: originLocality,
      destination: destination,
      lectureTime: lectureTime,
      studentEmails: studentEmails,
      studentAddresses: studentAddresses ?? this.studentAddresses,
      readyToStartEmails: readyToStartEmails ?? this.readyToStartEmails,
      leadStudentEmail: leadStudentEmail ?? this.leadStudentEmail,
      region: region,
      status: status ?? this.status,
      fetchedPrice: fetchedPrice ?? this.fetchedPrice,
    );
  }

  bool get isFull => studentEmails.length >= 4;

  bool get allAddressesCollected => 
    studentEmails.every((email) => studentAddresses.containsKey(email));

  bool get everyoneAgreedToStart => 
    studentEmails.length > 1 && 
    studentEmails.every((e) => readyToStartEmails.contains(e));
  
  double get pricePerStudent {
    double total = fetchedPrice ?? 12.00; 
    return (total / studentEmails.length) + platformFee;
  }

  double get savings {
    double total = fetchedPrice ?? 12.00;
    return total - pricePerStudent;
  }

  // --- HIVE SERIALIZATION (FIXED) ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'originLocality': originLocality.index,
      'destination': destination.index,
      'lectureTime': lectureTime.toIso8601String(),
      'studentEmails': studentEmails,
      'studentAddresses': studentAddresses,
      'readyToStartEmails': readyToStartEmails, 
      'leadStudentEmail': leadStudentEmail,
      'region': region.index,
      'status': status.index,
      'fetchedPrice': fetchedPrice,
    };
  }

  factory CarpoolPool.fromMap(Map<dynamic, dynamic> map) {
    return CarpoolPool(
      id: map['id'],
      originLocality: Locality.values[map['originLocality']],
      destination: Locality.values[map['destination']],
      lectureTime: DateTime.parse(map['lectureTime']),
      studentEmails: List<String>.from(map['studentEmails']),
      studentAddresses: Map<String, String>.from(map['studentAddresses']),
      readyToStartEmails: List<String>.from(map['readyToStartEmails'] ?? []), 
      leadStudentEmail: map['leadStudentEmail'],
      region: Region.values[map['region']],
      status: PoolStatus.values[map['status']],
      fetchedPrice: map['fetchedPrice'],
    );
  }
}