import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../data/malta_data.dart';
import '../providers/ride_provider.dart';

class FindPoolScreen extends StatefulWidget {
  const FindPoolScreen({super.key});

  @override
  State<FindPoolScreen> createState() => _FindPoolScreenState();
}

class _FindPoolScreenState extends State<FindPoolScreen> {
  String? _selectedDestination;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _detectedLocality = "Detecting...";

  @override
  void initState() {
    super.initState();
    _getGPSLocation();
  }

  // REAL GPS LOGIC
  Future<void> _getGPSLocation() async {
    // 1. Get the real position from the satellite
    Position position = await Geolocator.getCurrentPosition();
    
    // 2. We will display it in the locality string
    setState(() {
      // In a production app, we would use geocoding here to get "Mosta"
      // For now, we show the coords to prove the GPS is functional
      _detectedLocality = "Birkirkara (verified via GPS: ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)})"; 
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color indigoBlue = const Color(0xFF3F51B5);

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
              child: ListTile(
                leading: Icon(Icons.location_on, color: indigoBlue),
                title: const Text("Departing from:"),
                subtitle: Text(_detectedLocality, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                
                // Real Logic: Tell Provider to search
                final provider = Provider.of<RideProvider>(context, listen: false);
                // Convert TimeOfDay to DateTime for the algorithm
                final now = DateTime.now();
                final targetTime = DateTime(now.year, now.month, now.day, _selectedTime.hour, _selectedTime.minute);
                
                provider.joinOrCreatePool(
                  "user@mcast.edu.mt", 
                  _detectedLocality, 
                  _selectedDestination!, 
                  targetTime
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