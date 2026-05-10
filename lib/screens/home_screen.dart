import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart'; // Needed for .name extension
import 'find_pool_screen.dart';
import 'pool_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // BEST PRACTICE: Define brand colors here so we don't have to re-type them
  static const Color indigoBlue = Color(0xFF3F51B5);
  static const Color islandGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    // 1. Get our "Brains" (Providers)
    final userProvider = Provider.of<UserProvider>(context);
    final rideProvider = Provider.of<RideProvider>(context);
    final String currentUserEmail = userProvider.userEmail ?? "";

    // 2. Logic Check: Does this student already have an active ride?
    final activePool = rideProvider.getActivePoolForUser(currentUserEmail);

    return Scaffold(
      appBar: AppBar(
        title: const Text("GoCampus Dashboard"),
        backgroundColor: indigoBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => userProvider.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // A. THE REGION TOGGLE (Always visible at the top)
          _buildRegionToggle(context, userProvider),

          // B. THE DYNAMIC CONTENT AREA
          Expanded(
            child: activePool != null
                ? _buildActiveRideDashboard(context, activePool) // USER IS IN A RIDE
                : _buildDiscoveryFeed(context, rideProvider, userProvider), // USER IS SEARCHING
          ),
        ],
      ),
      // C. THE FLOATING ACTION BUTTON
      // We only show the "Find Pool" button if the user IS NOT already in one
      floatingActionButton: activePool == null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FindPoolScreen()),
              ),
              label: const Text("Find Pool", style: TextStyle(color: Colors.white)),
              icon: const Icon(Icons.search, color: Colors.white),
              backgroundColor: indigoBlue,
            )
          : null,
    );
  }

  // --- UI HELPER METHODS (Keeps the code clean and readable) ---

  Widget _buildRegionToggle(BuildContext context, UserProvider userProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SegmentedButton<Region>(
        segments: const [
          ButtonSegment(value: Region.malta, label: Text('Malta'), icon: Text("🇲🇹")),
          ButtonSegment(value: Region.gozo, label: Text('Gozo'), icon: Text("⛴️")),
        ],
        selected: {userProvider.selectedRegion},
        onSelectionChanged: (Set<Region> newSelection) {
          userProvider.setRegion(newSelection.first);
        },
      ),
    );
  }

  Widget _buildActiveRideDashboard(BuildContext context, CarpoolPool pool) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 100, color: indigoBlue),
          const SizedBox(height: 24),
          const Text(
            "You have an active carpool!",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Departure: ${DateFormat('E, MMM d - h:mm a').format(pool.lectureTime)}",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 30),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(20),
              title: Text(
                "${pool.originLocality.name} to ${pool.destination.name}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text("Current Status: ${pool.status.name.toUpperCase()}"),
              trailing: const Icon(Icons.arrow_forward_ios, color: indigoBlue),
              onTap: () {  
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoolDetailScreen(pool: pool)),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Tap the card above to manage your pickup address or see your fellow passengers.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryFeed(BuildContext context, RideProvider rideProvider, UserProvider userProvider) {
    // Only show pools that match the student's selected region
    final filteredPools = rideProvider.allPools
        .where((p) => p.region == userProvider.selectedRegion)
        .toList();

    if (filteredPools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.car_repair_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No pools found in ${userProvider.selectedRegion == Region.malta ? 'Malta' : 'Gozo'}.",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const Text("Be the first to start one!"),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: filteredPools.length,
      itemBuilder: (context, index) {
        final pool = filteredPools[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => PoolDetailScreen(pool: pool)),
              );
            },
            leading: CircleAvatar(
              backgroundColor: indigoBlue.withValues(alpha: 0.1),
              child: const Icon(Icons.group, color: indigoBlue),
            ),
            title: Text("${pool.originLocality.name} ➔ ${pool.destination.name}"),
            subtitle: Text(
              "Lecture: ${DateFormat('E, MMM d – h:mm a').format(pool.lectureTime)}",
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "€${pool.pricePerStudent.toStringAsFixed(2)}",
                  style: const TextStyle(color: islandGreen, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: islandGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Save €${pool.savings.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 9, color: islandGreen),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}