import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/user_provider.dart';
import 'providers/ride_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Start Hive
  await Hive.initFlutter();
  
  // 3. Create the Providers
  final userProvider = UserProvider();
  final rideProvider = RideProvider();

  // 4. Initialize Data (WAIT for it to finish)
  await userProvider.loadSession();
  await rideProvider.loadPools();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: rideProvider),
      ],
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3F51B5)),
      ),
      // THE GATE: This prevents the black screen
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // We listen to the userEmail to decide where to go
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.isLoggedIn) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}