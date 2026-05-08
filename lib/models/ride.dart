class Ride {
  final String id;
  final String driverName;
  final String fromLocation;
  final String toLocation; // e.g., MCAST Paola
  final DateTime departureTime;
  final int availableSeats;
  final double pricePerSeat;

  Ride({
    required this.id,
    required this.driverName,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    required this.availableSeats,
    required this.pricePerSeat,
  });
}