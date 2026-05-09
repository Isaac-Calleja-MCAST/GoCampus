// ================================
// COMPREHENSIVE LOCALITIES
// ================================
enum Locality {
  // Harbour / Central
  valletta, floriana, pieta, msida, gzira, sliema, sanGiljan, pembroke, taXbiex, swieqi, sanGwann,
  // Central
  birkirkara, attard, balzan, lija, iklin, santaVenera, hamrun, qormi, zebbug, siggiewi,
  // Northern Central
  mosta, naxxar, gharghur,
  // Northern
  mellieha, stPaulsBay, mgarr, burmarrad,
  // Southern Harbour
  paola, fgura, zabbar, marsa, cospicua, senglea, birgu, kalkara, xghajra, santaLucija, tarxien,
  // Southern
  birzebbuga, zejtun, marsaxlokk, zurrieq, safi, qrendi, mqabba, kirkop, gudja, ghaxaq, luqa, siggiewiMalta, marsaskala,
  // West
  rabat, mdina, dingli, mtarfa,
  // Gozo
  fontana, ghajnsielem, gharb, ghasri, kercem, munxar, nadur, qala, sanLawrenz, sannat, victoria, xaghra, xewkija, zebbugGozo,
}

// ================================
// ROUTE ZONES (For fallback matching)
// ================================
enum RouteZone {
  harbour, central, centralNorth, north, southHarbour, south, west, gozo
}

class LocalityNode {
  final Locality locality;
  final String displayName;
  final RouteZone zone;
  final List<Locality> connected; // Neighboring towns

  const LocalityNode({
    required this.locality,
    required this.displayName,
    required this.zone,
    this.connected = const [],
  });
}

// ================================
// THE MASTER MALTESE LOCALITY GRAPH
// ================================
const Map<Locality, LocalityNode> localityGraph = {
  // HARBOUR ZONE
  Locality.msida: LocalityNode(locality: Locality.msida, displayName: "Msida", zone: RouteZone.harbour, connected: [Locality.gzira, Locality.pieta, Locality.birkirkara, Locality.taXbiex]),
  Locality.valletta: LocalityNode(locality: Locality.valletta, displayName: "Valletta", zone: RouteZone.harbour, connected: [Locality.floriana]),
  Locality.sliema: LocalityNode(locality: Locality.sliema, displayName: "Sliema", zone: RouteZone.harbour, connected: [Locality.gzira, Locality.sanGiljan]),
  Locality.swieqi: LocalityNode(locality: Locality.swieqi, displayName: "Swieqi", zone: RouteZone.harbour, connected: [Locality.pembroke, Locality.sanGiljan]),
  
  // CENTRAL ZONE
  Locality.birkirkara: LocalityNode(locality: Locality.birkirkara, displayName: "Birkirkara", zone: RouteZone.central, connected: [Locality.msida, Locality.mosta, Locality.attard, Locality.santaVenera]),
  Locality.zebbug: LocalityNode(locality: Locality.zebbug, displayName: "Żebbuġ", zone: RouteZone.central, connected: [Locality.qormi, Locality.siggiewi, Locality.attard, Locality.rabat]),
  Locality.qormi: LocalityNode(locality: Locality.qormi, displayName: "Qormi", zone: RouteZone.central, connected: [Locality.zebbug, Locality.marsa, Locality.luqa, Locality.paola]),

  // NORTH ZONE
  Locality.mosta: LocalityNode(locality: Locality.mosta, displayName: "Mosta", zone: RouteZone.centralNorth, connected: [Locality.naxxar, Locality.mgarr, Locality.birkirkara]),
  Locality.mellieha: LocalityNode(locality: Locality.mellieha, displayName: "Mellieħa", zone: RouteZone.north, connected: [Locality.stPaulsBay]),
  Locality.stPaulsBay: LocalityNode(locality: Locality.stPaulsBay, displayName: "St. Paul's Bay", zone: RouteZone.north, connected: [Locality.mellieha, Locality.mosta]),

  // SOUTH ZONE
  Locality.paola: LocalityNode(locality: Locality.paola, displayName: "Paola", zone: RouteZone.southHarbour, connected: [Locality.fgura, Locality.marsa, Locality.luqa, Locality.tarxien]),
  Locality.zurrieq: LocalityNode(locality: Locality.zurrieq, displayName: "Żurrieq", zone: RouteZone.south, connected: [Locality.qrendi, Locality.safi]),
  
  // GOZO ZONE
  Locality.nadur: LocalityNode(locality: Locality.nadur, displayName: "Nadur", zone: RouteZone.gozo, connected: [Locality.xaghra, Locality.qala]),
  Locality.xewkija: LocalityNode(locality: Locality.xewkija, displayName: "Xewkija", zone: RouteZone.gozo, connected: [Locality.victoria, Locality.sannat]),
};

// ================================
// MATCH RESULT
// ================================

class MatchResult {
  final bool compatible;
  final int score;

  const MatchResult({
    required this.compatible,
    required this.score,
  });
}

// ================================
// MATCHING ENGINE
// ================================

class MatchingEngine {
  static MatchResult checkCompatibility({
    required Locality userOrigin,
    required Locality poolOrigin,
    required Locality userDestination,
    required Locality poolDestination,
    required DateTime userDepartureTime,
    required DateTime poolDepartureTime,
  }) {
    int score = 0;

    // =========================================
    // DESTINATION MATCHING
    // =========================================

    if (userDestination == poolDestination) {
      score += 40;
    } else {
      return const MatchResult(
        compatible: false,
        score: 0,
      );
    }

    // =========================================
    // EXACT ORIGIN MATCH
    // =========================================

    if (userOrigin == poolOrigin) {
      score += 30;
    }

    // =========================================
    // CONNECTED LOCALITY MATCH
    // =========================================

    else if (
        localityGraph[userOrigin]
                ?.connected
                .contains(poolOrigin) ??
            false) {
      score += 20;
    }

    // =========================================
    // SAME ZONE MATCH
    // =========================================

    else {
      final userZone = localityGraph[userOrigin]?.zone;
      final poolZone = localityGraph[poolOrigin]?.zone;

      if (userZone == poolZone) {
        score += 10;
      }
    }

    // =========================================
    // TIME WINDOW MATCH
    // =========================================

    final minuteDifference = userDepartureTime
        .difference(poolDepartureTime)
        .inMinutes
        .abs();

    if (minuteDifference <= 15) {
      score += 20;
    } else if (minuteDifference <= 30) {
      score += 10;
    }

    // =========================================
    // FINAL RESULT
    // =========================================

    final compatible = score >= 60;

    return MatchResult(
      compatible: compatible,
      score: score,
    );
  }
}

extension LocalityExtension on Locality {
  String get name {
    return localityGraph[this]?.displayName ?? toString().split('.').last;
  }
}