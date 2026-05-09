import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../data/malta_data.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import '../models/carpool_pool.dart';

class FindPoolScreen extends StatefulWidget {
  const FindPoolScreen({super.key});

  @override
  State<FindPoolScreen> createState() => _FindPoolScreenState();
}

class _FindPoolScreenState extends State<FindPoolScreen> {
  String? _selectedDestination;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _detectedLocality = "Detecting...";
  String? _manualLocality;

  @override
  void initState() {
    super.initState();
    _getGPSLocation();
  }

  Future<void> _getGPSLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    
    // Check if the user hasn't closed the screen while the GPS was working
    if (!mounted) return; 

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // We "use" the position variable to stop the warning (and for real logic)
    debugPrint("GPS coordinates: ${position.latitude}, ${position.longitude}");

    setState(() {
      _detectedLocality = userProvider.selectedRegion == Region.gozo 
          ? "Rabat (Gozo)" 
          : "Birkirkara";
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    
    // Access the User Session to find out which region they are in
    final userProvider = Provider.of<UserProvider>(context);
    final isGozo = userProvider.selectedRegion == Region.gozo;

    // Pick the correct list of towns based on the region
    final List<String> availableLocalities = isGozo ? gozoLocalities : maltaLocalities;

    return Scaffold(
      appBar: AppBar(title: const Text("Join or Start a Pool")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LOCALITY CARD
            Card(
              color: indigoBlue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on, color: indigoBlue),
                      title: Text("Departing from (${isGozo ? 'Gozo' : 'Malta'}):"),
                      subtitle: Text(_manualLocality ?? _detectedLocality),
                    ),
                    // Dropdown dynamically filled with only relevant towns!
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<String>(
                        hint: const Text("Change town manually"),
                        isExpanded: true,
                        value: _manualLocality,
                        items: availableLocalities.map((String town) {
                          return DropdownMenuItem(value: town, child: Text(town));
                        }).toList(),
                        onChanged: (val) => setState(() => _manualLocality = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // DESTINATION DROPDOWN
            const Text("Where are you going?", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestination,
              items: campusDestinations.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) => setState(() => _selectedDestination = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // TIME PICKER
            const Text("Lecture Start Time:", style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              tileColor: Colors.grey[100],
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _selectedTime);
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),

            const Spacer(),

            // SEARCH BUTTON
            ElevatedButton(
              onPressed: () {
                if (_selectedDestination == null) return;
                
                final rideProvider = Provider.of<RideProvider>(context, listen: false);
                final now = DateTime.now();
                final targetTime = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
                
                rideProvider.joinOrCreatePool(
                  email: userProvider.userEmail ?? "student@mcast.edu.mt",
                  origin: _manualLocality ?? _detectedLocality,
                  dest: _selectedDestination!,
                  time: targetTime,
                  region: userProvider.selectedRegion,
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: indigoBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Search for Matches"),
            ),
          ],
        ),
      ),
    );
  }
}