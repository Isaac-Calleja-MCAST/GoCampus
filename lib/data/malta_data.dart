import 'route_logic.dart';
import '../models/trip_category.dart';

/// Broad destination types used by the seasonal planner and home feed.
enum StudentDestinationType { campus, beach, nightlife, city, event }

/// A destination that can be offered as a pooled ride target.
class StudentDestination {
  const StudentDestination({
    required this.name,
    required this.locality,
    required this.type,
    required this.category,
  });

  final String name;
  final Locality locality;
  final StudentDestinationType type;
  final TripCategory category;
}

const List<Locality> maltaLocalities = [
  Locality.attard, Locality.balzan, Locality.birgu, Locality.birkirkara, Locality.birzebbuga,
  Locality.cospicua, Locality.dingli, Locality.fgura, Locality.floriana, Locality.gharghur,
  Locality.ghaxaq, Locality.gudja, Locality.gzira, Locality.hamrun, Locality.iklin, 
  Locality.kalkara, Locality.kirkop, Locality.lija, Locality.luqa, Locality.marsa, 
  Locality.marsaskala, Locality.marsaxlokk, Locality.mdina, Locality.mellieha, 
  Locality.mgarr, Locality.mosta, Locality.mqabba, Locality.msida, Locality.mtarfa, 
  Locality.naxxar, Locality.paola, Locality.pembroke, Locality.pieta, Locality.qormi, 
  Locality.qrendi, Locality.rabat, Locality.safi, Locality.sanGiljan, Locality.sanGwann, 
  Locality.stPaulsBay, Locality.santaLucija, Locality.santaVenera, Locality.senglea, 
  Locality.siggiewi, Locality.sliema, Locality.swieqi, Locality.taXbiex, Locality.tarxien, 
  Locality.valletta, Locality.xghajra, Locality.zabbar, Locality.zebbug, Locality.zejtun, Locality.zurrieq
];

const List<Locality> gozoLocalities = [
  Locality.fontana, Locality.ghajnsielem, Locality.gharb, Locality.ghasri, Locality.kercem, 
  Locality.munxar, Locality.nadur, Locality.qala, Locality.sanLawrenz, Locality.sannat, 
  Locality.victoria, Locality.xaghra, Locality.xewkija, Locality.zebbugGozo
];

const List<StudentDestination> studentDestinations = [
  StudentDestination(
    name: 'MCAST Paola',
    locality: Locality.paola,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'MCAST Mosta',
    locality: Locality.mosta,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'MCAST Luqa',
    locality: Locality.luqa,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'MCAST Gozo',
    locality: Locality.xewkija,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'University of Malta (Msida)',
    locality: Locality.msida,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'University of Malta (Marsaxlokk)',
    locality: Locality.marsaxlokk,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'University of Malta (Gozo)',
    locality: Locality.xewkija,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'Junior College (Msida)',
    locality: Locality.msida,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'ITS Malta Campus',
    locality: Locality.luqa,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'ITS Gozo Campus',
    locality: Locality.qala,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'University of Malta (Valletta)',
    locality: Locality.valletta,
    type: StudentDestinationType.campus,
    category: TripCategory.campusCommute,
  ),
  StudentDestination(
    name: 'Ghadira Bay',
    locality: Locality.mellieha,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: 'Golden Bay',
    locality: Locality.mgarr,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: 'Paradise Bay',
    locality: Locality.mellieha,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: 'Gnejna Bay',
    locality: Locality.mgarr,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: "St George's Bay",
    locality: Locality.sanGiljan,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: 'Pretty Bay',
    locality: Locality.birzebbuga,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: "St Peter's Pool",
    locality: Locality.marsaxlokk,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: 'Ramla Bay',
    locality: Locality.xaghra,
    type: StudentDestinationType.beach,
    category: TripCategory.daytimeBeachDeparture,
  ),
  StudentDestination(
    name: 'Gianpula',
    locality: Locality.rabat,
    type: StudentDestinationType.nightlife,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'Uno',
    locality: Locality.taXbiex,
    type: StudentDestinationType.nightlife,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'Cafe del Mar',
    locality: Locality.stPaulsBay,
    type: StudentDestinationType.nightlife,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'Paceville Night Out',
    locality: Locality.sanGiljan,
    type: StudentDestinationType.nightlife,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'MedAsia Playa',
    locality: Locality.sliema,
    type: StudentDestinationType.nightlife,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'Valletta',
    locality: Locality.valletta,
    type: StudentDestinationType.city,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'Isle of MTV (Floriana)',
    locality: Locality.floriana,
    type: StudentDestinationType.event,
    category: TripCategory.nighttimePartyDeparture,
  ),
  StudentDestination(
    name: 'Malta Jazz Festival (Valletta)',
    locality: Locality.valletta,
    type: StudentDestinationType.event,
    category: TripCategory.nighttimePartyDeparture,
  ),
];

final Map<String, Locality> campusMap = {
  for (final destination in campusStudentDestinations)
    destination.name: destination.locality,
};

final List<StudentDestination> campusStudentDestinations = studentDestinations
    .where((destination) => destination.type == StudentDestinationType.campus)
    .toList(growable: false);

final List<StudentDestination> summerStudentDestinations = studentDestinations
    .where((destination) => destination.type != StudentDestinationType.campus)
    .toList(growable: false);

final List<String> campusDestinations =
    campusStudentDestinations.map((destination) => destination.name).toList();

List<StudentDestination> destinationsForCategory(TripCategory category) {
  return studentDestinations
      .where((destination) => destination.category == category)
      .toList(growable: false);
}

StudentDestination? findStudentDestination(String name) {
  for (final destination in studentDestinations) {
    if (destination.name == name) return destination;
  }
  return null;
}

String getCampusDisplayName(Locality locality) {
  return getStudentDestinationName(locality);
}

String getStudentDestinationName(
  Locality locality, {
  TripCategory? category,
}) {
  try {
    return studentDestinations
        .where(
          (destination) =>
              destination.locality == locality &&
              (category == null || destination.category == category),
        )
        .first
        .name;
  } catch (e) {
    return locality.name;
  }
}
