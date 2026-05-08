// lib/screens/login_screen.dart
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Placeholder (We'll add the actual logo later)
              const Icon(Icons.directions_car, size: 100, color: Color(0xFF3F51B5)),
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Logic for login will go here
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: const Color(0xFF3F51B5),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Student Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}