import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  // THE VALIDATOR LOGIC
  void _tryLogin() {
    if (_formKey.currentState!.validate()) {
      // If the email is valid, move to the next screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification Successful')),
      );
      // We will add navigation here later
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.school, size: 80, color: Color(0xFF3F51B5)),
                const SizedBox(height: 10),
                const Text(
                  "GoCampus",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
                ),
                const SizedBox(height: 30),
                
                // EMAIL FIELD
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "College Email",
                    hintText: "example@mcast.edu.mt",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  // THE BRAINS: Checking for .edu.mt
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.endsWith('@mcast.edu.mt') && !value.endsWith('@um.edu.mt')) {
                      return 'Only @mcast.edu.mt or @um.edu.mt allowed';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _tryLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Verify & Enter"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}