import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/user_provider.dart';
import 'providers/ride_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // 1. Create the provider first
  final userProvider = UserProvider();
  
  // 2. WAIT for the session to load BEFORE running the app
  await userProvider.loadSession();
  
  runApp(
    MultiProvider(
      providers: [
        // 3. Use .value because we already initialized it above
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => RideProvider()),
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
      // THE GATE: This builder runs EVERY time UserProvider changes
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoggedIn) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}