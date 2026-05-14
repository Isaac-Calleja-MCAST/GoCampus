import 'package:flutter/material.dart';
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
  // 1. DEFAULT STATE
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default to Tomorrow
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);       // Default to 8:00 AM
  
  Locality? _selectedOrigin;
  String? _selectedDestination;

  @override
  void initState() {
    super.initState();
    // 2. AUTO-FILL LOGIC: Pull preferences from the User Session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _selectedOrigin = user.homeTown;
        _selectedDestination = user.targetCollege;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    final userProvider = Provider.of<UserProvider>(context);
    final isGozo = userProvider.selectedRegion == Region.gozo;
    final towns = isGozo ? gozoLocalities : maltaLocalities;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Ride"),
        backgroundColor: indigoBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Commute Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("We've pre-filled this based on your profile.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 25),

            // PICKUP LOCALITY
            _sectionLabel("Departing From:"),
            DropdownButtonFormField<Locality>(
              initialValue: _selectedOrigin,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)),
              items: towns.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (val) => setState(() => _selectedOrigin = val),
            ),
            const SizedBox(height: 20),

            // DESTINATION COLLEGE
            _sectionLabel("Going To:"),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestination,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.school)),
              items: campusDestinations.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedDestination = val),
            ),
            const SizedBox(height: 20),

            // DATE PICKER
            _sectionLabel("Departure Date:"),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(DateFormat('EEEE, MMM d').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_month, color: indigoBlue),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 7)),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 15),

            // TIME PICKER
            _sectionLabel("Lecture Start Time:"),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time, color: indigoBlue),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                if (picked != null) setState(() => _selectedTime = picked);
              },
            ),

            const SizedBox(height: 40),

            // SEARCH BUTTON
            ElevatedButton(
              onPressed: (_selectedOrigin != null && _selectedDestination != null) 
                ? _handleSearch 
                : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: indigoBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Search for Matches", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  void _handleSearch() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    
    // Combine Date & Time
    final targetTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    // Convert UI string to Enum
    final destinationEnum = campusMap[_selectedDestination!]!;

    rideProvider.joinOrCreatePool(
      email: userProvider.userEmail ?? "student@mcast.edu.mt",
      origin: _selectedOrigin!,
      destination: destinationEnum,
      time: targetTime,
      region: userProvider.selectedRegion,
    );

    Navigator.pop(context);
  }
}