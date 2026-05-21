// models/carpool_pool.dart
import '../data/route_logic.dart';
import 'trip_category.dart';

enum Region { malta, gozo }
enum PoolStatus { recruiting, collectingAddresses, awaitingPayment, booked }

class CarpoolPool {
  final String id;
  final Locality originLocality;
  final Locality destination; 
  // Kept for existing cached and Firestore demo data.
  final DateTime lectureTime;
  final TripCategory tripCategory;
  final List<String> studentEmails;
  final Map<String, String> studentNames;
  final Map<String, String> studentAddresses; 
  final List<String> readyToStartEmails;
  final List<String> paidStudentEmails;
  final String leadStudentEmail;
  final Region region;
  final PoolStatus status;
  final double? fetchedPrice;
  final String? driverName;
  final String? licensePlate;

  static const double scholasticPlatformFee = 1.00;
  static const double summerExamPlatformFee = 2.00;

  CarpoolPool({
    required this.id, required this.originLocality, required this.destination,
    required this.lectureTime, required this.studentEmails,
    this.studentNames = const {}, this.studentAddresses = const {},
    this.readyToStartEmails = const [],
    this.paidStudentEmails = const [], required this.leadStudentEmail,
    required this.region, this.status = PoolStatus.recruiting,
    this.tripCategory = TripCategory.campusCommute,
    this.fetchedPrice, this.driverName, this.licensePlate,
  });

  CarpoolPool copyWith({
    PoolStatus? status, String? leadStudentEmail, List<String>? readyToStartEmails,
    List<String>? paidStudentEmails, Map<String, String>? studentAddresses,
    Map<String, String>? studentNames, double? fetchedPrice,
    List<String>? studentEmails, String? driverName, String? licensePlate,
  }) {
    return CarpoolPool(
      id: id, originLocality: originLocality, destination: destination,
      lectureTime: lectureTime, region: region, tripCategory: tripCategory,
      studentEmails: studentEmails ?? this.studentEmails,
      studentNames: studentNames ?? this.studentNames,
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
  DateTime get departureTime => lectureTime;
  // A pool stays visible for a short grace period after departure.
  bool get isExpired {
    final now = DateTime.now();
    return now.isAfter(departureTime.add(const Duration(hours: 2)));
  }
  double get fundingProgress => studentEmails.isEmpty ? 0 : paidStudentEmails.length / studentEmails.length;

  /// Returns the per-student fee for the pool departure date.
  ///
  /// June to September covers the demo's summer and exam-season demand.
  static double platformFeeFor(DateTime departureTime) {
    final isSummerOrExamSeason =
        departureTime.month >= DateTime.june &&
        departureTime.month <= DateTime.september;
    return isSummerOrExamSeason
        ? summerExamPlatformFee
        : scholasticPlatformFee;
  }

  double get platformFee => platformFeeFor(departureTime);
  double get rideFare => fetchedPrice ?? 12.00;
  double get totalPlatformFees => studentEmails.length * platformFee;

  // The driver fare stays separate from GoCampus' per-student fee.
  double get totalRideCost => rideFare;

  double get fareSharePerStudent =>
      studentEmails.isEmpty ? 0 : rideFare / studentEmails.length;

  // What the individual student pays after splitting the fare and adding the fee.
  double get pricePerStudent => fareSharePerStudent + platformFee;
  double pricePerStudentFor({required bool hasMonthlyMembership}) {
    return fareSharePerStudent + feeFor(hasMonthlyMembership: hasMonthlyMembership);
  }

  double feeFor({required bool hasMonthlyMembership}) {
    return hasMonthlyMembership ? 0 : platformFee;
  }

  // Shows the saving against paying the whole driver fare alone.
  double get savings => rideFare - pricePerStudent;
  double savingsFor({required bool hasMonthlyMembership}) {
    return rideFare - pricePerStudentFor(hasMonthlyMembership: hasMonthlyMembership);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, 'originLocality': originLocality.index, 'destination': destination.index,
      'lectureTime': lectureTime.toIso8601String(), 'studentEmails': studentEmails,
      'studentNames': studentNames,
      'studentAddresses': studentAddresses, 'readyToStartEmails': readyToStartEmails,
      'paidStudentEmails': paidStudentEmails, 'leadStudentEmail': leadStudentEmail,
      'region': region.index, 'status': status.index, 'fetchedPrice': fetchedPrice,
      'driverName': driverName, 'licensePlate': licensePlate,
      'tripCategory': tripCategory.index,
    };
  }

  factory CarpoolPool.fromMap(Map<String, dynamic> map) {
    return CarpoolPool(
      id: map['id'],
      originLocality: Locality.values[map['originLocality']],
      destination: Locality.values[map['destination']],
      lectureTime: DateTime.parse(map['lectureTime']),
      studentEmails: List<String>.from(map['studentEmails'] ?? []),
      studentNames: Map<String, String>.from(map['studentNames'] ?? {}),
      studentAddresses: Map<String, String>.from(map['studentAddresses'] ?? {}),
      readyToStartEmails: List<String>.from(map['readyToStartEmails'] ?? []),
      paidStudentEmails: List<String>.from(map['paidStudentEmails'] ?? []),
      leadStudentEmail: map['leadStudentEmail'],
      region: Region.values[map['region']],
      status: PoolStatus.values[map['status']],
      tripCategory: TripCategory.values[
        map['tripCategory'] ?? TripCategory.campusCommute.index
      ],
      fetchedPrice: (map['fetchedPrice'] as num?)?.toDouble(),
      driverName: map['driverName'],
      licensePlate: map['licensePlate'],
    );
  }
}
