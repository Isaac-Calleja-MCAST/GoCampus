import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/carpool_pool.dart';
import '../providers/ride_provider.dart';
import '../providers/user_provider.dart';

class PoolDetailScreen extends StatefulWidget {
  final CarpoolPool pool;
  const PoolDetailScreen({super.key, required this.pool});

  @override
  State<PoolDetailScreen> createState() => _PoolDetailScreenState();
}

class _PoolDetailScreenState extends State<PoolDetailScreen> {
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color indigoBlue = Color(0xFF3F51B5);
    const Color islandGreen = Color(0xFF2E7D32);

    // Get the current user email to check their individual status
    final userEmail = Provider.of<UserProvider>(context).userEmail ?? "";
    final isLead = widget.pool.leadStudentEmail == userEmail;
    final hasSubmittedAddress = widget.pool.studentAddresses.containsKey(userEmail);

    return Scaffold(
      appBar: AppBar(title: const Text("Pool Status"), backgroundColor: indigoBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLead)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: indigoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: indigoBlue.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.stars_rounded, color: indigoBlue),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "You are the Lead Student. You will be responsible for confirming the Bolt booking once the car is full.",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            // ---
            // 1. HEADER SECTION
            Text("Ride to ${widget.pool.destination}", 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: indigoBlue)),
            Text("From ${widget.pool.originLocality} at ${DateFormat('jm').format(widget.pool.lectureTime)}"),
            const SizedBox(height: 10),
            
            // STATUS BADGE
            _buildStatusBadge(widget.pool.status),
            const Divider(height: 40),

            // 2. PASSENGERS LIST
            const Text("Passengers & Progress:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...widget.pool.studentEmails.map((email) {
              bool finished = widget.pool.studentAddresses.containsKey(email);
              return ListTile(
                leading: Icon(finished ? Icons.check_circle : Icons.radio_button_unchecked, 
                             color: finished ? islandGreen : Colors.grey),
                title: Text(email),
                subtitle: Text(finished ? "Address: ${widget.pool.studentAddresses[email]}" : "Waiting for address..."),
                trailing: email == widget.pool.leadStudentEmail 
                    ? const Chip(label: Text("Lead", style: TextStyle(fontSize: 10))) : null,
              );
            }),

            const SizedBox(height: 30),

            // 3. DYNAMIC ACTION SECTION (The "Engine" of the UI)
            _buildActionArea(context, userEmail, hasSubmittedAddress, islandGreen, indigoBlue),
          ],
        ),
      ),
    );
  }

  // UI HELPER: Status Badge
  Widget _buildStatusBadge(PoolStatus status) {
    String label;
    Color color;
    switch (status) {
      case PoolStatus.recruiting: label = "RECRUITING (Need 4)"; color = Colors.orange; break;
      case PoolStatus.collectingAddresses: label = "POOL FULL - ENTER ADDRESSES"; color = Colors.blue; break;
      case PoolStatus.awaitingPayment: label = "AWAITING PAYMENT"; color = Colors.purple; break;
      case PoolStatus.booked: label = "BOOKED & CONFIRMED"; color = Colors.green; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  // UI HELPER: Dynamic Action Area
  Widget _buildActionArea(BuildContext context, String email, bool hasSubmitted, Color green, Color indigo) {
    // PHASE 1: Recruiting
    if (widget.pool.status == PoolStatus.recruiting) {
      return Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text("Waiting for ${4 - widget.pool.studentEmails.length} more students to join..."),
          ],
        ),
      );
    }

    // PHASE 2: Collecting Addresses
    if (widget.pool.status == PoolStatus.collectingAddresses) {
      if (hasSubmitted) {
        return const Center(child: Text("✅ Your address is saved. Waiting for others."));
      }
      return Column(
        children: [
          const Text("Enter your exact pickup address for the Bolt driver:", 
                    style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "House No., Street Name"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (_addressController.text.isNotEmpty) {
                Provider.of<RideProvider>(context, listen: false)
                    .submitAddress(widget.pool.id, email, _addressController.text);
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: indigo),
            child: const Text("Submit Address", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    // PHASE 3: Awaiting Payment (The Financial Model)
    if (widget.pool.status == PoolStatus.awaitingPayment) {
      return Card(
        color: green.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text("ROUTE CONFIRMED", style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              _priceRow("Estimated Ride:", "€12.00"),
              _priceRow("Platform Fee:", "€0.50"),
              const Divider(),
              _priceRow("YOUR TOTAL:", "€${widget.pool.pricePerStudent.toStringAsFixed(2)}", isBold: true),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // In a real app: Trigger Revolut/Stripe
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Redirecting to Payment...")));
                },
                icon: const Icon(Icons.payment),
                label: const Text("Pay & Join Ride"),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50), backgroundColor: Colors.black),
              )
            ],
          ),
        ),
      );
    }

    return const SizedBox();
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
        ],
      ),
    );
  }
}