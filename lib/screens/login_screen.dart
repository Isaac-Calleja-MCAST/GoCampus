import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/user_provider.dart';
import '../models/carpool_pool.dart';
import '../data/route_logic.dart';
import '../data/malta_data.dart';
import '../services/student_email_validator.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final Color indigoBlue = const Color(0xFF3F51B5);
  final _emailController = TextEditingController();

  // Temporary state for the setup flow
  Region _selectedRegion = Region.malta;
  Locality? _selectedTown;
  String? _selectedCollege;
  String? _firstName;
  String? _lastName;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              SvgPicture.asset(
                'assets/images/logo.svg',
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              const Text(
                "Share the ride. Save more.",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 50),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: "Student Email",
                  hintText: "name@university.edu",
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                ),
                onSubmitted: (_) => _handleTypedEmailLogin(context),
              ),
              const SizedBox(height: 12),
              _loginButton(
                label: "Continue with Student Email",
                icon: Icons.school_outlined,
                color: indigoBlue,
                onTap: () => _handleTypedEmailLogin(context),
              ),
              const SizedBox(height: 15),

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
                  _debugButton(context, "Kelly", "kelly@mcast.edu.mt"),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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

  void _handleTypedEmailLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final error = StudentEmailValidator.errorMessage(email);
    setState(() => _emailError = error);
    if (error == null) {
      _handleSmartLogin(context, email);
    }
  }

  void _handleSmartLogin(BuildContext context, String email) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Existing profile preferences keep the demo login flow quick.
    if (userProvider.homeTown != null &&
        userProvider.targetCollege != null &&
        userProvider.firstName != null &&
        userProvider.lastName != null) {
      await userProvider.login(
        email,
        town: userProvider.homeTown,
        college: userProvider.targetCollege,
      );
    } else {
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

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              25,
              25,
              25,
              MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Complete your Profile", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Text("This helps us find rides for you automatically."),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "First Name",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setSheetState(() {
                          _firstName = value.trim();
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: "Surname",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => setSheetState(() {
                          _lastName = value.trim();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 1. Region Toggle
                const Text("Where are you based?", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SegmentedButton<Region>(
                  segments: const [
                    ButtonSegment(
                      value: Region.malta,
                      label: Text("Malta"),
                      icon: Icon(Icons.location_on_outlined),
                    ),
                    ButtonSegment(
                      value: Region.gozo,
                      label: Text("Gozo"),
                      icon: Icon(Icons.directions_boat_outlined),
                    ),
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
                  onPressed: (_selectedTown != null &&
                          _selectedCollege != null &&
                          (_firstName?.isNotEmpty ?? false) &&
                          (_lastName?.isNotEmpty ?? false))
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
      college: _selectedCollege,
      firstName: _firstName,
      lastName: _lastName,
    );
  }
}
