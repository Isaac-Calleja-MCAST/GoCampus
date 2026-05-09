import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Brand Colors
  final Color indigoBlue = const Color(0xFF3F51B5);
  final Color islandGreen = const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. BRAND LOGO (Matches your docs Page 16)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: indigoBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.school_rounded, size: 80, color: indigoBlue),
              ),
              const SizedBox(height: 24),
              Text(
                "GoCampus",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: indigoBlue,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                "Share the ride. Save more.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 60),

              // 2. MICROSOFT LOGIN (MCAST)
              _socialButton(
                label: "MCAST Login",
                icon: Icons.grid_view_rounded, // Microsoft-style icon
                color: Colors.black87,
                onTap: () => _handleLogin("mcast.edu.mt"),
              ),
              const SizedBox(height: 16),

              // 3. GOOGLE LOGIN (UoM)
              _socialButton(
                label: "UoM Login",
                icon: Icons.account_circle, 
                color: Colors.redAccent,
                onTap: () => _handleLogin("um.edu.mt"),
              ),
              
              const SizedBox(height: 40),
              const Text(
                "Verified Student Access Only",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A helper function to create consistent social buttons
  Widget _socialButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _handleLogin(String domain) async {
    final email = "student@$domain"; 
    await Provider.of<UserProvider>(context, listen: false).login(email);
  }
}