import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/user_provider.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart';
import '../data/malta_data.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color indigoBlue = const Color(0xFF3F51B5);

  // Temporary state for the setup flow
  Region _selectedRegion = Region.malta;
  Locality? _selectedTown;
  String? _selectedCollege;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
  'assets/images/logo.svg',
  height: 180,
  fit: BoxFit.contain,
),
              const SizedBox(height: 10),
              Text("", // Placeholder for tagline, can be updated later
                style: TextStyle(fontSize: 5, fontWeight: FontWeight.bold, color: indigoBlue)),
              const SizedBox(height: 10),
              Text("Share the ride. Save more.", 
                style: TextStyle(fontSize: 20),),
              const SizedBox(height: 50),

              _loginButton(
                label: "MCAST Login",
                icon: Icons.grid_view_rounded,
                color: Colors.black87,
                onTap: () => _handleSmartLogin(context, "student@mcast.edu.mt"),
              ),
              const SizedBox(height: 15),

              _loginButton(
                label: "UoM Login",
                icon: Icons.account_circle,
                color: Colors.redAccent,
                onTap: () => _handleSmartLogin(context, "student@um.edu.mt"),
              ),
              
              const Divider(height: 60),
              const Text("DEBUG ACCESS", 
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),

              // Using Wrap instead of Row to prevent buttons from cutting off
              Wrap(
                spacing: 10, // horizontal gap
                runSpacing: 10, // vertical gap
                alignment: WrapAlignment.center,
                children: [
                  _debugButton(context, "Isaac", "isaac@mcast.edu.mt"),
                  _debugButton(context, "Kayel", "kayel@mcast.edu.mt"),
                  _debugButton(context, "Kyra", "kyra@mcast.edu.mt"),
                  _debugButton(context, "Andrene", "andrene@mcast.edu.mt"),
                  _debugButton(context, "Nathan", "nathan@mcast.edu.mt"),
                  _debugButton(context, "Gabriel", "gabriel@mcast.edu.mt"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loginButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: color),
        label: Text(label, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Widget _debugButton(BuildContext context, String name, String email) {
  return ElevatedButton(
    onPressed: () => _handleSmartLogin(context, email),
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange[50],
      foregroundColor: Colors.orange[900],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    child: Text(name),
  );
}

  void _handleSmartLogin(BuildContext context, String email) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  // 1. Check if we already have the town and college in Hive/Provider
  if (userProvider.homeTown != null && userProvider.targetCollege != null) {
    // 2. SEAMLESS: Just log in and go straight to the Dashboard
    await userProvider.login(email, town: userProvider.homeTown, college: userProvider.targetCollege);
  } else {
    // 3. FIRST TIME: Show the setup drawer
    _startSetup(context, email);
  }
}

  // THE SEAMLESS SETUP FLOW
  void _startSetup(BuildContext context, String email) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder( // Allows us to update the sheet UI
        builder: (ctx, setSheetState) {
          final towns = _selectedRegion == Region.gozo ? gozoLocalities : maltaLocalities;

          return Container(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Complete your Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text("This helps us find rides for you automatically."),
                const SizedBox(height: 25),

                // 1. Region Toggle
                const Text("Where are you based?", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SegmentedButton<Region>(
                  segments: const [
                    ButtonSegment(value: Region.malta, label: Text("Malta"), icon: Text("🇲🇹")),
                    ButtonSegment(value: Region.gozo, label: Text("Gozo"), icon: Text("⛴️")),
                  ],
                  selected: {_selectedRegion},
                  onSelectionChanged: (val) => setSheetState(() {
                    _selectedRegion = val.first;
                    _selectedTown = null; // Reset town if region changes
                  }),
                ),
                const SizedBox(height: 20),

                // 2. Town Picker
                DropdownButtonFormField<Locality>(
                  initialValue: _selectedTown,
                  decoration: const InputDecoration(labelText: "Home Town", border: OutlineInputBorder()),
                  items: towns.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setSheetState(() => _selectedTown = val),
                ),
                const SizedBox(height: 20),

                // 3. College Picker
                DropdownButtonFormField<String>(
                  initialValue: _selectedCollege,
                  decoration: const InputDecoration(labelText: "Destination College", border: OutlineInputBorder()),
                  items: campusDestinations.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setSheetState(() => _selectedCollege = val),
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: (_selectedTown != null && _selectedCollege != null) 
                    ? () => _finishLogin(context, email) 
                    : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(55),
                    backgroundColor: indigoBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Start Commuting"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _finishLogin(BuildContext context, String email) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // 1. Close the BottomSheet first (while the LoginScreen context is still active)
    Navigator.of(context).pop(); 

    // 2. Perform the logic (This triggers the AuthGate to show HomeScreen)
    await userProvider.setRegion(_selectedRegion);
    await userProvider.login(
      email, 
      town: _selectedTown, 
      college: _selectedCollege
    );
  }
}