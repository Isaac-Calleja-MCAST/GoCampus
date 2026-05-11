import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Returns true if the address exists on a real map
  static Future<bool> isAddressValid(String address, String town) async {
    try {
      // We append "Malta" to ensure the search stays local
      String fullQuery = "$address, $town, Malta";
      
      // This attempt to find coordinates for the text
      List<Location> locations = await locationFromAddress(fullQuery);
      
      // If it found a coordinate, the address is "real"
      return locations.isNotEmpty;
    } catch (e) {
      // If geocoding fails, it's likely an invented/unrecognizable address
      return false;
    }
  }
}