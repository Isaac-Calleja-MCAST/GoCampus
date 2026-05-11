import 'route_logic.dart';

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

const Map<String, Locality> campusMap = {
  "MCAST Paola": Locality.paola,
  "MCAST Mosta": Locality.mosta,
  "MCAST Luqa": Locality.luqa,
  "MCAST Gozo": Locality.xewkija,
  "University of Malta (Msida)": Locality.msida,
  "University of Malta (Marsaxlokk)": Locality.marsaxlokk,
  "University of Malta (Gozo)": Locality.xewkija,
  "Junior College (Msida)": Locality.msida,
};

final List<String> campusDestinations = campusMap.keys.toList();

String getCampusDisplayName(Locality locality) {
  try {
    return campusMap.entries.firstWhere((e) => e.value == locality).key;
  } catch (e) {
    return locality.name;
  }
}