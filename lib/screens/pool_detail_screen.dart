import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/carpool_pool.dart';

class PoolDetailScreen extends StatelessWidget {
  final CarpoolPool pool;

  const PoolDetailScreen({super.key, required this.pool});

  // FUNCTION TO OPEN BOLT
  Future<void> _launchBolt() async {
    // This is a "Universal Link" for Bolt. 
    // It tries to open the app; if not installed, it goes to the store.
    final Uri url = Uri.parse('https://bolt.eu/'); 
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Bolt');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    const Color islandGreen = Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(title: const Text("Pool Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ride to ${pool.destination}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: indigoBlue)),
            const SizedBox(height: 10),
            Text("Locality: ${pool.originLocality}", style: const TextStyle(fontSize: 18)),
            const Divider(height: 40),

            const Text("Passengers Joined:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Show list of student emails
            ...pool.studentEmails.map((email) => ListTile(
              leading: const Icon(Icons.verified_user, color: islandGreen),
              title: Text(email),
            )),

            const Spacer(),

            // FINANCIAL BREAKDOWN CARD
            Card(
              color: islandGreen.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Bolt Cost:"),
                        const Text("€12.00"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Your Split:"),
                        Text("€${(12 / pool.studentEmails.length).toStringAsFixed(2)}"),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("GoCampus Fee:"),
                        const Text("€0.50"),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total to Pay:", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("€${pool.pricePerStudent.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: islandGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BOLT BUTTON
            ElevatedButton.icon(
              onPressed: pool.isFull ? _launchBolt : null, // Only enable if pool is full (e.g. 4 people)
              icon: const Icon(Icons.local_taxi),
              label: Text(pool.isFull ? "Book Bolt Now" : "Waiting for more students..."),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: pool.isFull ? Colors.black : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}