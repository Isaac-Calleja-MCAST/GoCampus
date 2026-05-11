// ================================================================
// LOCALITIES ENUM
// Perfectly synced with your malta_data list.
// ================================================================
enum Locality {
  attard, balzan, birgu, birkirkara, birzebbuga, cospicua, dingli, 
  fgura, floriana, gharghur, ghaxaq, gudja, gzira, hamrun, iklin, 
  kalkara, kirkop, lija, luqa, marsa, marsaskala, marsaxlokk, mdina, 
  mellieha, mgarr, mosta, mqabba, msida, mtarfa, naxxar, paola, 
  pembroke, pieta, qormi, qrendi, rabat, safi, sanGiljan, sanGwann, 
  stPaulsBay, santaLucija, santaVenera, senglea, siggiewi, sliema, 
  swieqi, taXbiex, tarxien, valletta, xghajra, zabbar, zebbug, 
  zejtun, zurrieq, 
  // Gozo
  fontana, ghajnsielem, gharb, ghasri, kercem, munxar, nadur, 
  qala, sanLawrenz, sannat, victoria, xaghra, xewkija, zebbugGozo
}

enum RouteZone { harbour, central, centralSouth, centralNorth, north, southHarbour, south, west, gozo }

class LocalityNode {
  final Locality locality;
  final String displayName;
  final RouteZone zone;
  final List<Locality> connected; // Matches your class

  const LocalityNode({
    required this.locality,
    required this.displayName,
    required this.zone,
    this.connected = const [],
  });
}

// ================================================================
// THE MASTER GRAPH
// ================================================================
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

// ================================================================
// MATCHING ENGINE & EXTENSION
// ================================================================
class MatchResult {
  final bool compatible;
  final int score;
  const MatchResult({required this.compatible, required this.score});
}

// ================================================================
// MATCHING ENGINE 
// ================================================================
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

    // 1. Destination Match (MANDATORY)
    if (userDestination == poolDestination) {
      score += 40;
    } else {
      return const MatchResult(compatible: false, score: 0);
    }

    // 2. Exact Origin Match
    if (userOrigin == poolOrigin) {
      score += 30;
    } 
    // 3. Connected/Adjacency Match
    else if (localityGraph[userOrigin]?.connected.contains(poolOrigin) ?? false) {
      score += 20;
    } 
    // 4. Same Zone Fallback
    else {
      final userZone = localityGraph[userOrigin]?.zone;
      final poolZone = localityGraph[poolOrigin]?.zone;
      if (userZone != null && userZone == poolZone) {
        score += 10;
      }
    }

    // 5. Time Window Matching
    final minuteDiff = userDepartureTime.difference(poolDepartureTime).inMinutes.abs();
    if (minuteDiff <= 15) {
      score += 20;
    } else if (minuteDiff <= 30) {
      score += 10;
    }

    return MatchResult(compatible: score >= 60, score: score);
  }
}

extension LocalityExtension on Locality {
  String get name {
    if (localityGraph.containsKey(this)) return localityGraph[this]!.displayName;
    String raw = toString().split('.').last;
    return raw.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').replaceFirst(raw[0], raw[0].toUpperCase());
  }
}