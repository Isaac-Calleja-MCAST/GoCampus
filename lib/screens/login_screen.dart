import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/carpool_pool.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color indigoBlue = const Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_rounded, size: 100, color: indigoBlue),
              const SizedBox(height: 20),
              const Text(
                "GoCampus",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const Text("Share the ride. Save more."),
              const SizedBox(height: 50),

              // MICROSOFT SSO (MCAST)
              _loginButton(
                label: "MCAST Login (Microsoft)",
                icon: Icons.grid_view_rounded,
                color: Colors.black87,
                onTap: () => _showRegionPicker(context, "student@mcast.edu.mt"),
              ),
              const SizedBox(height: 15),

              // GOOGLE SSO (UoM)
              _loginButton(
                label: "UoM Login (Google)",
                icon: Icons.account_circle,
                color: Colors.redAccent,
                onTap: () => _showRegionPicker(context, "student@um.edu.mt"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for UI buttons
  Widget _loginButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // REGION PICKER: Ask the user where they are based upon first login
  void _showRegionPicker(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isDismissible: false, // Force them to pick
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select your Region",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Text("🇲🇹", style: TextStyle(fontSize: 24)),
              title: const Text("Malta"),
              onTap: () {
                Navigator.pop(ctx);
                _completeLogin(context, email, Region.malta);
              },
            ),
            ListTile(
              leading: const Text("⛴️", style: TextStyle(fontSize: 24)),
              title: const Text("Gozo"),
              onTap: () {
                Navigator.pop(ctx);
                _completeLogin(context, email, Region.gozo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _completeLogin(BuildContext context, String email, Region region) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Set region first
    await userProvider.setRegion(region);
    // Then log in (this triggers the Auth Gate in main.dart)
    await userProvider.login(email);

    if (context.mounted) Navigator.pop(context); // Close the bottom sheet
  }
}
