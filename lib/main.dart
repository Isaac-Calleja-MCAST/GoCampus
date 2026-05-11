import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'providers/user_provider.dart';
import 'providers/ride_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings);

  final userProvider = UserProvider();
  final rideProvider = RideProvider();

  // Load everything BEFORE the app starts to prevent flickering/black screens
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
      // THE FIX: The AuthGate handles the logic internally
      home: const AuthGate(), 
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget REBUILDS automatically the instant isLoggedIn changes
    final isLoggedIn = context.watch<UserProvider>().isLoggedIn;

    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}