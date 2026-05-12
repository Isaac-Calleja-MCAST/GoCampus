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
  final List<String> readyToStartEmails;
  final List<String> paidStudentEmails;
  final String leadStudentEmail;
  final Region region;
  final PoolStatus status;
  final double? fetchedPrice;
  final String? driverName;
  final String? licensePlate;

  static const double platformFee = 0.50;

  CarpoolPool({
    required this.id, required this.originLocality, required this.destination,
    required this.lectureTime, required this.studentEmails,
    this.studentAddresses = const {}, this.readyToStartEmails = const [],
    this.paidStudentEmails = const [], required this.leadStudentEmail,
    required this.region, this.status = PoolStatus.recruiting,
    this.fetchedPrice, this.driverName, this.licensePlate,
  });

  CarpoolPool copyWith({
    PoolStatus? status, String? leadStudentEmail, List<String>? readyToStartEmails,
    List<String>? paidStudentEmails, Map<String, String>? studentAddresses,
    double? fetchedPrice, List<String>? studentEmails, String? driverName, String? licensePlate,
  }) {
    return CarpoolPool(
      id: id, originLocality: originLocality, destination: destination,
      lectureTime: lectureTime, region: region,
      studentEmails: studentEmails ?? this.studentEmails,
      studentAddresses: studentAddresses ?? this.studentAddresses,
      readyToStartEmails: readyToStartEmails ?? this.readyToStartEmails,
      paidStudentEmails: paidStudentEmails ?? this.paidStudentEmails,
      leadStudentEmail: leadStudentEmail ?? this.leadStudentEmail,
      status: status ?? this.status,
      fetchedPrice: fetchedPrice ?? this.fetchedPrice,
      driverName: driverName ?? this.driverName,
      licensePlate: licensePlate ?? this.licensePlate,
    );
  }

  // LOGIC HELPERS (Principle 18)
  bool get isFull => studentEmails.length >= 4;
  bool get allAddressesCollected => studentEmails.isNotEmpty && studentEmails.every((email) => studentAddresses.containsKey(email));
  bool get isFullyFunded => studentEmails.isNotEmpty && paidStudentEmails.length == studentEmails.length;
  double get fundingProgress => studentEmails.isEmpty ? 0 : paidStudentEmails.length / studentEmails.length;
  double get pricePerStudent => ((fetchedPrice ?? 12.00) / studentEmails.length) + platformFee;
  double get savings => (fetchedPrice ?? 12.00) - pricePerStudent;

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'originLocality': originLocality.index, 'destination': destination.index,
      'lectureTime': lectureTime.toIso8601String(), 'studentEmails': studentEmails,
      'studentAddresses': studentAddresses, 'readyToStartEmails': readyToStartEmails,
      'paidStudentEmails': paidStudentEmails, 'leadStudentEmail': leadStudentEmail,
      'region': region.index, 'status': status.index, 'fetchedPrice': fetchedPrice,
      'driverName': driverName, 'licensePlate': licensePlate,
    };
  }

  factory CarpoolPool.fromMap(Map<String, dynamic> map) {
    return CarpoolPool(
      id: map['id'],
      originLocality: Locality.values[map['originLocality']],
      destination: Locality.values[map['destination']],
      lectureTime: DateTime.parse(map['lectureTime']),
      studentEmails: List<String>.from(map['studentEmails'] ?? []),
      studentAddresses: Map<String, String>.from(map['studentAddresses'] ?? {}),
      readyToStartEmails: List<String>.from(map['readyToStartEmails'] ?? []),
      paidStudentEmails: List<String>.from(map['paidStudentEmails'] ?? []),
      leadStudentEmail: map['leadStudentEmail'],
      region: Region.values[map['region']],
      status: PoolStatus.values[map['status']],
      fetchedPrice: (map['fetchedPrice'] as num?)?.toDouble(),
      driverName: map['driverName'],
      licensePlate: map['licensePlate'],
    );
  }
}