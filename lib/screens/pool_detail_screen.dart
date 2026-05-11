import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/carpool_pool.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';
import '../data/route_logic.dart';
import '../data/malta_data.dart';
import '../services/location_service.dart'; // Ensure this file exists from previous step

class PoolDetailScreen extends StatefulWidget {
  final CarpoolPool pool;
  const PoolDetailScreen({super.key, required this.pool});

  @override
  State<PoolDetailScreen> createState() => _PoolDetailScreenState();
}

class _PoolDetailScreenState extends State<PoolDetailScreen> {
  final _addressController = TextEditingController();
  
  // Define Brand Colors at class level so all methods can see them
  static const Color indigoBlue = Color(0xFF3F51B5);
  static const Color islandGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<UserProvider>(context).userEmail ?? "";

    return Consumer<RideProvider>(
      builder: (context, rideProvider, child) {
        CarpoolPool pool;
        try {
          pool = rideProvider.allPools.firstWhere((p) => p.id == widget.pool.id);
        } catch (e) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final bool isMember = pool.studentEmails.contains(userEmail);
        final bool isLead = pool.leadStudentEmail == userEmail;
        final bool hasSubmittedAddress = pool.studentAddresses.containsKey(userEmail);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Pool Status"), 
            backgroundColor: indigoBlue, 
            foregroundColor: Colors.white
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMember && isLead) _buildLeadBanner(),
                
                Text("Ride to ${getCampusDisplayName(pool.destination)}", 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: indigoBlue)),
                Text("From ${pool.originLocality.name} at ${DateFormat('h:mm a').format(pool.lectureTime)}"),
                
                const SizedBox(height: 10),
                _buildStatusBadge(pool.status),
                const Divider(height: 40),

                const Text("Passengers:", style: TextStyle(fontWeight: FontWeight.bold)),
                ...pool.studentEmails.map((email) {
                  bool addrIn = pool.studentAddresses.containsKey(email);
                  return ListTile(
                    leading: Icon(addrIn ? Icons.check_circle : Icons.person_outline, 
                                 color: addrIn ? islandGreen : Colors.grey),
                    title: Text(email),
                    subtitle: Text(addrIn ? "Address: ${pool.studentAddresses[email]}" : "Waiting for address..."),
                    trailing: email == pool.leadStudentEmail ? const Icon(Icons.stars, color: Colors.orange, size: 16) : null,
                  );
                }),

                const SizedBox(height: 30),

                isMember 
                  ? _buildMemberActionArea(pool, userEmail, hasSubmittedAddress)
                  : _buildVisitorActionArea(rideProvider, pool, userEmail),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeadBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: indigoBlue.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: indigoBlue.withValues(alpha: 0.5))
      ),
      child: const Text("⭐ You are the Lead Student. You'll confirm the booking once everyone pays.", 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(PoolStatus status) {
    return Chip(
      label: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)), 
      backgroundColor: indigoBlue
    );
  }

  Widget _buildMemberActionArea(CarpoolPool pool, String email, bool hasSubmitted) {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);

    if (pool.status == PoolStatus.recruiting) {
      return Column(
        children: [
          Text("Searching... (${pool.studentEmails.length}/4)"),
          const SizedBox(height: 10),
          if (!pool.readyToStartEmails.contains(email))
            ElevatedButton(
              onPressed: () => rideProvider.voteToStartEarly(pool.id, email), 
              child: const Text("Start carpool now (Vote)")
            ),
          TextButton(
            onPressed: () => rideProvider.leavePool(pool.id, email), 
            child: const Text("Leave Pool", style: TextStyle(color: Colors.red))
          ),
        ],
      );
    }

    if (pool.status == PoolStatus.collectingAddresses) {
      if (hasSubmitted) return const Center(child: Text("✅ Address verified. Waiting for others..."));

      return Column(
        children: [
          const Text("Enter your exact pickup address:"),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController, 
            decoration: InputDecoration(
              hintText: "12, Triq il-Forn",
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.location_searching, color: indigoBlue),
                onPressed: () async {
                  // ASYNC GAP FIX: Store navigator/messenger before await
                  final messenger = ScaffoldMessenger.of(context);
                  
                  bool isValid = await LocationService.isAddressValid(_addressController.text, pool.originLocality.name);
                  
                  if (!mounted) return; // FIX: Check if screen still exists

                  if (isValid) {
                    messenger.showSnackBar(const SnackBar(content: Text("Address Verified!"), backgroundColor: islandGreen));
                    rideProvider.submitAddress(pool.id, email, _addressController.text);
                  } else {
                    messenger.showSnackBar(const SnackBar(content: Text("Address not found. check spelling."), backgroundColor: Colors.red));
                  }
                },
              ),
            ),
          ),
        ],
      );
    }

    if (pool.status == PoolStatus.awaitingPayment) {
      return Column(
        children: [
          const Text("Ready for Payment", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {}, 
            icon: const Icon(Icons.payment), 
            label: const Text("Pay via Revolut"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(50)),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildVisitorActionArea(RideProvider provider, CarpoolPool pool, String email) {
    return ElevatedButton(
      onPressed: pool.isFull ? null : () => provider.manualJoin(pool.id, email),
      style: ElevatedButton.styleFrom(backgroundColor: indigoBlue, minimumSize: const Size.fromHeight(50)),
      child: Text(pool.isFull ? "Pool Full" : "Join this Pool", style: const TextStyle(color: Colors.white)),
    );
  }
}