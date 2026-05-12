import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/carpool_pool.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import '../data/malta_data.dart';
import '../services/location_service.dart';

class PoolDetailScreen extends StatefulWidget {
  final CarpoolPool pool;
  const PoolDetailScreen({super.key, required this.pool});

  @override
  State<PoolDetailScreen> createState() => _PoolDetailScreenState();
}

class _PoolDetailScreenState extends State<PoolDetailScreen> {
  final _addrController = TextEditingController();
  static const Color indigoBlue = Color(0xFF3F51B5);
  static const Color islandGreen = Color(0xFF2E7D32);

  Future<void> _payViaRevolut(double amount) async {
    final url = Uri.parse("https://revolut.me/pay/GOCAMPUS?amount=$amount");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<UserProvider>(context).userEmail ?? "";

    return Consumer<RideProvider>(
      builder: (context, provider, _) {
        CarpoolPool pool;
        try {
          pool = provider.allPools.firstWhere((p) => p.id == widget.pool.id);
          if (!pool.studentEmails.contains(userEmail)) throw Exception();
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) Navigator.pop(context); });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final isLead = pool.leadStudentEmail == userEmail;

        return Scaffold(
          appBar: AppBar(title: const Text("Pool Details"), backgroundColor: indigoBlue, foregroundColor: Colors.white),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLead) _buildBanner("⭐ You are the Lead Student."),
                Text("Ride to ${getCampusDisplayName(pool.destination)}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: indigoBlue)),
                Text("From ${pool.originLocality.name} at ${DateFormat('h:mm a').format(pool.lectureTime)}"),
                const SizedBox(height: 10),
                Chip(label: Text(pool.status.name.toUpperCase()), backgroundColor: indigoBlue.withValues(alpha: 0.1)),
                const Divider(height: 40),
                ...pool.studentEmails.map((e) => ListTile(
                  leading: Icon(pool.studentAddresses.containsKey(e) ? Icons.check_circle : Icons.person_outline, color: islandGreen),
                  title: Text(e),
                )),
                const SizedBox(height: 30),
                _buildActionArea(pool, userEmail, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBanner(String text) => Container(width: double.infinity, padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: indigoBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: indigoBlue.withValues(alpha: 0.5))), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));

  Widget _buildActionArea(CarpoolPool pool, String email, RideProvider provider) {
    if (pool.status == PoolStatus.recruiting) {
      return Column(children: [
        if (pool.studentEmails.length > 1 && !pool.readyToStartEmails.contains(email))
          ElevatedButton(onPressed: () => provider.voteToStartEarly(pool.id, email), child: const Text("Vouch to start early")),
        TextButton(onPressed: () => provider.leavePool(pool.id, email), child: const Text("Leave Pool", style: TextStyle(color: Colors.red))),
      ]);
    }
    if (pool.status == PoolStatus.collectingAddresses) {
      if (pool.studentAddresses.containsKey(email)) return const Center(child: Text("Waiting for others..."));
      return Column(children: [
        const Text("Enter Pickup Address:"),
        TextField(controller: _addrController, decoration: const InputDecoration(border: OutlineInputBorder())),
        ElevatedButton(onPressed: () async {
          if (await LocationService.isAddressValid(_addrController.text, pool.originLocality.name)) {
            provider.submitAddress(pool.id, email, _addrController.text);
          }
        }, child: const Text("Verify & Submit")),
      ]);
    }
    if (pool.status == PoolStatus.awaitingPayment) {
      bool paid = pool.paidStudentEmails.contains(email);
      return Column(children: [
        LinearProgressIndicator(value: pool.fundingProgress, color: islandGreen),
        const SizedBox(height: 10),
        paid ? const Text("Payment Received!") : ElevatedButton(onPressed: () { _payViaRevolut(pool.pricePerStudent); provider.processPayment(pool.id, email); }, child: const Text("Pay Share via Revolut")),
      ]);
    }
    if (pool.status == PoolStatus.booked) {
      return _buildBanner("🚗 Driver ${pool.driverName} arriving in 5 mins!\nPlate: ${pool.licensePlate}");
    }
    return const SizedBox();
  }
}