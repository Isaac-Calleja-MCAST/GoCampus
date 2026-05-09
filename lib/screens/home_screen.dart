import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart'; 
import '../models/carpool_pool.dart';
import 'find_pool_screen.dart';
import 'pool_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    const Color islandGreen = Color(0xFF2E7D32);

    // 2. Access the user session here to know if we are in Malta or Gozo mode
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("GoCampus Pools"),
        backgroundColor: indigoBlue,
        foregroundColor: Colors.white,
        actions: [
          // Logout button - good for testing session persistence!
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => userProvider.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 3. THE TOGGLE (Now talks to UserProvider)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<Region>(
              segments: const [
                ButtonSegment(
                  value: Region.malta, 
                  label: Text('Malta'), 
                  icon: Icon(Icons.map)
                ),
                ButtonSegment(
                  value: Region.gozo, 
                  label: Text('Gozo'), 
                  icon: Icon(Icons.directions_boat)
                ),
              ],
              selected: {userProvider.selectedRegion},
              onSelectionChanged: (Set<Region> newSelection) {
                // This saves the choice to Hive automatically!
                userProvider.setRegion(newSelection.first);
              },
            ),
          ),

          // 4. THE LIST (Filtered by region)
          Expanded(
            child: Consumer<RideProvider>(
              builder: (context, rideProvider, child) {
                // Only show pools that match the student's selected region
                final filteredPools = rideProvider.allPools
                    .where((p) => p.region == userProvider.selectedRegion)
                    .toList();

                if (filteredPools.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.car_crash_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No pools found in ${userProvider.selectedRegion == Region.malta ? 'Malta' : 'Gozo'}.",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
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
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PoolDetailScreen(pool: pool),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: indigoBlue.withValues(alpha: 0.1),
                          child: const Icon(Icons.group, color: indigoBlue),
                        ),
                        title: Text("${pool.originLocality} ➔ ${pool.destination}"),
                        subtitle: Text(
                          "Lecture: ${DateFormat('jm').format(pool.lectureTime)}",
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "€${pool.pricePerStudent.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: islandGreen, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: islandGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "Save €${pool.savings.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontSize: 9, 
                                  color: islandGreen
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const FindPoolScreen()),
        ),
        label: const Text("Find Pool", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.search, color: Colors.white),
        backgroundColor: indigoBlue,
      ),
    );
  }
}