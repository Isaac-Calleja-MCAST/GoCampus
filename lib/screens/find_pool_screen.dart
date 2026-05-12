// find_pool_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/malta_data.dart';
import '../data/route_logic.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
import '../models/carpool_pool.dart';

class FindPoolScreen extends StatefulWidget {
  const FindPoolScreen({super.key});

  @override
  State<FindPoolScreen> createState() => _FindPoolScreenState();
}

class _FindPoolScreenState extends State<FindPoolScreen> {
  // 1. STATE VARIABLES (Using Enums instead of Strings)
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedDestination; // Keys from campusMap
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  
  // These are now Locality Enums
  Locality _detectedLocality = Locality.valletta; 
  Locality? _manualLocality;

  @override
  void initState() {
    super.initState();
    _getGPSLocation();
  }

  Future<void> _getGPSLocation() async {
    // Attempt to get GPS coordinates
    try {
      Position position = await Geolocator.getCurrentPosition();
      debugPrint("GPS coordinates: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      debugPrint("GPS Error: $e");
    }

    if (!mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      // Logic: Set a logical default town based on their active region
      _detectedLocality = userProvider.selectedRegion == Region.gozo
          ? Locality.victoria
          : Locality.msida;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);

    // 2. Access User Session & Filter Localities
    final userProvider = Provider.of<UserProvider>(context);
    final isGozo = userProvider.selectedRegion == Region.gozo;
    
    // availableLocalities is now a List<Locality> from malta_data.dart
    final List<Locality> availableLocalities = isGozo
        ? gozoLocalities
        : maltaLocalities;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Join or Start a Pool"),
        backgroundColor: indigoBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: LOCALITY (Enum-based Dropdown) ---
            Card(
              color: indigoBlue.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.location_on, color: indigoBlue),
                      title: Text(
                        "Departing from (${isGozo ? 'Gozo' : 'Malta'}):",
                      ),
                      subtitle: Text((_manualLocality ?? _detectedLocality).name), // Uses extension
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<Locality>(
                        hint: const Text("Change town manually"),
                        isExpanded: true,
                        value: _manualLocality,
                        items: availableLocalities.map((Locality town) {
                          return DropdownMenuItem<Locality>(
                            value: town,
                            child: Text(town.name), // Uses the .name extension
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _manualLocality = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- SECTION 2: DESTINATION (Mapped to Enum via campusMap) ---
            const Text(
              "Where are you going?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestination,
              items: campusDestinations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedDestination = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            // --- SECTION 3: DATE PICKER ---
            const Text(
              "Departure Date:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_month, color: indigoBlue),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 15),

            // --- SECTION 4: TIME PICKER ---
            const Text(
              "Lecture Start Time:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time, color: indigoBlue),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),

            const Spacer(),

            // --- SECTION 5: SEARCH & SAVE (With Enum Translation) ---
            ElevatedButton(
              onPressed: () {
                if (_selectedDestination == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a destination")),
                  );
                  return;
                }

                // Translate UI String back to Locality Enum
                final Locality destinationEnum = campusMap[_selectedDestination!]!;

                final rideProvider = Provider.of<RideProvider>(context, listen: false);

                final targetDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );

                rideProvider.joinOrCreatePool(
                  email: userProvider.userEmail ?? "student@mcast.edu.mt",
                  origin: _manualLocality ?? _detectedLocality,
                  destination: destinationEnum,
                  time: targetDateTime,
                  region: userProvider.selectedRegion,
                );

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: indigoBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Search for Matches",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}