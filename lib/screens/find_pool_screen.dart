import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FindPoolScreen extends StatefulWidget {
  const FindPoolScreen({super.key});

  @override
  State<FindPoolScreen> createState() => _FindPoolScreenState();
}

class _FindPoolScreenState extends State<FindPoolScreen> {
  String _currentLocality = "Detecting location...";

  // R&U3: Using GPS API
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    // In a real app, we'd use Geocoding to turn coords into "Qormi"
    // For the assignment, we will display the coordinates to prove it works
    setState(() {
      _currentLocality = "Lat: ${position.latitude.toStringAsFixed(2)}, Lng: ${position.longitude.toStringAsFixed(2)}";
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Find a Pool")),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.my_location, color: Color(0xFF3F51B5)),
            title: const Text("Your Current Locality"),
            subtitle: Text(_currentLocality),
          ),
          // We will add Time Selection and Destination Selection here next
        ],
      ),
    );
  }
}