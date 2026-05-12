enum Locality {
  attard, balzan, birgu, birkirkara, birzebbuga, cospicua, dingli, fgura, floriana, 
  gharghur, ghaxaq, gudja, gzira, hamrun, iklin, kalkara, kirkop, lija, luqa, marsa, 
  marsaskala, marsaxlokk, mdina, mellieha, mgarr, mosta, mqabba, msida, mtarfa, 
  naxxar, paola, pembroke, pieta, qormi, qrendi, rabat, safi, sanGiljan, sanGwann, 
  stPaulsBay, santaLucija, santaVenera, senglea, siggiewi, sliema, swieqi, taXbiex, 
  tarxien, valletta, xghajra, zabbar, zebbug, zejtun, zurrieq,
  fontana, ghajnsielem, gharb, ghasri, kercem, munxar, nadur, qala, sanLawrenz, 
  sannat, victoria, xaghra, xewkija, zebbugGozo
}

enum RouteZone { harbour, central, centralSouth, centralNorth, north, southHarbour, south, west, gozo }

class LocalityNode {
  final Locality locality;
  final String displayName;
  final RouteZone zone;
  final List<Locality> connected;

  const LocalityNode({
    required this.locality,
    required this.displayName,
    required this.zone,
    this.connected = const [],
  });
}

const Map<Locality, LocalityNode> localityGraph = {
  Locality.msida: LocalityNode(locality: Locality.msida, displayName: "Msida", zone: RouteZone.harbour, connected: [Locality.gzira, Locality.pieta, Locality.birkirkara, Locality.taXbiex]),
  Locality.valletta: LocalityNode(locality: Locality.valletta, displayName: "Valletta", zone: RouteZone.harbour, connected: [Locality.floriana]),
  Locality.sliema: LocalityNode(locality: Locality.sliema, displayName: "Sliema", zone: RouteZone.harbour, connected: [Locality.gzira, Locality.sanGiljan]),
  Locality.hamrun: LocalityNode(locality: Locality.hamrun, displayName: "Ħamrun", zone: RouteZone.central, connected: [Locality.msida, Locality.pieta, Locality.santaVenera]),
  Locality.birkirkara: LocalityNode(locality: Locality.birkirkara, displayName: "Birkirkara", zone: RouteZone.central, connected: [Locality.msida, Locality.mosta, Locality.attard, Locality.santaVenera]),
  Locality.zebbug: LocalityNode(locality: Locality.zebbug, displayName: "Żebbuġ", zone: RouteZone.centralSouth, connected: [Locality.siggiewi, Locality.qormi, Locality.attard, Locality.rabat]),
  Locality.qormi: LocalityNode(locality: Locality.qormi, displayName: "Qormi", zone: RouteZone.centralSouth, connected: [Locality.zebbug, Locality.marsa, Locality.luqa, Locality.paola]),
  Locality.siggiewi: LocalityNode(locality: Locality.siggiewi, displayName: "Siġġiewi", zone: RouteZone.centralSouth, connected: [Locality.zebbug, Locality.qormi, Locality.luqa]),
  Locality.mosta: LocalityNode(locality: Locality.mosta, displayName: "Mosta", zone: RouteZone.centralNorth, connected: [Locality.naxxar, Locality.attard, Locality.birkirkara]),
  Locality.mellieha: LocalityNode(locality: Locality.mellieha, displayName: "Mellieħa", zone: RouteZone.north, connected: [Locality.stPaulsBay]),
  Locality.stPaulsBay: LocalityNode(locality: Locality.stPaulsBay, displayName: "St. Paul's Bay", zone: RouteZone.north, connected: [Locality.mellieha, Locality.mosta]),
  Locality.paola: LocalityNode(locality: Locality.paola, displayName: "Paola", zone: RouteZone.southHarbour, connected: [Locality.fgura, Locality.marsa, Locality.luqa, Locality.tarxien]),
  Locality.zurrieq: LocalityNode(locality: Locality.zurrieq, displayName: "Żurrieq", zone: RouteZone.south, connected: [Locality.qrendi, Locality.safi]),
  Locality.nadur: LocalityNode(locality: Locality.nadur, displayName: "Nadur", zone: RouteZone.gozo, connected: [Locality.xaghra, Locality.qala]),
  Locality.victoria: LocalityNode(locality: Locality.victoria, displayName: "Victoria (Rabat)", zone: RouteZone.gozo, connected: [Locality.xewkija, Locality.sannat]),
};

class MatchingEngine {
  // FIX: Renamed method and parameters to match RideProvider call
  static bool checkCompatibility({
    required Locality userOrigin,
    required Locality poolOrigin,
    required Locality userDestination,
    required Locality poolDestination,
    required DateTime userDepartureTime,
    required DateTime poolDepartureTime,
  }) {
    if (userDestination != poolDestination) return false;

    int score = 0;

    // 1. Origin Matching
    if (userOrigin == poolOrigin) {
      score += 30;
    } else if (localityGraph[userOrigin]?.connected.contains(poolOrigin) ?? false) {
      score += 20;
    } else if (localityGraph[userOrigin]?.zone == localityGraph[poolOrigin]?.zone) {
      score += 10;
    }

    // 2. Time Window Matching
    final diff = userDepartureTime.difference(poolDepartureTime).inMinutes.abs();
    if (diff <= 15) {
      score += 30;
    } else if (diff <= 30) {
      score += 15;
    }

    // 3. Final Decision (Score 50+ is a match)
    return score >= 50;
  }
}

extension LocalityExtension on Locality {
  String get name {
    if (localityGraph.containsKey(this)) return localityGraph[this]!.displayName;
    String raw = toString().split('.').last;
    return raw.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').replaceFirst(raw[0], raw[0].toUpperCase());
  }
}