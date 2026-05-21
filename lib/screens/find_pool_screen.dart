import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../data/malta_data.dart';
import '../data/route_logic.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import '../models/carpool_pool.dart';
import '../models/trip_category.dart';

enum RideDirection { fromTown, toTown }

class FindPoolScreen extends StatefulWidget {
  const FindPoolScreen({
    super.key,
    this.initialDestinationName,
    this.initialCategory = TripCategory.campusCommute,
  });

  final String? initialDestinationName;
  final TripCategory initialCategory;

  @override
  State<FindPoolScreen> createState() => _FindPoolScreenState();
}

class _FindPoolScreenState extends State<FindPoolScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  late TimeOfDay _selectedTime;
  late TripCategory _selectedCategory;

  RideDirection _selectedDirection = RideDirection.fromTown;
  Locality? _selectedTown;
  String? _selectedDestinationName;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedDestinationName = widget.initialDestinationName;
    _selectedTime = TimeOfDay(hour: _selectedCategory.defaultHour, minute: 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Provider.of<UserProvider>(context, listen: false);
      setState(() {
        _selectedTown = user.homeTown;
        if (_selectedCategory == TripCategory.campusCommute) {
          _selectedDestinationName ??= user.targetCollege;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    final userProvider = Provider.of<UserProvider>(context);
    final isGozo = userProvider.selectedRegion == Region.gozo;
    final towns = isGozo ? gozoLocalities : maltaLocalities;
    final destinations = destinationsForCategory(_selectedCategory);
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
            const Text("Trip Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Use academic routes or switch into seasonal student travel.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 25),

            _sectionLabel("Travel Category:"),
            DropdownButtonFormField<TripCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.explore_outlined),
              ),
              items: TripCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
              onChanged: (category) {
                if (category == null) return;
                setState(() {
                  _selectedCategory = category;
                  _selectedDestinationName = null;
                  _selectedTime = TimeOfDay(hour: category.defaultHour, minute: 0);
                });
              },
            ),
            const SizedBox(height: 20),

            _sectionLabel("Route Direction:"),
            SegmentedButton<RideDirection>(
              segments: [
                ButtonSegment(
                  value: RideDirection.fromTown,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(_routeLabel(fromTown: true)),
                ),
                ButtonSegment(
                  value: RideDirection.toTown,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(_routeLabel(fromTown: false)),
                ),
              ],
              selected: {_selectedDirection},
              onSelectionChanged: (selection) {
                setState(() => _selectedDirection = selection.first);
              },
            ),
            const SizedBox(height: 20),

            _sectionLabel(
              _selectedDirection == RideDirection.fromTown
                  ? 'Departing Town:'
                  : 'Returning To Town:',
            ),
            DropdownButtonFormField<Locality>(
              initialValue: _selectedTown,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.home)),
              items: towns.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (val) => setState(() => _selectedTown = val),
            ),
            const SizedBox(height: 20),

            _sectionLabel(
              _selectedDirection == RideDirection.fromTown
                  ? 'Going To:'
                  : 'Departing From:',
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestinationName,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.place_outlined)),
              items: destinations
                  .map(
                    (destination) => DropdownMenuItem(
                      value: destination.name,
                      child: Text(destination.name),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedDestinationName = val),
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
                if (picked != null && mounted) {
                  setState(() => _selectedDate = picked);
                }
              },
            ),
            const SizedBox(height: 15),

            // TIME PICKER
            _sectionLabel('${_selectedCategory.timePrompt}:'),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time, color: indigoBlue),
              onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: _selectedTime);
                if (picked != null && mounted) {
                  setState(() => _selectedTime = picked);
                }
              },
            ),

            const SizedBox(height: 40),

            // SEARCH BUTTON
            ElevatedButton(
              onPressed: (_selectedTown != null && _selectedDestinationName != null)
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

  String _routeLabel({required bool fromTown}) {
    if (_selectedCategory == TripCategory.campusCommute) {
      return fromTown ? 'Town to Campus' : 'Campus to Town';
    }
    return fromTown ? 'Town to Spot' : 'Spot to Town';
  }

  void _handleSearch() {
    // 1. Combine Date and Time
    final targetTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // 2. Principle #22: Validation Gate
    if (targetTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Departure cannot be in the past."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return; // Stop the search
    }

    // 3. Continue with normal search logic
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final studentDestination = findStudentDestination(_selectedDestinationName!);
    if (studentDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a destination before continuing.')),
      );
      return;
    }

    final origin = _selectedDirection == RideDirection.fromTown
        ? _selectedTown!
        : studentDestination.locality;
    final destination = _selectedDirection == RideDirection.fromTown
        ? studentDestination.locality
        : _selectedTown!;

    rideProvider.joinOrCreatePool(
      email: userProvider.userEmail ?? "student@mcast.edu.mt",
      displayName: userProvider.displayName,
      origin: origin,
      destination: destination,
      time: targetTime,
      region: userProvider.selectedRegion,
      tripCategory: _selectedCategory,
    );

    Navigator.pop(context);
  }
}
