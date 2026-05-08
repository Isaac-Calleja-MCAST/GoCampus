import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/ride_provider.dart';
import 'screens/login_screen.dart';

void main() async {
  // Ensure Flutter is initialized for Hive
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  runApp(
    ChangeNotifierProvider(
      create: (context) => RideProvider(),
      child: const GoCampusApp(),
    ),
  );
}

class GoCampusApp extends StatelessWidget {
  const GoCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoCampus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Using your brand colors from the docs
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F51B5), // Indigo Blue
          primary: const Color(0xFF3F51B5),
          secondary: const Color(0xFF2E7D32), // Island Green
        ),
      ),
      home: const LoginScreen(), // We will build this next
    );
  }
}