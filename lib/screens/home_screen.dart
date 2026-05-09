import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/ride_provider.dart';
import 'find_pool_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    const Color islandGreen = Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(
        title: const Text("GoCampus Pools"),
        backgroundColor: indigoBlue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, child) {
          if (rideProvider.activePools.isEmpty) {
            return const Center(child: Text("No pools found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rideProvider.activePools.length,
            itemBuilder: (context, index) {
              final pool = rideProvider.activePools[index];
              
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    // Fixed deprecated withOpacity
                    backgroundColor: indigoBlue.withValues(alpha: 0.1),
                    child: const Icon(Icons.group, color: indigoBlue),
                  ),
                  title: Text("${pool.originLocality} ➔ ${pool.destination}"),
                  subtitle: Text("Lecture: ${DateFormat('jm').format(pool.lectureTime)}"),
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
        },
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