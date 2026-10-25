
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// For Flutter Web on this computer, the backend is available at localhost.
// For an Android emulator, change 
// to 10.0.2.2.
class CareScheduleApi {
  static const baseUrl = 'http://10.36.136.190:5000';
  static String? token;

  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

void main() {
  runApp(const CareScheduleApp());
}

class CareScheduleApp extends StatelessWidget {
  const CareScheduleApp({super.key});

  static const sage = Color(0xFF238B78);
  static const cream = Color(0xFFEAF7F2);
  static const darkGreen = Color(0xFF285747);
  static const softGreen = Color(0xFFB9E5D9);
  static const mutedText = Color(0xFF607A72);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareSchedule',
      theme: ThemeData(
        scaffoldBackgroundColor: cream,
        colorScheme: ColorScheme.fromSeed(seedColor: sage),
        appBarTheme: const AppBarTheme(
          backgroundColor: cream,
          foregroundColor: darkGreen,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 105,
                    width: 105,
                    decoration: BoxDecoration(
                      color: CareScheduleApp.softGreen,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.health_and_safety_rounded,
                      size: 62,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'CareSchedule',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your health, thoughtfully organised.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: CareScheduleApp.mutedText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7FBF8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.spa_rounded,
                          size: 36,
                          color: CareScheduleApp.sage,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'A little care goes a long way.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: CareScheduleApp.darkGreen,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Keep track of your medicines, appointments '
                          'and health in one place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: CareScheduleApp.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CareScheduleApp.sage,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Made with care ♡',
                    style: TextStyle(color: CareScheduleApp.mutedText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;
  bool rememberEmail = true;
  bool isLoadingSavedEmail = true;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('careschedule_saved_email') ?? '';
      if (!mounted) return;
      setState(() {
        emailController.text = savedEmail;
        rememberEmail = savedEmail.isNotEmpty;
        isLoadingSavedEmail = false;
      });
    } catch (_) {
      if (mounted) setState(() => isLoadingSavedEmail = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.health_and_safety_rounded,
                      size: 65,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Let’s take care of you 🌿',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: CareScheduleApp.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Log in to continue to CareSchedule.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CareScheduleApp.mutedText),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Email address'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username, AutofillHints.email],
                    enableSuggestions: true,
                    autocorrect: false,
                    decoration: _inputDecoration(
                      'Enter your email',
                      Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: _inputDecoration(
                      'Enter your password',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: rememberEmail,
                    onChanged: (value) {
                      setState(() => rememberEmail = value ?? false);
                    },
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: CareScheduleApp.sage,
                    title: const Text(
                      'Remember my email',
                      style: TextStyle(color: CareScheduleApp.darkGreen),
                    ),
                    subtitle: const Text(
                      'Your email will be filled in next time. Your password will not be stored in plain text.',
                      style: TextStyle(
                        color: CareScheduleApp.mutedText,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password recovery will be added later.'),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _primaryButton('Log In', () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your email and password.')),
                      );
                      return;
                    }
                    try {
                      final response = await http.post(
                        Uri.parse('${CareScheduleApi.baseUrl}/api/auth/login'),
                        headers: CareScheduleApi.headers,
                        body: jsonEncode({'email': email, 'password': password}),
                      );
                      final data = jsonDecode(response.body) as Map<String, dynamic>;
                      if (response.statusCode == 200 && data['token'] != null) {
                        CareScheduleApi.token = data['token'] as String;
                        final prefs = await SharedPreferences.getInstance();
                        if (rememberEmail) {
                          await prefs.setString(
                            'careschedule_saved_email',
                            email.trim(),
                          );
                        } else {
                          await prefs.remove('careschedule_saved_email');
                        }
                        if (!mounted) return;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeDashboard()));
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']?.toString() ?? 'Login failed.')));
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not connect to CareSchedule server. Make sure the backend is running.')));
                    }
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Flexible(child: Text("Don't have an account?")),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 60,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Your care journey starts here 🌱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: CareScheduleApp.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Create an account to get started.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Full name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: _inputDecoration(
                      'Enter your full name',
                      Icons.person_outline,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Email address'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      'Enter your email',
                      Icons.email_outlined,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Password'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: _inputDecoration(
                      'Create a password',
                      Icons.lock_outline,
                    ).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _primaryButton('Create Account', () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text;
                    if (name.isEmpty || email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields.')));
                      return;
                    }
                    try {
                      final response = await http.post(
                        Uri.parse('${CareScheduleApi.baseUrl}/api/auth/register'),
                        headers: CareScheduleApi.headers,
                        body: jsonEncode({'name': name, 'email': email, 'password': password}),
                      );
                      final data = jsonDecode(response.body) as Map<String, dynamic>;
                      if (!mounted) return;
                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please log in.')));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']?.toString() ?? 'Registration failed.')));
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not connect to the server. Make sure the backend is running.')));
                    }
                  }),
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Already have an account? Log in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// HOME DASHBOARD

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int selectedIndex = 0;
  final List<Map<String, String>> medicines = [];
  bool isLoadingMedicines = false;
  String _dailyCheckIn = '';

  Future<void> _saveDailyCheckIn(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'careschedule_daily_checkin_${today.year}-${today.month}-${today.day}';
    await prefs.setString(key, mood);
    if (mounted) setState(() => _dailyCheckIn = mood);
  }

  Future<void> _loadDailyCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'careschedule_daily_checkin_${today.year}-${today.month}-${today.day}';
    final saved = prefs.getString(key);
    if (mounted && saved != null) setState(() => _dailyCheckIn = saved);
  }

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _loadDailyCheckIn();
  }

  Future<void> _loadMedicines() async {
    if (CareScheduleApi.token == null) return;
    setState(() => isLoadingMedicines = true);
    try {
      final response = await http.get(
        Uri.parse('${CareScheduleApi.baseUrl}/api/medicines'),
        headers: CareScheduleApi.headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['medicines'] as List<dynamic>? ?? []);
        if (!mounted) return;
        setState(() {
          medicines
            ..clear()
            ..addAll(list.map((item) {
              final m = item as Map<String, dynamic>;
              return <String, String>{
                'id': (m['_id'] ?? '').toString(),
                'name': (m['medicineName'] ?? '').toString(),
                'dosage': (m['dosage'] ?? '').toString(),
                'timing': (m['timing'] ?? '').toString(),
                'frequency': (m['frequency'] ?? '').toString(),
              };
            }));
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not load medicines. Please log in again.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not connect to the server to load medicines.')));
    } finally {
      if (mounted) setState(() => isLoadingMedicines = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650),
            child: IndexedStack(
              index: selectedIndex,
              children: [
                _buildHome(),
                _buildMedicines(),
                const AppointmentsScreen(),
                const MyHealthScreen(),
                const MedicalTimelineScreen(),
                const SymptomTrackerScreen(),
                const FamilyMedicalHistoryScreen(),
                const PreventiveHealthTipsScreen(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'careScheduleAssistant',
        backgroundColor: CareScheduleApp.sage,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiHealthAssistantScreen()),
        ),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Ask Care AI'),
      ),
      bottomNavigationBar: NavigationBar(
        // Keep the bottom navigation compact on both laptop and mobile.
        // Extra sections are available from the More menu.
        selectedIndex: selectedIndex < 4 ? selectedIndex : 4,
        backgroundColor: Colors.white,
        indicatorColor: CareScheduleApp.softGreen,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) {
          if (index < 4) {
            setState(() => selectedIndex = index);
          } else {
            _showMoreFeatures();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.medication_outlined),
            selectedIcon: Icon(Icons.medication_rounded),
            label: 'Medicines',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Appointments',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'My Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_rounded),
            selectedIcon: Icon(Icons.menu_open_rounded),
            label: 'More',
          ),
        ],
      ),
    );
  }


  void _showMoreFeatures() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final features = <({String title, String subtitle, IconData icon, int index})>[
          (title: 'Medical Timeline', subtitle: 'View your health history', icon: Icons.timeline_rounded, index: 4),
          (title: 'Symptom Tracker', subtitle: 'Record how you feel', icon: Icons.monitor_heart_outlined, index: 5),
          (title: 'Family History', subtitle: 'Keep family health details', icon: Icons.family_restroom_outlined, index: 6),
          (title: 'Health Tips', subtitle: 'Explore everyday wellness tips', icon: Icons.spa_outlined, index: 7),
        ];

        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.82,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'More features',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'All your care tools, in one place.',
                    style: TextStyle(color: CareScheduleApp.mutedText),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.count(
                      padding: const EdgeInsets.only(top: 8, bottom: 12),
                      crossAxisCount: MediaQuery.of(sheetContext).size.width > 600 ? 2 : 1,
                      childAspectRatio: MediaQuery.of(sheetContext).size.width > 600 ? 2.8 : 3.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 10,
                      children: [
                        ...features.map((feature) => _moreFeatureTile(
                          icon: feature.icon,
                          title: feature.title,
                          subtitle: feature.subtitle,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            setState(() => selectedIndex = feature.index);
                          },
                        )),
                        _moreFeatureTile(
                          icon: Icons.document_scanner_outlined,
                          title: 'Prescription Scanner',
                          subtitle: 'Upload and review a prescription photo',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrescriptionScannerScreen()));
                          },
                        ),
                        _moreFeatureTile(
                          icon: Icons.description_outlined,
                          title: 'Medical Reports',
                          subtitle: 'Organise lab report photos by date and type',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalReportsScreen()));
                          },
                        ),
                        _moreFeatureTile(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notifications',
                          subtitle: 'View reminders and care updates',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                          },
                        ),
                        _moreFeatureTile(
                          icon: Icons.medication_liquid_rounded,
                          title: 'Medicine Interaction Checker',
                          subtitle: 'Review official medicine label information',
                          onTap: () {
                            Navigator.pop(sheetContext);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MedicineInteractionCheckerScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _moreFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFF7FBF8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CareScheduleApp.softGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: CareScheduleApp.sage),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: CareScheduleApp.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: CareScheduleApp.mutedText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicines() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Medicines 💊',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your medicines and dosage details in one place.',
            style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.medication_rounded,
                      color: CareScheduleApp.darkGreen, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${medicines.length} ${medicines.length == 1 ? 'medicine' : 'medicines'} added',
                        style: const TextStyle(
                          color: CareScheduleApp.darkGreen,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Stay organised with your daily care.',
                        style: TextStyle(color: CareScheduleApp.darkGreen),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your medicine list',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CareScheduleApp.darkGreen,
                ),
              ),
              TextButton.icon(
                onPressed: _openAddMedicine,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add new'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (isLoadingMedicines)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (medicines.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  Container(
                    height: 76,
                    width: 76,
                    decoration: BoxDecoration(
                      color: CareScheduleApp.softGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.medication_outlined,
                      size: 42,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No medicines added yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CareScheduleApp.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your medicine details to keep them organised here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  _primaryButton('Add Medicine', _openAddMedicine),
                ],
              ),
            )
          else
            ...medicines.asMap().entries.map((entry) {
              final index = entry.key;
              final medicine = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: CareScheduleApp.softGreen,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.medication_outlined,
                          color: CareScheduleApp.darkGreen, size: 28),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(medicine['name']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: CareScheduleApp.darkGreen,
                              )),
                          const SizedBox(height: 4),
                          Text('${medicine['dosage']} • ${medicine['frequency']}',
                              style: const TextStyle(color: CareScheduleApp.mutedText)),
                          const SizedBox(height: 4),
                          Text('Time: ${medicine['timing']}',
                              style: const TextStyle(fontSize: 12, color: CareScheduleApp.sage)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove medicine',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Delete from database will be added in a later step.')),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: CareScheduleApp.mutedText),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: CareScheduleApp.darkGreen),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your medicine details are loaded from your CareSchedule account. Follow your healthcare professional’s instructions.',
                    style: TextStyle(color: CareScheduleApp.darkGreen, height: 1.4, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAddMedicine() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
    );
    if (result == null || !mounted) return;
    if (CareScheduleApi.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in before adding a medicine.')));
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${CareScheduleApi.baseUrl}/api/medicines'),
        headers: CareScheduleApi.headers,
        body: jsonEncode({
          'medicineName': result['name'],
          'dosage': result['dosage'],
          'timing': result['timing'],
          'frequency': result['frequency'],
        }),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 201) {
        await _loadMedicines();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medicine saved to your account.')));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message']?.toString() ?? 'Could not save medicine.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not connect to the server. Check that the backend is running.')));
    }
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PopupMenuButton<String>(
                tooltip: 'Quick access',
                icon: const Icon(Icons.menu_rounded, color: CareScheduleApp.darkGreen),
                onSelected: (value) {
                  final Widget page = value == 'prescription'
                      ? const PrescriptionScannerScreen()
                      : value == 'reports'
                          ? const MedicalReportsScreen()
                          : value == 'sos'
                              ? const SosScreen()
                              : const NotificationsScreen();
                  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'prescription', child: ListTile(leading: Icon(Icons.document_scanner_outlined), title: Text('Prescription Scanner'), contentPadding: EdgeInsets.zero)),
                  PopupMenuItem(value: 'reports', child: ListTile(leading: Icon(Icons.description_outlined), title: Text('Medical Reports'), contentPadding: EdgeInsets.zero)),
                  PopupMenuItem(value: 'notifications', child: ListTile(leading: Icon(Icons.notifications_none_rounded), title: Text('Notifications'), contentPadding: EdgeInsets.zero)),
                  PopupMenuItem(value: 'sos', child: ListTile(leading: Icon(Icons.sos_rounded, color: Colors.red), title: Text('Emergency SOS'), contentPadding: EdgeInsets.zero)),
                ],
              ),
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: CareScheduleApp.softGreen,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  color: CareScheduleApp.darkGreen,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CareSchedule',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: CareScheduleApp.darkGreen,
                      ),
                    ),
                    Text(
                      'Your daily wellness companion',
                      style: TextStyle(
                        fontSize: 12,
                        color: CareScheduleApp.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Notifications',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              IconButton(
                tooltip: 'Emergency SOS',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen())),
                icon: const Icon(Icons.sos_rounded, color: Colors.red, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _EmergencySosHomeCard(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosScreen()))),
          const SizedBox(height: 12),
          const SizedBox(height: 28),
          const Text(
            'Hello, there! 🌿',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let’s make today a little healthier.',
            style: TextStyle(
              fontSize: 15,
              color: CareScheduleApp.mutedText,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 20),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: CareScheduleApp.softGreen),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined, color: CareScheduleApp.sage, size: 26),
                    SizedBox(width: 10),
                    Expanded(child: Text('How are you feeling today?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen))),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('A tiny daily check-in, just for you.', style: TextStyle(color: CareScheduleApp.mutedText)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ('😊', 'Good'),
                    ('😐', 'Okay'),
                    ('😔', 'Low'),
                    ('😣', 'Unwell'),
                  ].map((option) {
                    final selected = _dailyCheckIn == option.$2;
                    return ChoiceChip(
                      label: Text('${option.$1} ${option.$2}'),
                      selected: selected,
                      onSelected: (_) => _saveDailyCheckIn(option.$2),
                      selectedColor: CareScheduleApp.softGreen,
                      backgroundColor: const Color(0xFFF7FBF8),
                      labelStyle: TextStyle(color: CareScheduleApp.darkGreen, fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                      side: BorderSide(color: selected ? CareScheduleApp.sage : const Color(0xFFE2EEE8)),
                    );
                  }).toList(),
                ),
                if (_dailyCheckIn.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Today’s check-in: $_dailyCheckIn', style: const TextStyle(color: CareScheduleApp.darkGreen, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 8),
                const Text('This is a personal wellness note, not a medical assessment.', style: TextStyle(fontSize: 12, color: CareScheduleApp.mutedText)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.spa_rounded,
                  color: CareScheduleApp.darkGreen,
                  size: 32,
                ),
                SizedBox(height: 14),
                Text(
                  'A gentle reminder',
                  style: TextStyle(
                    color: CareScheduleApp.darkGreen,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Small steps towards better health matter. '
                  'Take a moment for yourself today.',
                  style: TextStyle(
                    color: CareScheduleApp.darkGreen,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Your daily care',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  Icons.medication_outlined,
                  'Medicines',
                  'Manage doses',
                  () => setState(() => selectedIndex = 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  Icons.calendar_month_outlined,
                  'Appointments',
                  'Plan visits',
                  () => setState(() => selectedIndex = 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryCard(
            Icons.favorite_border_rounded,
            'Health profile',
            'View your health details',
            () => setState(() => selectedIndex = 3),
            fullWidth: true,
          ),
          const SizedBox(height: 28),
          const Text(
            'Coming up next',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FBF8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.notifications_active_outlined,
                  color: CareScheduleApp.sage,
                  size: 30,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your reminders and appointments will appear here.',
                    style: TextStyle(
                      color: CareScheduleApp.mutedText,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: CareScheduleApp.softGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: CareScheduleApp.darkGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: CareScheduleApp.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CareScheduleApp.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: CareScheduleApp.sage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final timingController = TextEditingController(text: '9:00 AM');
  String frequency = 'Once daily';

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    timingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: CareScheduleApp.softGreen,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.medication_rounded, size: 38, color: CareScheduleApp.darkGreen),
                          SizedBox(height: 12),
                          Text('Medicine details', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
                          SizedBox(height: 6),
                          Text('Enter the details as prescribed by your healthcare professional.', style: TextStyle(color: CareScheduleApp.darkGreen, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Medicine name', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration('e.g. Paracetamol', Icons.medication_outlined),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter a medicine name' : null,
                    ),
                    const SizedBox(height: 18),
                    const Text('Dosage', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: dosageController,
                      decoration: _inputDecoration('e.g. 500 mg', Icons.scale_outlined),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter the prescribed dosage' : null,
                    ),
                    const SizedBox(height: 18),
                    const Text('Time', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: timingController,
                      decoration: _inputDecoration('e.g. 9:00 AM', Icons.access_time_rounded),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter a time' : null,
                    ),
                    const SizedBox(height: 18),
                    const Text('Frequency', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: frequency,
                      decoration: _inputDecoration('Choose frequency', Icons.repeat_rounded),
                      items: const [
                        DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
                        DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                        DropdownMenuItem(value: 'Three times daily', child: Text('Three times daily')),
                        DropdownMenuItem(value: 'As prescribed', child: Text('As prescribed')),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => frequency = value);
                      },
                    ),
                    const SizedBox(height: 28),
                    _primaryButton('Save Medicine', () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, <String, String>{
                          'name': nameController.text.trim(),
                          'dosage': dosageController.text.trim(),
                          'timing': timingController.text.trim(),
                          'frequency': frequency,
                        });
                      }
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final List<Map<String, dynamic>> appointments = [];
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    if (CareScheduleApi.token == null) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${CareScheduleApi.baseUrl}/api/appointments'),
        headers: CareScheduleApi.headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> items = data is List
            ? data
            : (data is Map<String, dynamic>
                ? (data['appointments'] as List<dynamic>? ?? [])
                : []);
        if (!mounted) return;
        setState(() {
          appointments
            ..clear()
            ..addAll(items.whereType<Map>().map((item) => Map<String, dynamic>.from(item)));
        });
      } else if (mounted) {
        _showMessage(data is Map ? (data['message']?.toString() ?? 'Could not load appointments.') : 'Could not load appointments.');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not connect to the server. Check that the backend is running.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openBookingForm() async {
    if (CareScheduleApi.token == null) {
      _showMessage('Please log in before booking an appointment.');
      return;
    }
    final formKey = GlobalKey<FormState>();
    final doctorController = TextEditingController();
    final specialtyController = TextEditingController();
    final reasonController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CareScheduleApp.cream,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(22, 22, 22, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Book an appointment 🩺', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
                  const SizedBox(height: 8),
                  const Text('Enter your doctor and visit details.', style: TextStyle(color: CareScheduleApp.mutedText)),
                  const SizedBox(height: 20),
                  TextFormField(controller: doctorController, textCapitalization: TextCapitalization.words, decoration: _appointmentDecoration('Doctor name', Icons.person_outline), validator: (v) => v == null || v.trim().isEmpty ? 'Enter the doctor name' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: specialtyController, textCapitalization: TextCapitalization.words, decoration: _appointmentDecoration('Speciality (e.g. Dentist)', Icons.medical_services_outlined), validator: (v) => v == null || v.trim().isEmpty ? 'Enter the speciality' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: reasonController, maxLines: 2, decoration: _appointmentDecoration('Reason for visit', Icons.notes_rounded), validator: (v) => v == null || v.trim().isEmpty ? 'Enter the reason for visit' : null),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: OutlinedButton.icon(onPressed: () async { final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365 * 2))); if (picked != null) setSheetState(() => selectedDate = picked); }, icon: const Icon(Icons.calendar_month_outlined), label: Text('${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'))),
                    const SizedBox(width: 10),
                    Expanded(child: OutlinedButton.icon(onPressed: () async { final picked = await showTimePicker(context: context, initialTime: selectedTime); if (picked != null) setSheetState(() => selectedTime = picked); }, icon: const Icon(Icons.access_time), label: Text(selectedTime.format(context)))),
                  ]),
                  const SizedBox(height: 20),
                  SizedBox(width: double.infinity, child: FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(sheetContext, true); }, style: FilledButton.styleFrom(backgroundColor: CareScheduleApp.sage, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Save appointment'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (result != true || !mounted) {
      doctorController.dispose(); specialtyController.dispose(); reasonController.dispose();
      return;
    }
    setState(() => isSaving = true);
    final dateString = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    final timeString = selectedTime.format(context);
    try {
      final response = await http.post(
        Uri.parse('${CareScheduleApi.baseUrl}/api/appointments'),
        headers: CareScheduleApi.headers,
        body: jsonEncode({
          'doctorName': doctorController.text.trim(),
          'specialty': specialtyController.text.trim(),
          'appointmentDate': dateString,
          'appointmentTime': timeString,
          'reason': reasonController.text.trim(),
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadAppointments();
        if (mounted) _showMessage('Appointment saved to your CareSchedule account.');
      } else if (mounted) {
        _showMessage(data is Map ? (data['message']?.toString() ?? 'Could not save appointment.') : 'Could not save appointment.');
      }
    } catch (_) {
      if (mounted) _showMessage('Could not connect to the server. Check that the backend is running.');
    } finally {
      doctorController.dispose(); specialtyController.dispose(); reasonController.dispose();
      if (mounted) setState(() => isSaving = false);
    }
  }

  InputDecoration _appointmentDecoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: CareScheduleApp.sage),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
  );

  String _value(Map<String, dynamic> item, List<String> keys, [String fallback = '']) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: CareScheduleApp.sage,
      onRefresh: _loadAppointments,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        children: [
          const Text('My Appointments 🩺', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 8),
          const Text('Keep your doctor visits organised in one gentle, simple place.', style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4)),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: CareScheduleApp.softGreen, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.calendar_month_rounded, size: 36, color: CareScheduleApp.darkGreen), SizedBox(width: 14), Expanded(child: Text('Plan your next visit and keep the details handy.', style: TextStyle(color: CareScheduleApp.darkGreen, fontWeight: FontWeight.w600, height: 1.4)))])),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: isSaving ? null : _openBookingForm, style: FilledButton.styleFrom(backgroundColor: CareScheduleApp.sage, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)), icon: const Icon(Icons.add), label: Text(isSaving ? 'Saving appointment...' : 'Book an appointment'))),
          const SizedBox(height: 26),
          Row(children: [const Expanded(child: Text('Upcoming and saved visits', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen))), IconButton(onPressed: _loadAppointments, tooltip: 'Refresh', icon: const Icon(Icons.refresh_rounded, color: CareScheduleApp.sage))]),
          if (isLoading) const Padding(padding: EdgeInsets.all(28), child: Center(child: CircularProgressIndicator(color: CareScheduleApp.sage))),
          if (!isLoading && appointments.isEmpty) Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0xFFF7FBF8), borderRadius: BorderRadius.circular(20)), child: const Column(children: [Icon(Icons.event_available_outlined, size: 42, color: CareScheduleApp.sage), SizedBox(height: 12), Text('No appointments yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: CareScheduleApp.darkGreen)), SizedBox(height: 6), Text('Tap “Book an appointment” to add your first visit.', textAlign: TextAlign.center, style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4))])),
          ...appointments.map((item) {
            final doctor = _value(item, ['doctorName', 'doctor', 'name'], 'Doctor');
            final specialty = _value(item, ['specialty', 'speciality', 'doctorSpecialty']);
            final date = _value(item, ['appointmentDate', 'date'], 'Date not specified');
            final time = _value(item, ['appointmentTime', 'time'], 'Time not specified');
            final reason = _value(item, ['reason', 'purpose'], 'General consultation');
            return Container(margin: const EdgeInsets.only(bottom: 13), padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: const Color(0xFFF7FBF8), borderRadius: BorderRadius.circular(19), border: Border.all(color: CareScheduleApp.softGreen)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: CareScheduleApp.softGreen, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.medical_services_outlined, color: CareScheduleApp.darkGreen)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)), if (specialty.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 3), child: Text(specialty, style: const TextStyle(color: CareScheduleApp.mutedText))), const SizedBox(height: 9), Row(children: [const Icon(Icons.calendar_today_outlined, size: 16, color: CareScheduleApp.sage), const SizedBox(width: 6), Expanded(child: Text(date, style: const TextStyle(color: CareScheduleApp.darkGreen)))]), const SizedBox(height: 5), Row(children: [const Icon(Icons.access_time, size: 16, color: CareScheduleApp.sage), const SizedBox(width: 6), Text(time, style: const TextStyle(color: CareScheduleApp.darkGreen))]), const SizedBox(height: 8), Text('Reason: $reason', style: const TextStyle(color: CareScheduleApp.mutedText, height: 1.3))]))]));
          }),
        ],
      ),
    );
  }
}


// MY HEALTH PROFILE
class MyHealthScreen extends StatefulWidget {
  const MyHealthScreen({super.key});

  @override
  State<MyHealthScreen> createState() => _MyHealthScreenState();
}

class _MyHealthScreenState extends State<MyHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  final dateOfBirthController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final allergiesController = TextEditingController();
  final conditionsController = TextEditingController();
  final emergencyContactController = TextEditingController();

  String? gender;
  String? bloodGroup;
  bool isLoading = false;
  bool isSaving = false;
  bool hasProfile = false;
  bool hasLoaded = false;
  bool isEditing = false;

  static const _genderOptions = ['Female', 'Male', 'Other', 'Prefer not to say'];
  static const _bloodGroupOptions = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
    'Unknown',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    dateOfBirthController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergiesController.dispose();
    conditionsController.dispose();
    emergencyContactController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadProfile() async {
    if (CareScheduleApi.token == null) {
      setState(() => hasLoaded = true);
      return;
    }

    setState(() {
      isLoading = true;
      hasLoaded = false;
    });

    try {
      final response = await http.get(
        Uri.parse('${CareScheduleApi.baseUrl}/api/health-profile'),
        headers: CareScheduleApi.headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final Map<String, dynamic>? profile =
            decoded is Map<String, dynamic> &&
                    decoded['profile'] is Map<String, dynamic>
                ? decoded['profile'] as Map<String, dynamic>
                : null;

        if (profile != null && mounted) {
          setState(() {
            dateOfBirthController.text =
                (profile['dateOfBirth'] ?? '').toString();
            gender = _matchingOption(
              (profile['gender'] ?? '').toString(),
              _genderOptions,
            );
            bloodGroup = _matchingOption(
              (profile['bloodGroup'] ?? '').toString(),
              _bloodGroupOptions,
            );
            heightController.text = (profile['height'] ?? '').toString();
            weightController.text = (profile['weight'] ?? '').toString();
            allergiesController.text = (profile['allergies'] ?? 'None').toString();
            conditionsController.text =
                (profile['existingConditions'] ?? 'None').toString();
            // Some older backend versions may not return emergencyContact yet.
            // Preserve the number entered in the form instead of replacing it with blank.
            if (profile.containsKey('emergencyContact') &&
                profile['emergencyContact'] != null) {
              emergencyContactController.text =
                  profile['emergencyContact'].toString();
            }
            hasProfile = true;
          });
        }
      } else if (response.statusCode == 404) {
        if (mounted) {
          setState(() {
            hasProfile = false;
            allergiesController.text = 'None';
            conditionsController.text = 'None';
            emergencyContactController.clear();
          });
        }
      } else if (response.statusCode == 401) {
        _showMessage('Your session may have expired. Please log in again.');
      } else {
        _showMessage('Could not load your health profile.');
      }
    } catch (_) {
      _showMessage('Could not connect to the server. Check that the backend is running.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasLoaded = true;
        });
      }
    }
  }

  String? _matchingOption(String value, List<String> options) {
    for (final option in options) {
      if (option.toLowerCase() == value.toLowerCase()) return option;
    }
    return null;
  }

  Future<void> _pickDateOfBirth() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    final currentText = dateOfBirthController.text.trim();
    final parsed = DateTime.tryParse(currentText);
    if (parsed != null) initialDate = parsed;

    final now = DateTime.now();
    if (initialDate.isAfter(now)) initialDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
    );

    if (picked != null && mounted) {
      dateOfBirthController.text =
          '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (CareScheduleApi.token == null) {
      _showMessage('Please log in before saving your health profile.');
      return;
    }

    if (gender == null || bloodGroup == null) {
      _showMessage('Please select your gender and blood group.');
      return;
    }

    setState(() => isSaving = true);

    try {
      final response = await http.post(
        Uri.parse('${CareScheduleApi.baseUrl}/api/health-profile'),
        headers: CareScheduleApi.headers,
        body: jsonEncode({
          'dateOfBirth': dateOfBirthController.text.trim(),
          'gender': gender,
          'bloodGroup': bloodGroup,
          'height': heightController.text.trim(),
          'weight': weightController.text.trim(),
          'allergies': allergiesController.text.trim().isEmpty
              ? 'None'
              : allergiesController.text.trim(),
          'existingConditions': conditionsController.text.trim().isEmpty
              ? 'None'
              : conditionsController.text.trim(),
          'emergencyContact': emergencyContactController.text.trim(),
        }),
      );

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          setState(() {
            hasProfile = true;
            isEditing = false;
          });
          _showMessage('Your health profile has been saved.');
        }
        await _loadProfile();
      } else {
        _showMessage(
          data['message']?.toString() ?? 'Could not save your health profile.',
        );
      }
    } catch (_) {
      _showMessage('Could not connect to the server. Check that the backend is running.');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  InputDecoration _healthDecoration(String label, IconData icon,
      {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: CareScheduleApp.sage),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: CareScheduleApp.softGreen),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: CareScheduleApp.sage, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: CareScheduleApp.darkGreen,
        ),
      ),
    );
  }

  Widget _detailCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: CareScheduleApp.softGreen),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: CareScheduleApp.darkGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(
                  color: CareScheduleApp.mutedText, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: CareScheduleApp.darkGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQrHealthPassport() {
    final passport = <String, dynamic>{
      'app': 'CareSchedule Health Passport',
      'dateOfBirth': dateOfBirthController.text.trim().isEmpty
          ? 'Not provided'
          : dateOfBirthController.text.trim(),
      'bloodGroup': bloodGroup ?? 'Not provided',
      'allergies': allergiesController.text.trim().isEmpty
          ? 'Not provided'
          : allergiesController.text.trim(),
      'existingConditions': conditionsController.text.trim().isEmpty
          ? 'Not provided'
          : conditionsController.text.trim(),
      'emergencyContact': emergencyContactController.text.trim().isEmpty
          ? 'Not provided'
          : emergencyContactController.text.trim(),
      'notice':
          'Personal health summary only. Confirm details with the patient; not a diagnosis.',
    };
    final qrData = jsonEncode(passport);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: const Color(0xFFF7FBF8),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'QR Health Passport',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CareScheduleApp.darkGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This QR contains your selected health summary. Only show it to someone you trust.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CareScheduleApp.mutedText),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 252,
                    height: 252,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 228,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Anyone who scans this code may be able to read the information inside it. Do not post or share it publicly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: CareScheduleApp.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showHealthSummary() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF7FBF8),
        title: const Row(
          children: [
            Icon(Icons.health_and_safety_rounded,
                color: CareScheduleApp.darkGreen),
            SizedBox(width: 10),
            Expanded(child: Text('Health Summary')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _summaryLine('Date of birth', dateOfBirthController.text),
              _summaryLine('Gender', gender ?? ''),
              _summaryLine('Blood group', bloodGroup ?? ''),
              _summaryLine('Height', heightController.text),
              _summaryLine('Weight', weightController.text),
              _summaryLine('Allergies', allergiesController.text),
              _summaryLine('Medical conditions', conditionsController.text),
              _summaryLine('Emergency contact', emergencyContactController.text),
              const SizedBox(height: 8),
              const Text(
                'This summary is based on the information you entered and is not medical advice.',
                style: TextStyle(
                  color: CareScheduleApp.mutedText,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CareScheduleApp.mutedText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.trim().isEmpty ? 'Not provided' : value.trim(),
            style: const TextStyle(
              color: CareScheduleApp.darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmergencyCard() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFFF7FBF8),
        title: const Row(
          children: [
            Icon(Icons.emergency_rounded, color: Colors.redAccent),
            SizedBox(width: 10),
            Expanded(child: Text('Emergency Health Card')),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: CareScheduleApp.softGreen, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('CARESCHEDULE', style: TextStyle(
                  fontSize: 12, letterSpacing: 1.4,
                  fontWeight: FontWeight.bold, color: CareScheduleApp.sage)),
                const SizedBox(height: 12),
                _summaryLine('Blood group', bloodGroup ?? ''),
                _summaryLine('Allergies', allergiesController.text),
                _summaryLine('Medical conditions', conditionsController.text),
                _summaryLine('Current medicines', 'See Medicines and Timeline'),
                _summaryLine('Emergency contact', emergencyContactController.text),
                const SizedBox(height: 8),
                const Text(
                  'Keep this information updated. In an emergency, contact local emergency services. This card is a personal summary, not a medical diagnosis.',
                  style: TextStyle(fontSize: 11, color: CareScheduleApp.mutedText, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return RefreshIndicator(
      color: CareScheduleApp.sage,
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
        children: [
          const Text('My Health 💚', style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold,
            color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 8),
          const Text(
            'Your personal health dashboard. Your saved details are shown below.',
            style: TextStyle(color: CareScheduleApp.mutedText, height: 1.45)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(children: [
              Icon(Icons.verified_user_rounded, size: 35,
                  color: CareScheduleApp.darkGreen),
              SizedBox(width: 13),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Health profile saved',
                    style: TextStyle(fontWeight: FontWeight.bold,
                      fontSize: 17, color: CareScheduleApp.darkGreen)),
                  SizedBox(height: 4),
                  Text('Your information is ready to view and update.',
                    style: TextStyle(color: CareScheduleApp.darkGreen,
                      height: 1.4)),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Basic information', style: TextStyle(
            fontSize: 19, fontWeight: FontWeight.bold,
            color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 12),
          _detailCard(Icons.calendar_month_outlined, 'Date of birth',
              dateOfBirthController.text),
          const SizedBox(height: 10),
          _detailCard(Icons.person_outline, 'Gender', gender ?? ''),
          const SizedBox(height: 10),
          _detailCard(Icons.bloodtype_outlined, 'Blood group', bloodGroup ?? ''),
          const SizedBox(height: 20),
          const Text('Body measurements', style: TextStyle(
            fontSize: 19, fontWeight: FontWeight.bold,
            color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _detailCard(Icons.height_rounded, 'Height',
                heightController.text)),
            const SizedBox(width: 10),
            Expanded(child: _detailCard(Icons.monitor_weight_outlined, 'Weight',
                weightController.text)),
          ]),
          const SizedBox(height: 20),
          const Text('Medical details', style: TextStyle(
            fontSize: 19, fontWeight: FontWeight.bold,
            color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 12),
          _detailCard(Icons.warning_amber_rounded, 'Allergies',
              allergiesController.text),
          const SizedBox(height: 10),
          _detailCard(Icons.medical_information_outlined,
              'Existing medical conditions', conditionsController.text),
          const SizedBox(height: 10),
          _detailCard(Icons.contact_phone_outlined, 'Emergency contact',
              emergencyContactController.text),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => setState(() => isEditing = true),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
              style: FilledButton.styleFrom(
                backgroundColor: CareScheduleApp.sage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showHealthSummary,
              icon: const Icon(Icons.description_outlined),
              label: const Text('Health Summary'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CareScheduleApp.darkGreen,
                side: const BorderSide(color: CareScheduleApp.sage),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showEmergencyCard,
              icon: const Icon(Icons.emergency_outlined),
              label: const Text('Emergency Health Card'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CareScheduleApp.darkGreen,
                side: const BorderSide(color: CareScheduleApp.sage),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showQrHealthPassport,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: const Text('QR Health Passport'),
              style: OutlinedButton.styleFrom(
                foregroundColor: CareScheduleApp.darkGreen,
                side: const BorderSide(color: CareScheduleApp.sage),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Keep your information accurate and updated. This record does not replace advice from a healthcare professional.',
            style: TextStyle(color: CareScheduleApp.mutedText,
              fontSize: 12, height: 1.45)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hasProfile && !isEditing && hasLoaded && !isLoading) {
      return _buildProfileView();
    }
    return RefreshIndicator(
      color: CareScheduleApp.sage,
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
        children: [
          const Text(
            'My Health 💚',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your important health details together in one secure profile.',
            style: TextStyle(color: CareScheduleApp.mutedText, height: 1.45),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.favorite_rounded,
                    size: 35, color: CareScheduleApp.darkGreen),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'Your health story, all in one place.',
                    style: TextStyle(
                      color: CareScheduleApp.darkGreen,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading && !hasLoaded)
            const Padding(
              padding: EdgeInsets.all(35),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            const SizedBox(height: 8),
            if (hasProfile)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: CareScheduleApp.sage),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'Edit your details below, then save your changes.',
                        style: TextStyle(color: CareScheduleApp.darkGreen),
                      ),
                    ),
                  ],
                ),
              ),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Basic information'),
                  TextFormField(
                    controller: dateOfBirthController,
                    readOnly: true,
                    onTap: _pickDateOfBirth,
                    decoration: _healthDecoration(
                      'Date of birth',
                      Icons.calendar_month_outlined,
                      hint: 'Choose your date of birth',
                    ).copyWith(
                      suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Select your date of birth'
                        : null,
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: _healthDecoration('Gender', Icons.person_outline),
                    items: _genderOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => gender = value),
                  ),
                  const SizedBox(height: 13),
                  DropdownButtonFormField<String>(
                    value: bloodGroup,
                    decoration:
                        _healthDecoration('Blood group', Icons.bloodtype_outlined),
                    items: _bloodGroupOptions
                        .map((item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => bloodGroup = value),
                  ),
                  _sectionTitle('Body measurements'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _healthDecoration(
                            'Height',
                            Icons.height_rounded,
                            hint: 'e.g. 160 cm',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter height'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: _healthDecoration(
                            'Weight',
                            Icons.monitor_weight_outlined,
                            hint: 'e.g. 55 kg',
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Enter weight'
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  _sectionTitle('Emergency contact'),
                  TextFormField(
                    controller: emergencyContactController,
                    keyboardType: TextInputType.phone,
                    decoration: _healthDecoration(
                      'Emergency contact number',
                      Icons.contact_phone_outlined,
                      hint: 'Phone number of a trusted person',
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add a trusted person who can be contacted in an emergency.',
                    style: TextStyle(color: CareScheduleApp.mutedText, fontSize: 12),
                  ),
                  _sectionTitle('Medical details'),
                  TextFormField(
                    controller: allergiesController,
                    maxLines: 2,
                    decoration: _healthDecoration(
                      'Allergies',
                      Icons.warning_amber_rounded,
                      hint: 'Write allergies, or None',
                    ),
                  ),
                  const SizedBox(height: 13),
                  TextFormField(
                    controller: conditionsController,
                    maxLines: 3,
                    decoration: _healthDecoration(
                      'Existing medical conditions',
                      Icons.medical_information_outlined,
                      hint: 'Write any conditions, or None',
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (hasProfile && isEditing)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          _loadProfile().then((_) {
                            if (mounted) setState(() => isEditing = false);
                          });
                        },
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Cancel editing'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CareScheduleApp.darkGreen,
                          side: const BorderSide(color: CareScheduleApp.softGreen),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isSaving ? null : _saveProfile,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(isSaving
                          ? 'Saving profile...'
                          : hasProfile
                              ? 'Update health profile'
                              : 'Save health profile'),
                      style: FilledButton.styleFrom(
                        backgroundColor: CareScheduleApp.sage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Enter accurate information and keep it updated. This profile is for record-keeping and does not replace advice from a healthcare professional.',
                    style: TextStyle(
                      color: CareScheduleApp.mutedText,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


// MASTER MEDICAL TIMELINE
// Combines saved appointments and medicines from the signed-in user's account.
class MedicalTimelineScreen extends StatefulWidget {
  const MedicalTimelineScreen({super.key});

  @override
  State<MedicalTimelineScreen> createState() => _MedicalTimelineScreenState();
}

class _MedicalTimelineScreenState extends State<MedicalTimelineScreen> {
  bool isLoading = false;
  String? errorMessage;
  final List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    if (CareScheduleApi.token == null) {
      setState(() {
        events.clear();
        errorMessage = 'Please log in to view your medical timeline.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final responses = await Future.wait([
        http.get(
          Uri.parse('${CareScheduleApi.baseUrl}/api/appointments'),
          headers: CareScheduleApi.headers,
        ),
        http.get(
          Uri.parse('${CareScheduleApi.baseUrl}/api/medicines'),
          headers: CareScheduleApi.headers,
        ),
      ]);

      final appointmentResponse = responses[0];
      final medicineResponse = responses[1];
      final List<Map<String, dynamic>> loadedEvents = [];

      if (appointmentResponse.statusCode == 200) {
        final decoded = jsonDecode(appointmentResponse.body);
        final List<dynamic> appointments = decoded is List
            ? decoded
            : decoded is Map<String, dynamic>
                ? (decoded['appointments'] as List<dynamic>? ?? [])
                : [];

        for (final raw in appointments) {
          if (raw is! Map) continue;
          final item = Map<String, dynamic>.from(raw);
          final date = _firstValue(item, ['appointmentDate', 'date']);
          final time = _firstValue(item, ['appointmentTime', 'time']);
          loadedEvents.add({
            'type': 'appointment',
            'title': _firstValue(item, ['doctorName', 'doctor', 'name'],
                fallback: 'Doctor appointment'),
            'subtitle': _firstValue(item, ['specialty', 'speciality']),
            'details': _firstValue(item, ['reason', 'purpose'],
                fallback: 'General consultation'),
            'date': date,
            'time': time,
            'sortDate': DateTime.tryParse(date) ?? DateTime(2100),
          });
        }
      } else {
        throw Exception('appointments');
      }

      if (medicineResponse.statusCode == 200) {
        final decoded = jsonDecode(medicineResponse.body);
        final List<dynamic> medicines = decoded is Map<String, dynamic>
            ? (decoded['medicines'] as List<dynamic>? ?? [])
            : decoded is List
                ? decoded
                : [];

        for (final raw in medicines) {
          if (raw is! Map) continue;
          final item = Map<String, dynamic>.from(raw);
          loadedEvents.add({
            'type': 'medicine',
            'title': _firstValue(item, ['medicineName', 'name'],
                fallback: 'Medicine'),
            'subtitle': _firstValue(item, ['dosage']),
            'details': _firstValue(item, ['frequency'], fallback: 'As prescribed'),
            'date': '',
            'time': _firstValue(item, ['timing']),
            'sortDate': DateTime(2099),
          });
        }
      } else {
        throw Exception('medicines');
      }

      loadedEvents.sort((a, b) {
        final aDate = a['sortDate'] as DateTime;
        final bDate = b['sortDate'] as DateTime;
        return aDate.compareTo(bDate);
      });

      if (!mounted) return;
      setState(() {
        events
          ..clear()
          ..addAll(loadedEvents);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          errorMessage =
              'Could not load your timeline. Check that the server is running and try again.';
        });
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _firstValue(
    Map<String, dynamic> item,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: CareScheduleApp.sage,
      onRefresh: _loadTimeline,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
        children: [
          const Text(
            'Medical Timeline 🗓️',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your saved appointments and medicines, together in one place.',
            style: TextStyle(
              color: CareScheduleApp.mutedText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.timeline_rounded,
                  size: 36,
                  color: CareScheduleApp.darkGreen,
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Text(
                    'A quick overview of the care details saved to your account.',
                    style: TextStyle(
                      color: CareScheduleApp.darkGreen,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your records',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: CareScheduleApp.darkGreen,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Refresh timeline',
                onPressed: isLoading ? null : _loadTimeline,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: CareScheduleApp.sage,
                ),
              ),
            ],
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(
                child: CircularProgressIndicator(color: CareScheduleApp.sage),
              ),
            )
          else if (errorMessage != null)
            _timelineMessage(
              Icons.cloud_off_outlined,
              errorMessage!,
            )
          else if (events.isEmpty)
            _timelineMessage(
              Icons.event_note_outlined,
              'No records yet. Add a medicine or book an appointment to start your timeline.',
            )
          else ...[
            ...events.map((event) {
              final isAppointment = event['type'] == 'appointment';
              final date = (event['date'] ?? '').toString();
              final time = (event['time'] ?? '').toString();
              final subtitle = (event['subtitle'] ?? '').toString();
              final details = (event['details'] ?? '').toString();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBF8),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: CareScheduleApp.softGreen),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: CareScheduleApp.softGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isAppointment
                            ? Icons.calendar_month_outlined
                            : Icons.medication_outlined,
                        color: CareScheduleApp.darkGreen,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAppointment ? 'Appointment' : 'Medicine',
                            style: const TextStyle(
                              fontSize: 12,
                              color: CareScheduleApp.sage,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (event['title'] ?? '').toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: CareScheduleApp.darkGreen,
                            ),
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: CareScheduleApp.mutedText,
                              ),
                            ),
                          ],
                          if (details.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              isAppointment ? 'Reason: $details' : details,
                              style: const TextStyle(
                                color: CareScheduleApp.darkGreen,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            isAppointment
                                ? '${date.isEmpty ? 'Date not specified' : date}${time.isEmpty ? '' : ' • $time'}'
                                : 'Time: ${time.isEmpty ? 'Not specified' : time}',
                            style: const TextStyle(
                              color: CareScheduleApp.mutedText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 8),
          const Text(
            'This timeline shows records currently saved in CareSchedule. It does not replace your doctor’s records or medical advice.',
            style: TextStyle(
              color: CareScheduleApp.mutedText,
              fontSize: 12,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineMessage(IconData icon, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: CareScheduleApp.sage),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CareScheduleApp.mutedText,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}


class SymptomTrackerScreen extends StatefulWidget {
  const SymptomTrackerScreen({super.key});

  @override
  State<SymptomTrackerScreen> createState() => _SymptomTrackerScreenState();
}

class _SymptomTrackerScreenState extends State<SymptomTrackerScreen> {
  static const _storageKey = 'careschedule_symptom_entries';
  static const _symptomOptions = <String>[
    'Headache', 'Fever', 'Cough', 'Sore throat', 'Stomach pain',
    'Nausea', 'Dizziness', 'Fatigue', 'Body ache', 'Shortness of breath',
    'Skin rash', 'Other',
  ];

  final Set<String> selectedSymptoms = {};
  final customSymptomController = TextEditingController();
  final notesController = TextEditingController();
  final List<Map<String, dynamic>> entries = [];
  DateTime selectedDate = DateTime.now();
  int severity = 3;
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    customSymptomController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      final decoded = raw == null ? [] : jsonDecode(raw);
      if (!mounted) return;
      setState(() {
        entries
          ..clear()
          ..addAll(decoded is List
              ? decoded.whereType<Map>().map(
                  (item) => Map<String, dynamic>.from(item),
                )
              : []);
        isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _saveSymptom() async {
    final symptoms = selectedSymptoms
        .where((item) => item != 'Other')
        .toList();
    if (selectedSymptoms.contains('Other') &&
        customSymptomController.text.trim().isNotEmpty) {
      symptoms.add(customSymptomController.text.trim());
    }
    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter at least one symptom.')),
      );
      return;
    }

    setState(() => isSaving = true);
    final entry = <String, dynamic>{
      'date': '${selectedDate.year.toString().padLeft(4, '0')}-'
          '${selectedDate.month.toString().padLeft(2, '0')}-'
          '${selectedDate.day.toString().padLeft(2, '0')}',
      'symptoms': symptoms,
      'severity': severity,
      'notes': notesController.text.trim(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final updated = [entry, ...entries];
      await prefs.setString(_storageKey, jsonEncode(updated));
      if (!mounted) return;
      setState(() {
        entries
          ..clear()
          ..addAll(updated);
        selectedSymptoms.clear();
        customSymptomController.clear();
        notesController.clear();
        selectedDate = DateTime.now();
        severity = 3;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Symptom entry saved on this device/browser.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this symptom entry.')),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Future<void> _deleteEntry(int index) async {
    final updated = [...entries]..removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(updated));
    if (mounted) setState(() {
      entries
        ..clear()
        ..addAll(updated);
    });
  }

  String _formatDate(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return '${parsed.day.toString().padLeft(2, '0')}/'
        '${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
      children: [
        const Text(
          'Symptom Tracker 🌿',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
              color: CareScheduleApp.darkGreen),
        ),
        const SizedBox(height: 8),
        const Text(
          'Record how you are feeling so you can review the pattern or share it with your healthcare professional.',
          style: TextStyle(color: CareScheduleApp.mutedText, height: 1.45),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CareScheduleApp.softGreen,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.health_and_safety_outlined, size: 34,
                  color: CareScheduleApp.darkGreen),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Track symptoms, date, severity and notes. This tracker does not diagnose conditions.',
                  style: TextStyle(color: CareScheduleApp.darkGreen, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('What symptoms are you experiencing?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                color: CareScheduleApp.darkGreen)),
        const SizedBox(height: 10),
        ..._symptomOptions.map((symptom) => CheckboxListTile(
          value: selectedSymptoms.contains(symptom),
          onChanged: (checked) => setState(() {
            if (checked == true) {
              selectedSymptoms.add(symptom);
            } else {
              selectedSymptoms.remove(symptom);
            }
          }),
          title: Text(symptom),
          activeColor: CareScheduleApp.sage,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
        )),
        if (selectedSymptoms.contains('Other')) ...[
          const SizedBox(height: 8),
          TextField(
            controller: customSymptomController,
            decoration: _inputDecoration('Describe your symptom', Icons.edit_note),
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
        const SizedBox(height: 18),
        const Text('Date',
            style: TextStyle(fontWeight: FontWeight.w600,
                color: CareScheduleApp.darkGreen)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null && mounted) setState(() => selectedDate = picked);
          },
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(_formatDate('${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}')),
        ),
        const SizedBox(height: 18),
        Text('Severity: $severity / 5',
            style: const TextStyle(fontWeight: FontWeight.w600,
                color: CareScheduleApp.darkGreen)),
        Slider(
          value: severity.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '$severity',
          activeColor: CareScheduleApp.sage,
          onChanged: (value) => setState(() => severity = value.round()),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mild', style: TextStyle(color: CareScheduleApp.mutedText)),
            Text('Severe', style: TextStyle(color: CareScheduleApp.mutedText)),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          controller: notesController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          decoration: _inputDecoration('Extra notes (optional)', Icons.notes_outlined),
        ),
        const SizedBox(height: 20),
        _primaryButton(isSaving ? 'Saving...' : 'Save Symptom Entry',
            isSaving ? () {} : _saveSymptom),
        const SizedBox(height: 28),
        const Text('Previous entries',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                color: CareScheduleApp.darkGreen)),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FBF8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text('No symptom entries yet. Your saved entries will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4)),
          )
        else
          ...entries.asMap().entries.map((item) {
            final index = item.key;
            final entry = item.value;
            final symptoms = (entry['symptoms'] as List? ?? []).join(', ');
            final note = (entry['notes'] ?? '').toString();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FBF8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: CareScheduleApp.softGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.event_note_outlined, color: CareScheduleApp.sage),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_formatDate((entry['date'] ?? '').toString()),
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            color: CareScheduleApp.darkGreen))),
                    IconButton(
                      tooltip: 'Delete entry',
                      onPressed: () => _deleteEntry(index),
                      icon: const Icon(Icons.delete_outline, color: CareScheduleApp.mutedText),
                    ),
                  ]),
                  Text(symptoms, style: const TextStyle(color: CareScheduleApp.darkGreen)),
                  const SizedBox(height: 5),
                  Text('Severity: ${entry['severity'] ?? 3}/5',
                      style: const TextStyle(color: CareScheduleApp.sage)),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text('Notes: $note', style: const TextStyle(color: CareScheduleApp.mutedText)),
                  ],
                ],
              ),
            );
          }),
        const SizedBox(height: 12),
        const Text(
          'If symptoms are severe, sudden or worsening, seek urgent medical help. Do not rely on this tracker for diagnosis.',
          style: TextStyle(fontSize: 12, color: CareScheduleApp.mutedText, height: 1.45),
        ),
      ],
    );
  }
}

class SimpleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SimpleSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: CareScheduleApp.softGreen,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                icon,
                size: 48,
                color: CareScheduleApp.darkGreen,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: CareScheduleApp.darkGreen,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: CareScheduleApp.mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'We’ll build this section next.',
              style: TextStyle(color: CareScheduleApp.sage),
            ),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 17,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
  );
}

Widget _primaryButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: CareScheduleApp.sage,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17),
      ),
    ),
  );
}


// FAMILY MEDICAL HISTORY
class FamilyMedicalHistoryScreen extends StatefulWidget {
  const FamilyMedicalHistoryScreen({super.key});

  @override
  State<FamilyMedicalHistoryScreen> createState() => _FamilyMedicalHistoryScreenState();
}

class _FamilyMedicalHistoryScreenState extends State<FamilyMedicalHistoryScreen> {
  static const _storageKey = 'careschedule_family_medical_history';
  static const _relations = <String>[
    'Mother', 'Father', 'Sister', 'Brother', 'Grandmother', 'Grandfather',
    'Aunt', 'Uncle', 'Other relative',
  ];
  static const _conditions = <String>[
    'Diabetes', 'High blood pressure', 'Heart disease', 'Stroke',
    'Asthma', 'Cancer', 'Thyroid disorder', 'Kidney disease',
    'Mental health condition', 'Other',
  ];

  final List<Map<String, dynamic>> records = [];
  final TextEditingController ageController = TextEditingController();
  final TextEditingController customConditionController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  String relation = 'Mother';
  String condition = 'Diabetes';
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    ageController.dispose();
    customConditionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      final decoded = raw == null ? [] : jsonDecode(raw);
      if (!mounted) return;
      setState(() {
        records
          ..clear()
          ..addAll(decoded is List
              ? decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item))
              : []);
        isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _persistRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(records));
  }

  Future<void> _addRecord() async {
    final chosenCondition = condition == 'Other'
        ? customConditionController.text.trim()
        : condition;
    if (chosenCondition.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the medical condition.')),
      );
      return;
    }
    final ageText = ageController.text.trim();
    if (ageText.isNotEmpty && int.tryParse(ageText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid age or leave it blank.')),
      );
      return;
    }

    setState(() => isSaving = true);
    records.insert(0, <String, dynamic>{
      'relation': relation,
      'condition': chosenCondition,
      'ageDiagnosed': ageText,
      'notes': notesController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
    try {
      await _persistRecords();
      ageController.clear();
      customConditionController.clear();
      notesController.clear();
      if (mounted) {
        setState(() {
          condition = 'Diabetes';
          isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Family medical history saved.')),
        );
      }
    } catch (_) {
      records.removeAt(0);
      if (mounted) setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save this record on this device.')),
        );
      }
    }
  }

  Future<void> _deleteRecord(int index) async {
    final removed = records.removeAt(index);
    setState(() {});
    try {
      await _persistRecords();
    } catch (_) {
      records.insert(index, removed);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Family Medical History 👨‍👩‍👧',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold,
                color: CareScheduleApp.darkGreen),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep a record of health conditions that run in your family. This can help you discuss relevant risks with your doctor.',
            style: TextStyle(color: CareScheduleApp.mutedText, height: 1.45),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CareScheduleApp.softGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_outlined, size: 28, color: CareScheduleApp.darkGreen),
                SizedBox(width: 12),
                Expanded(child: Text(
                  'Family history is information, not a diagnosis. Having a condition in your family does not mean you will definitely develop it.',
                  style: TextStyle(color: CareScheduleApp.darkGreen, height: 1.4),
                )),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Add a family record', style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 14),
          _fieldLabel('Family member'),
          DropdownButtonFormField<String>(
            value: relation,
            decoration: _inputDecoration('Select relation'),
            items: _relations.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) { if (value != null) setState(() => relation = value); },
          ),
          const SizedBox(height: 14),
          _fieldLabel('Medical condition'),
          DropdownButtonFormField<String>(
            value: condition,
            decoration: _inputDecoration('Select condition'),
            items: _conditions.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) { if (value != null) setState(() => condition = value); },
          ),
          if (condition == 'Other') ...[
            const SizedBox(height: 12),
            TextField(controller: customConditionController,
              decoration: _inputDecoration('Enter condition')),
          ],
          const SizedBox(height: 14),
          _fieldLabel('Age when diagnosed (optional)'),
          TextField(controller: ageController, keyboardType: TextInputType.number,
            decoration: _inputDecoration('e.g. 45')),
          const SizedBox(height: 14),
          _fieldLabel('Additional notes (optional)'),
          TextField(controller: notesController, maxLines: 3,
            decoration: _inputDecoration('Any details you want to remember')),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _addRecord,
              icon: const Icon(Icons.save_outlined),
              label: Text(isSaving ? 'Saving...' : 'Save Family Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CareScheduleApp.sage,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Saved family records', style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (records.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: const Text('No family history added yet. Your saved records will appear here.',
                  style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4)),
            )
          else
            ...records.asMap().entries.map((entry) {
              final index = entry.key;
              final record = entry.value;
              final age = (record['ageDiagnosed'] ?? '').toString();
              final notes = (record['notes'] ?? '').toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 44, height: 44,
                      decoration: BoxDecoration(color: CareScheduleApp.cream, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.family_restroom_outlined, color: CareScheduleApp.sage)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text((record['condition'] ?? 'Condition').toString(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
                      const SizedBox(height: 4),
                      Text('Relation: ${(record['relation'] ?? '').toString()}',
                        style: const TextStyle(color: CareScheduleApp.mutedText)),
                      if (age.isNotEmpty) Text('Age diagnosed: $age', style: const TextStyle(color: CareScheduleApp.mutedText)),
                      if (notes.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(notes)),
                    ])),
                    IconButton(tooltip: 'Delete record', onPressed: () => _deleteRecord(index),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: CareScheduleApp.darkGreen)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFDCEBE5))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: CareScheduleApp.sage, width: 1.5)),
  );
}


// PREVENTIVE HEALTH TIPS


// AI HEALTH ASSISTANT — free local demo replies with voice-to-text input.

// MEDICINE INTERACTION CHECKER
// This screen retrieves medicine-name records from the official DailyMed API.
// It does NOT claim to calculate pairwise drug-drug interactions.

// Offline educational summaries for common medicines. Brand formulations can vary;
// users must confirm the active ingredient on the exact package.
Map<String, String>? _offlineMedicineInfo(String rawName) {
  final name = rawName.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  const database = <String, Map<String, String>>{
    'crocin advance': {
      'labelName': 'Crocin Advance (check pack for exact formulation)',
      'description': 'Commonly contains paracetamol and is used for temporary relief of pain and fever.',
      'warnings': 'Do not combine with other paracetamol-containing products unless a clinician says it is safe. Too much paracetamol can seriously damage the liver. Check the package strength and instructions.',
    },
    'crocin': {
      'labelName': 'Crocin (formulations vary)',
      'description': 'Many Crocin products contain paracetamol for temporary relief of pain and fever; confirm the active ingredient on your pack.',
      'warnings': 'Do not take multiple products containing paracetamol together without professional advice. Follow the exact package or prescription instructions.',
    },
    'meftal spas': {
      'labelName': 'Meftal-Spas (verify exact ingredients on your pack)',
      'description': 'Common Meftal-Spas formulations contain mefenamic acid and dicyclomine and may be prescribed for abdominal or menstrual cramps. Formulations can vary; confirm the active ingredients on your exact package.',
      'warnings': 'Mefenamic acid is an NSAID and may increase the risk of stomach ulcers or bleeding and kidney problems; it may not be suitable during pregnancy or for some medical conditions. Dicyclomine may cause dizziness, blurred vision or urinary problems and may be unsuitable for some people, including those with glaucoma. Ask a pharmacist or doctor before use, especially if taking other painkillers or if pregnant.',
    },
    'meftal-spas': {
      'labelName': 'Meftal-Spas (verify exact ingredients on your pack)',
      'description': 'Common Meftal-Spas formulations contain mefenamic acid and dicyclomine and may be prescribed for abdominal or menstrual cramps. Formulations can vary; confirm the active ingredients on your exact package.',
      'warnings': 'Mefenamic acid is an NSAID and may increase the risk of stomach ulcers or bleeding and kidney problems; it may not be suitable during pregnancy or for some medical conditions. Dicyclomine may cause dizziness, blurred vision or urinary problems and may be unsuitable for some people, including those with glaucoma. Ask a pharmacist or doctor before use, especially if taking other painkillers or if pregnant.',
    },
    'paracetamol': {
      'labelName': 'Paracetamol / acetaminophen',
      'description': 'A pain reliever and fever reducer. It does not treat the cause of an infection.',
      'warnings': 'Taking too much can cause severe liver damage. Check cold/flu medicines for the same ingredient and follow the prescribed or package dose.',
    },
    'dolo 650': {
      'labelName': 'Dolo 650 (check pack)',
      'description': 'Commonly contains paracetamol 650 mg and is used for temporary relief of pain and fever.',
      'warnings': 'Do not combine with other paracetamol products unless advised by a clinician. Verify the strength and instructions on the pack.',
    },
    'ibuprofen': {
      'labelName': 'Ibuprofen',
      'description': 'A non-steroidal anti-inflammatory medicine used for pain, fever and inflammation.',
      'warnings': 'May not be suitable with stomach ulcers/bleeding, kidney disease, some heart conditions, pregnancy, or blood thinners. Ask a pharmacist or doctor before use.',
    },
    'cetirizine': {
      'labelName': 'Cetirizine',
      'description': 'An antihistamine commonly used to relieve allergy symptoms such as sneezing, runny nose and itching.',
      'warnings': 'Can cause sleepiness. Avoid driving if affected and check with a clinician/pharmacist about alcohol or other sedating medicines.',
    },
    'azithromycin': {
      'labelName': 'Azithromycin',
      'description': 'A prescription antibiotic used for certain bacterial infections; it does not treat viral colds or flu.',
      'warnings': 'Use only as prescribed. It can interact with other medicines and may not be suitable for some heart-rhythm conditions.',
    },
    'amoxicillin': {
      'labelName': 'Amoxicillin',
      'description': 'A penicillin-type prescription antibiotic used for certain bacterial infections.',
      'warnings': 'Do not use if you have a serious penicillin allergy unless a clinician specifically assesses it. Use only as prescribed.',
    },
    'pantoprazole': {
      'labelName': 'Pantoprazole',
      'description': 'Reduces stomach acid and is used for conditions such as acid reflux, as prescribed.',
      'warnings': 'Check with a pharmacist or doctor about long-term use and interactions with your other medicines.',
    },
    'metformin': {
      'labelName': 'Metformin',
      'description': 'A prescription medicine used to help manage blood glucose in type 2 diabetes.',
      'warnings': 'Take as prescribed. Kidney function and acute illness can affect safety; consult your clinician before changing or stopping it.',
    },
    'omeprazole': {
      'labelName': 'Omeprazole',
      'description': 'Reduces stomach acid and is used for conditions such as acid reflux and heartburn.',
      'warnings': 'Check with a pharmacist or doctor if symptoms persist, if you take other medicines, or before long-term use. Follow the package or prescription directions.',
    },
    'ondansetron': {
      'labelName': 'Ondansetron',
      'description': 'A prescription medicine used to help prevent or treat nausea and vomiting in specific situations.',
      'warnings': 'Can affect heart rhythm in some people and may interact with other medicines. Use only as directed by a clinician.',
    },
    'diclofenac': {
      'labelName': 'Diclofenac',
      'description': 'A non-steroidal anti-inflammatory medicine used for pain and inflammation.',
      'warnings': 'May increase stomach bleeding, kidney and cardiovascular risks. Not suitable for everyone, including some people who are pregnant or take blood thinners. Ask a pharmacist or doctor before use.',
    },
    'levocetirizine': {
      'labelName': 'Levocetirizine',
      'description': 'An antihistamine used to relieve allergy symptoms such as sneezing, runny nose and itching.',
      'warnings': 'May cause sleepiness. Ask a pharmacist about alcohol, sedating medicines, kidney problems and whether it is appropriate for you.',
    },
    'montelukast': {
      'labelName': 'Montelukast',
      'description': 'A prescription medicine used in some people to help control asthma or allergy symptoms; it is not a rescue treatment for a sudden asthma attack.',
      'warnings': 'It carries a serious warning about possible mood or behavior changes, including suicidal thoughts. Discuss risks and alternatives with a clinician and seek medical advice promptly if such changes occur.',
    },
    'ors': {
      'labelName': 'Oral Rehydration Salts (ORS)',
      'description': 'A correctly prepared ORS solution helps replace water and salts lost through diarrhoea or vomiting.',
      'warnings': 'Mix the sachet with exactly the amount of safe water stated on its packet. Do not make it stronger or weaker. Seek urgent medical care for severe dehydration, confusion, inability to drink or worsening symptoms.',
    },
    'zinc': {
      'labelName': 'Zinc (check the exact product and strength)',
      'description': 'Zinc is a mineral supplement used when needed; its purpose depends on the person and formulation.',
      'warnings': 'Too much can cause nausea and, over time, copper deficiency. It can interfere with absorption of some antibiotics. Check the product strength and ask a pharmacist about timing with other medicines.',
    },
    'aspirin': {
      'labelName': 'Aspirin',
      'description': 'A medicine used for pain and fever in some situations; low-dose aspirin may be prescribed for specific cardiovascular reasons.',
      'warnings': 'Can increase bleeding and stomach-ulcer risk and is not suitable for everyone. Do not give to children or teenagers with viral illness unless a clinician specifically directs it. Ask a clinician before starting or stopping prescribed low-dose aspirin.',
    },
    'fexofenadine': {
      'labelName': 'Fexofenadine',
      'description': 'An antihistamine used to relieve allergy symptoms such as sneezing, runny nose and itchy or watery eyes.',
      'warnings': 'Follow the package directions and ask a pharmacist about interactions, including timing with antacids or fruit juices, and about use with kidney problems.',
    },
  };
  final key = database.keys.firstWhere(
    (key) => name == key || name.startsWith('$key ') || name.startsWith('$key('),
    orElse: () => '',
  );
  if (key.isEmpty) return null;
  final item = database[key]!;
  return {
    'medicine': rawName,
    'status': 'Basic offline information (not an official label lookup). Confirm the active ingredient and strength on your exact package.',
    'labelName': item['labelName']!,
    'description': item['description']!,
    'warnings': item['warnings']!,
    'interactions': 'This screen does not verify whether this medicine is safe to combine with the other medicine(s) entered.',
    'url': 'https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=${Uri.encodeQueryComponent(rawName)}',
    'source': 'Built-in general medicine information; verify with package/pharmacist',
  };
}

class MedicineInteractionCheckerScreen extends StatefulWidget {
  const MedicineInteractionCheckerScreen({super.key});

  @override
  State<MedicineInteractionCheckerScreen> createState() =>
      _MedicineInteractionCheckerScreenState();
}

class _MedicineInteractionCheckerScreenState
    extends State<MedicineInteractionCheckerScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  bool _loading = false;
  String? _message;
  List<Map<String, String>> _results = [];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _reviewMedicines() async {
    final names = _controllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (names.length < 2) {
      setState(() {
        _message = 'Enter at least two medicine names to review them together.';
        _results = [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
      _results = [];
    });

    final results = <Map<String, String>>[];

    try {
      for (final name in names) {
        // Prefer a useful offline summary for common medicines; this still works
        // when Google's free Gemini API or the official label service is unavailable.
        final offlineInfo = _offlineMedicineInfo(name);
        if (offlineInfo != null) {
          results.add(offlineInfo);
          continue;
        }
        final searchUrl =
            'https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=${Uri.encodeQueryComponent(name)}';

        try {
          // The backend endpoint expects the query parameter "name".
          final uri = Uri.parse(
            '${CareScheduleApi.baseUrl}/api/medicine-info',
          ).replace(queryParameters: {'name': name});

          final response = await http
              .get(uri, headers: CareScheduleApi.headers)
              .timeout(const Duration(seconds: 18));

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);

            if (decoded is Map<String, dynamic>) {
              final value = decoded;
              final matched = value['matched'] == true;
              final labelName =
                  (value['medicineName'] ?? '').toString().trim();
              final uses = value['uses'] is List
                  ? (value['uses'] as List)
                      .map((item) => item.toString().trim())
                      .where((item) => item.isNotEmpty)
                      .toList()
                      .join('\n')
                  : (value['uses'] ?? '').toString();
              final warnings = value['warnings'] is List
                  ? (value['warnings'] as List)
                      .map((item) => item.toString().trim())
                      .where((item) => item.isNotEmpty)
                      .toList()
                      .join('\n')
                  : (value['warnings'] ?? '').toString();
              final interactions = value['interactions'] is List
                  ? (value['interactions'] as List)
                      .map((item) => item.toString().trim())
                      .where((item) => item.isNotEmpty)
                      .toList()
                      .join('\n')
                  : (value['interactions'] ?? '').toString();

              String status;
              final message = (value['message'] ?? '').toString().trim();
              if (!matched) {
                status = message.isNotEmpty
                    ? message
                    : 'No matching official medicine-name record was found. Check the spelling or open the official search.';
              } else if (uses.isEmpty && warnings.isEmpty && interactions.isEmpty) {
                status = message.isNotEmpty
                    ? message
                    : 'A medicine-name match was found, but detailed label information was not available.';
              } else {
                status = 'Official label information retrieved. Review the details below.';
              }

              results.add({
                'medicine': name,
                'status': status,
                'labelName': labelName,
                'description': uses,
                'warnings': warnings,
                'interactions': interactions,
                'url': (value['labelUrl'] ?? searchUrl).toString(),
                'source': (value['source'] ?? 'Official drug-label information').toString(),
              });
              continue;
            }
          }

          results.add({
            'medicine': name,
            'status': 'No offline summary is available for this name and the online label lookup failed. Check the spelling and active ingredient, then ask a pharmacist to verify it.',
            'url': searchUrl,
            'source': 'DailyMed',
          });
        } catch (_) {
          results.add({
            'medicine': name,
            'status': 'No offline summary is available for this name, and the online lookup could not connect. Verify the active ingredient with a pharmacist.',
            'url': searchUrl,
            'source': 'DailyMed',
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _results = results;
        _message = 'Basic information is shown for common medicines, with official label lookup attempted for other names. This is not a complete drug-interaction check. A missing warning does not mean medicines are safe together; ask a pharmacist or doctor to review your full medicine list.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _message = 'The lookup could not be completed. Missing information does not mean medicines are safe together.';
        _results = names.map((name) => <String, String>{
          'medicine': name,
          'status': 'Open the official DailyMed search for this medicine.',
          'url': 'https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=${Uri.encodeQueryComponent(name)}',
          'source': 'DailyMed',
        }).toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBF8),
      appBar: AppBar(
        title: const Text('Medicine Interaction Checker'),
        backgroundColor: const Color(0xFFF7FBF8),
        foregroundColor: CareScheduleApp.darkGreen,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.health_and_safety_outlined, size: 32, color: Color(0xFF238B78)),
                    SizedBox(height: 10),
                    Text('Check your medicine information', style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF285747))),
                    SizedBox(height: 8),
                    Text('Enter the names exactly as written on the medicine package. We will look up official DailyMed label records for each medicine.'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ...List.generate(_controllers.length, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[index],
                  textInputAction: index == _controllers.length - 1 ? TextInputAction.done : TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Medicine ${index + 1}${index == 0 ? ' *' : ''}',
                    hintText: index == 0 ? 'e.g. medicine brand or generic name' : 'Enter another medicine',
                    prefixIcon: const Icon(Icons.medication_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              )),
              const SizedBox(height: 4),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _reviewMedicines,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF238B78),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded),
                  label: Text(_loading ? 'Looking up official labels...' : 'Review medicine labels'),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(_message!, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF285747))),
              ],
              ..._results.map((result) => Card(
                margin: const EdgeInsets.only(top: 12),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result['medicine'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if ((result['labelName'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Official label: ${result['labelName']}', style: const TextStyle(fontSize: 12, color: Color(0xFF527468))),
                      ],
                      const SizedBox(height: 6),
                      Text(result['status'] ?? ''),
                      if ((result['description'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text('What it is used for', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(result['description']!),
                      ],
                      if ((result['warnings'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text('Important label warnings', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(result['warnings']!),
                      ],
                      if ((result['interactions'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text('Drug interactions listed on label', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 3),
                        Text(result['interactions']!),
                      ],
                      const SizedBox(height: 8),
                      Text('Source: ${result['source'] ?? 'DailyMed'}', style: const TextStyle(fontSize: 11, color: Color(0xFF527468))),
                      const SizedBox(height: 4),
                      const Text('Open official label/search:', style: TextStyle(fontWeight: FontWeight.w600)),
                      SelectableText(result['url'] ?? '', style: const TextStyle(color: Color(0xFF238B78), decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8D3A5)),
                ),
                child: const Text(
                  'Important safety note: This first version finds official medicine-label records; it does NOT reliably determine whether two medicines interact, and no result here means “safe together.” Read the label’s Drug Interactions section and ask a pharmacist or doctor to check your full medicine list. Do not stop or change a prescribed medicine based on this screen.',
                  style: TextStyle(height: 1.45, color: Color(0xFF674D18)),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Data source: U.S. National Library of Medicine, DailyMed. The service provides current drug-label information, but this app does not yet have a validated comprehensive pairwise interaction database.',
                style: TextStyle(fontSize: 12, color: CareScheduleApp.mutedText, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AiHealthAssistantScreen extends StatefulWidget {
  const AiHealthAssistantScreen({super.key});

  @override
  State<AiHealthAssistantScreen> createState() => _AiHealthAssistantScreenState();
}

class _AiHealthAssistantScreenState extends State<AiHealthAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListening = false;
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text': 'Hi! I’m Care AI 🌿 I can help explain common health terms and prepare questions for your doctor. What would you like help with?'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (mounted && status == 'notListening') setState(() => _isListening = false);
        },
        onError: (_) {
          if (mounted) setState(() => _isListening = false);
        },
      );
      if (mounted) setState(() => _speechAvailable = available);
    } catch (_) {
      if (mounted) setState(() => _speechAvailable = false);
    }
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice input is unavailable. Check microphone permission and browser support.')),
      );
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      onResult: (result) {
        if (mounted) setState(() => _messageController.text = result.recognizedWords);
      },
    );
  }

  bool _isThinking = false;

  String _demoReply(String question) {
    final q = question.toLowerCase();

    if (q.contains('migraine') || q.contains('headache')) {
      return 'A migraine is a type of headache that can cause moderate to severe throbbing pain, often on one side of the head. Some people also feel nauseated or become sensitive to light and sound.\n\nSigns that may suggest a migraine include: repeated headache episodes, pain that gets worse with activity, nausea, and sensitivity to light or sound. Not every headache is a migraine, and I can’t diagnose you here.\n\nYou can rest in a quiet, dark room, drink water, and note when the headache starts and what symptoms you notice. If headaches are new, frequent, or affecting daily life, contact a healthcare professional. Seek urgent care for a sudden, extremely severe headache or headache with weakness, confusion, fainting, fever with a stiff neck, or trouble speaking.';
    }
    if (q.contains('fever') || q.contains('temperature')) {
      return 'A fever usually means your body temperature is higher than normal and can happen with infections or other illnesses. Rest, drink fluids, and monitor your temperature. Contact a healthcare professional if the fever is persistent, worsening, or you are worried. Seek urgent care for severe breathing difficulty, confusion, a seizure, or other serious symptoms.';
    }
    if (q.contains('cold') || q.contains('cough') || q.contains('sore throat')) {
      return 'A common cold can cause a runny or blocked nose, sneezing, cough, and sore throat. Rest, drink fluids, and consider warm drinks for comfort. If symptoms are severe, last longer than expected, or you have trouble breathing or chest pain, seek medical advice.';
    }
    if (q.contains('diabetes') || q.contains('blood sugar')) {
      return 'Diabetes is a condition in which blood glucose (sugar) stays too high because the body does not make enough insulin or cannot use it effectively. Possible symptoms include increased thirst, frequent urination, tiredness, and blurry vision, but some people have no obvious symptoms. A blood test is needed to check for diabetes. Please speak with a healthcare professional for testing and advice.';
    }
    if (q.contains('blood pressure') || q.contains('hypertension')) {
      return 'Blood pressure is the force of blood pushing against the walls of your arteries. High blood pressure often has no symptoms, so measuring it is the way to know. A single reading may not be enough to diagnose it; a healthcare professional can help interpret repeated readings.';
    }
    if (q.contains('period') || q.contains('menstrual')) {
      return 'Periods are part of the menstrual cycle. Mild cramps and changes in mood can happen, but severe pain, very heavy bleeding, fainting, or a sudden unusual change should be discussed with a healthcare professional. Tracking dates, pain, and flow can help you explain your symptoms at an appointment.';
    }
    if (q.contains('sleep') || q.contains('insomnia')) {
      return 'For better sleep, try keeping a regular sleep and wake time, reducing caffeine late in the day, limiting screens before bed, and keeping your room quiet and comfortable. If sleep problems continue or affect your daily life, consider speaking with a healthcare professional.';
    }
    if (q.contains('stress') || q.contains('anxiety')) {
      return 'Stress and anxiety can affect your thoughts, mood, sleep, and body. It may help to pause for slow breathing, take a short walk, talk to someone you trust, and break tasks into smaller steps. If these feelings are intense or persistent, a mental health professional can help.';
    }
    if (q.contains('water') || q.contains('hydration')) {
      return 'Staying hydrated supports normal body functions. Drink fluids regularly and pay attention to thirst, activity, and hot weather. Needs vary by person, and some medical conditions require specific fluid advice, so follow your clinician’s guidance if you have one.';
    }
    if (q.contains('nutrition') || q.contains('healthy food') || q.contains('balanced diet')) {
      return 'A balanced diet usually includes vegetables and fruit, whole grains, protein foods such as dal, beans, lentils, tofu or dairy if suitable, and healthy fats. Try to vary foods across the week and drink fluids regularly. Individual needs differ, especially with medical conditions or pregnancy, so a clinician or dietitian can personalize advice.';
    }
    if (q.contains('stomach pain') || q.contains('stomach ache') || q.contains('abdominal pain')) {
      return 'Stomach pain can have many causes, from gas or indigestion to conditions that need treatment. Notice where the pain is, when it started, and any vomiting, fever, bowel changes, or pregnancy possibility. Seek urgent medical care for severe or worsening pain, fainting, blood in vomit or stool, a hard/swollen abdomen, or pain with repeated vomiting.';
    }
    if (q.contains('allergy') || q.contains('sneezing') || q.contains('itchy')) {
      return 'Allergies can cause sneezing, a runny nose, itchy eyes, or skin symptoms. Avoiding a known trigger may help. Medicines differ and some cause drowsiness, so check with a pharmacist before using one. Swelling of the lips/tongue, trouble breathing, or faintness can be an emergency—seek emergency help immediately.';
    }
    if (q.contains('anemia') || q.contains('anaemia') || q.contains('iron deficiency')) {
      return 'Anemia means the blood may not carry enough oxygen, often because hemoglobin is low. It can cause tiredness, weakness, dizziness, or breathlessness, but symptoms alone cannot confirm it. A blood test and clinician review are needed; do not start iron supplements without appropriate advice because the cause matters.';
    }
    if (q.contains('thyroid')) {
      return 'The thyroid is a gland that helps regulate energy use and other body functions. An underactive thyroid may cause tiredness, feeling cold, or constipation; an overactive thyroid may cause palpitations, sweating, or weight changes. These symptoms have other causes too, so blood tests and clinician advice are needed.';
    }
    if (q.contains('medicine') || q.contains('medication') || q.contains('tablet') || q.contains('drug interaction')) {
      return 'Medicine safety depends on the exact product, active ingredient, strength, your health conditions, allergies, and other medicines. Check the package and ask a pharmacist or doctor before combining medicines or changing a dose. If you share the exact name and strength, I can provide general educational information, but I cannot confirm that a combination is safe.';
    }
    if (q.contains('emergency') || q.contains('chest pain') || q.contains('can\'t breathe') || q.contains('cannot breathe')) {
      return 'If you may be experiencing a medical emergency, contact your local emergency service or go to the nearest emergency department now. Do not wait for an online chat response.';
    }

    return 'I can share basic health information in this free demo. Try asking about migraine, fever, cold and cough, diabetes, blood pressure, periods, sleep, stress, or hydration.\n\nI’m not a doctor and this demo uses prepared responses rather than a live AI model. For personal symptoms, diagnosis, or treatment, please contact a qualified healthcare professional. If symptoms are severe or feel like an emergency, seek urgent medical care.';
  }

  Future<void> _sendMessage() async {
    final question = _messageController.text.trim();
    if (question.isEmpty || _isThinking) return;

    setState(() {
      _messages.add({'role': 'user', 'text': question});
      _messageController.clear();
      _isThinking = true;
    });
    _scrollToLatest();

    try {
      // Send the conversation to the backend; do not silently return a canned demo reply.
      final conversation = _messages
          .where((message) =>
              (message['role'] == 'user' || message['role'] == 'assistant') &&
              message['text'] is String)
          .toList();
      final recentConversation = conversation.length > 12
          ? conversation.sublist(conversation.length - 12)
          : conversation;

      final response = await http
          .post(
            Uri.parse('${CareScheduleApi.baseUrl}/api/ai-chat'),
            headers: CareScheduleApi.headers,
            body: jsonEncode({
              'messages': recentConversation
                  .map((message) => {
                        'role': message['role'],
                        'text': message['text'],
                      })
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 35));

      Map<String, dynamic> data = {};
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}

      if (response.statusCode != 200) {
        final message = (data['message'] ?? data['error'] ??
                'The AI service returned HTTP ${response.statusCode}.')
            .toString();
        throw Exception(message);
      }

      final reply = (data['reply'] ?? data['text'] ?? '').toString().trim();
      if (reply.isEmpty) {
        throw Exception('The backend returned an empty AI answer.');
      }
      if (!mounted) return;
      setState(() => _messages.add({'role': 'assistant', 'text': reply}));
    } catch (error) {
      if (!mounted) return;
      // No-cost fallback: keep the assistant useful when the hosted AI quota is unavailable.
      final offlineReply = _demoReply(question);
      setState(() => _messages.add({
            'role': 'assistant',
            'text': '$offlineReply\n\n(Offline Care AI: live AI access is currently unavailable. This is general health education, not a diagnosis.)',
          }));
    } finally {
      if (mounted) setState(() => _isThinking = false);
      _scrollToLatest();
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Icon(Icons.spa_rounded, color: CareScheduleApp.sage),
          SizedBox(width: 10),
          Text('Care AI Assistant'),
        ]),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CareScheduleApp.softGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'For general education only — not a diagnosis or emergency service. For severe or sudden symptoms, seek urgent medical care.',
                  style: TextStyle(color: CareScheduleApp.darkGreen, fontSize: 12),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isThinking && index == _messages.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: CareScheduleApp.softGreen),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('Care AI is thinking...', style: TextStyle(color: CareScheduleApp.darkGreen)),
                          ]),
                        ),
                      );
                    }
                    final message = _messages[index];
                    final isUser = message['role'] == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                        decoration: BoxDecoration(
                          color: isUser ? CareScheduleApp.sage : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: isUser ? null : Border.all(color: CareScheduleApp.softGreen),
                        ),
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            height: 1.4,
                            color: isUser ? Colors.white : CareScheduleApp.darkGreen,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  IconButton.filledTonal(
                    tooltip: _isListening ? 'Stop voice input' : 'Speak your question',
                    onPressed: _toggleListening,
                    icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_none_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _isListening ? 'Listening… speak now' : 'Ask a health question…',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide(color: CareScheduleApp.softGreen)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide(color: CareScheduleApp.softGreen)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Send message',
                    onPressed: _sendMessage,
                    style: IconButton.styleFrom(backgroundColor: CareScheduleApp.sage, foregroundColor: Colors.white),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}


// PRESCRIPTION SCANNER
// This screen deliberately requires the user to review/edit medicine names.
// OCR engine integration is separate; the screen never pretends guesses are confirmed.
class PrescriptionScannerScreen extends StatefulWidget {
  const PrescriptionScannerScreen({super.key});
  @override
  State<PrescriptionScannerScreen> createState() => _PrescriptionScannerScreenState();
}

class _PrescriptionScannerScreenState extends State<PrescriptionScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _photoBytes;
  String? _photoName;
  String? _photoPath;
  final List<TextEditingController> _medicineControllers = [TextEditingController()];
  bool _reviewed = false;
  bool _isAnalyzing = false;
  String? _analysisMessage;

  Future<void> _analyzePrescription() async {
    if (_photoBytes == null || _photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload or take a prescription photo first.')));
      return;
    }
    setState(() { _isAnalyzing = true; _analysisMessage = null; _reviewed = false; });
    TextRecognizer? recognizer;
    try {
      // First use on-device OCR so basic printed text can be read without any API key.
      recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(InputImage.fromFilePath(_photoPath!));
      final lines = recognized.blocks
          .expand((block) => block.lines)
          .map((line) => line.text.trim())
          .where((line) => line.length >= 3 && line.length <= 90)
          .toList();

      if (lines.isNotEmpty) {
        for (final controller in _medicineControllers) { controller.dispose(); }
        _medicineControllers
          ..clear()
          ..addAll(lines.map((line) => TextEditingController(text: line)));
        if (mounted) setState(() => _analysisMessage = 'Offline text recognition found these lines. They may include doctor details or instructions, and handwritten medicine names may be misread. Edit the list so it contains only the correct medicine names, then confirm with a pharmacist.');
        return;
      }

      // No readable text found: try the optional online recognizer if the project has access.
      final response = await http.post(
        Uri.parse('${CareScheduleApi.baseUrl}/api/prescription-ocr'),
        headers: CareScheduleApi.headers,
        body: jsonEncode({'imageBase64': base64Encode(_photoBytes!), 'fileName': _photoName ?? 'prescription.jpg'}),
      ).timeout(const Duration(seconds: 45));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200) {
        throw Exception(data['message']?.toString() ?? 'Offline text recognition could not read this photo. Please type the names manually.');
      }
      final rawNames = data['medicines'];
      final names = rawNames is List ? rawNames.map((e) => e is Map ? (e['name'] ?? '').toString().trim() : e.toString().trim()).where((e) => e.isNotEmpty).toList() : <String>[];
      if (names.isEmpty) {
        setState(() => _analysisMessage = 'No medicine names could be read confidently. Please type them in manually and confirm with your pharmacist.');
      } else {
        for (final controller in _medicineControllers) { controller.dispose(); }
        _medicineControllers
          ..clear()
          ..addAll(names.map((name) => TextEditingController(text: name)));
        setState(() => _analysisMessage = 'Possible medicine names detected. Check every name against the original prescription before confirming.');
      }
    } catch (error) {
      if (mounted) {
        final detail = error.toString().replaceFirst('Exception: ', '');
        final pluginMissing = detail.contains('MissingPluginException') || detail.contains('No implementation found');
        setState(() => _analysisMessage = pluginMissing
            ? 'Text recognition plugin is not loaded in this app build. Stop the app completely, then run flutter clean, flutter pub get, and flutter run again (do not use hot reload). If it still fails, check that google_mlkit_text_recognition is under dependencies in pubspec.yaml. You can type the medicine name below meanwhile.'
            : 'Offline text recognition could not read this image. Handwriting may not be supported. Please enter the medicine names manually and verify them with a pharmacist. Details: $detail');
      }
    } finally {
      await recognizer?.close();
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _choosePhoto(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85);
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _photoName = image.name;
        _photoPath = image.path;
        _reviewed = false;
        _analysisMessage = null;
      });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the image. Please try another photo.')));
    }
  }

  void _addMedicineField() => setState(() => _medicineControllers.add(TextEditingController()));

  void _saveReviewedList() {
    final names = _medicineControllers.map((c) => c.text.trim()).where((name) => name.isNotEmpty).toList();
    if (_photoBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload a prescription photo first.')));
      return;
    }
    if (names.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter and review at least one medicine name.')));
      return;
    }
    setState(() => _reviewed = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reviewed medicine list saved in this screen for now. Verify the prescription with your pharmacist or doctor.')));
  }

  @override
  void dispose() {
    for (final controller in _medicineControllers) { controller.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Prescription Scanner')),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: CareScheduleApp.softGreen, borderRadius: BorderRadius.circular(18)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.document_scanner_outlined, color: CareScheduleApp.darkGreen, size: 30), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Scan a prescription', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)), SizedBox(height: 5), Text('Upload a clear photo, then review and correct every medicine name before saving.', style: TextStyle(color: CareScheduleApp.darkGreen, height: 1.4))]))])),
      const SizedBox(height: 16),
      Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _choosePhoto(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Upload photo'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: () => _choosePhoto(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Take photo')))]),
      if (_photoBytes != null) ...[
        const SizedBox(height: 14),
        ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(_photoBytes!, height: 240, fit: BoxFit.contain)),
        const SizedBox(height: 6), Text(_photoName ?? 'Prescription photo', style: const TextStyle(color: CareScheduleApp.mutedText)),
      ],
      const SizedBox(height: 12),
      SizedBox(height: 48, child: OutlinedButton.icon(onPressed: _isAnalyzing ? null : _analyzePrescription, icon: _isAnalyzing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome_outlined), label: Text(_isAnalyzing ? 'Analysing handwriting…' : 'Analyse prescription handwriting'))),
      if (_analysisMessage != null) ...[const SizedBox(height: 8), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: CareScheduleApp.softGreen.withOpacity(0.45), borderRadius: BorderRadius.circular(12)), child: Text(_analysisMessage!, style: const TextStyle(color: CareScheduleApp.darkGreen, height: 1.4)))],
      const SizedBox(height: 20),
      const Text('Review medicine names', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
      const SizedBox(height: 6),
      const Text('AI may suggest possible medicine names from the image, but handwriting can be misread. Edit every name and confirm it with your pharmacist or doctor before saving.', style: TextStyle(color: CareScheduleApp.mutedText, height: 1.4)),
      const SizedBox(height: 12),
      ..._medicineControllers.asMap().entries.map((entry) => Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: entry.value, decoration: InputDecoration(labelText: 'Possible medicine ${entry.key + 1}', hintText: 'Type the name exactly as written', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))))),
      Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: _addMedicineField, icon: const Icon(Icons.add), label: const Text('Add another medicine'))),
      const SizedBox(height: 8),
      SizedBox(height: 50, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: CareScheduleApp.sage, foregroundColor: Colors.white), onPressed: _saveReviewedList, icon: const Icon(Icons.fact_check_outlined), label: const Text('Confirm reviewed list'))),
      if (_reviewed) Container(margin: const EdgeInsets.only(top: 14), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)), child: Text('Reviewed names: ${_medicineControllers.map((c) => c.text.trim()).where((x) => x.isNotEmpty).join(', ')}', style: const TextStyle(color: CareScheduleApp.darkGreen))),
      const SizedBox(height: 12),
      const Text('Safety: Never use an uncertain reading to decide a dose or start a medicine. Confirm unclear handwriting with the prescribing clinician or pharmacist.', style: TextStyle(fontSize: 12, color: CareScheduleApp.mutedText, height: 1.45)),
    ]))),
  );
}

// MEDICAL REPORTS
class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});
  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> _reports = [];
  final List<String> _types = [
    'Blood Test',
    'X-Ray / Scan',
    'Prescription',
    'Discharge Summary',
    'Other',
  ];

  Future<void> _addReport() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;

    String type = _types.first;
    final dateController = TextEditingController(
      text: DateTime.now().toIso8601String().substring(0, 10),
    );
    final titleController = TextEditingController(text: image.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Report name'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Report type'),
                  items: _types
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => type = value);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Report date (YYYY-MM-DD)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Add report'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _reports.insert(0, {
          'name': titleController.text.trim().isEmpty
              ? image.name
              : titleController.text.trim(),
          'type': type,
          'date': dateController.text.trim(),
          'bytes': bytes,
        });
      });
    }

    titleController.dispose();
    dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        actions: [
          IconButton(
            tooltip: 'Upload report photo',
            onPressed: _addReport,
            icon: const Icon(Icons.add_a_photo_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReport,
        backgroundColor: CareScheduleApp.sage,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file_outlined),
        label: const Text('Upload report'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: _reports.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(22),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CareScheduleApp.softGreen),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 48,
                            color: CareScheduleApp.sage,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Your medical reports',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CareScheduleApp.darkGreen,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Upload report photos, add the report date and type, and keep them organised here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: CareScheduleApp.mutedText,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Currently, reports are kept in this screen while it is open. Database and PDF storage can be connected as a later step.',
                      style: TextStyle(
                        color: CareScheduleApp.mutedText,
                        height: 1.4,
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            report['bytes'] as Uint8List,
                            width: 54,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          report['name'] as String,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: CareScheduleApp.darkGreen,
                          ),
                        ),
                        subtitle: Text('${report['type']} • ${report['date']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() => _reports.removeAt(index)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

// EMERGENCY SOS
// This screen opens the phone dialer after confirmation; it does not silently call anyone.
class _EmergencySosHomeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmergencySosHomeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0EF),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const Icon(Icons.sos_rounded, color: Color(0xFFB42318), size: 36),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Emergency SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF8E1B16))),
              SizedBox(height: 3),
              Text('Quick access to emergency services or your trusted contact.', style: TextStyle(color: Color(0xFF75413D))),
            ])),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB42318)),
          ]),
        ),
      ),
    );
  }
}

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final List<Map<String, String>> _contacts = [];
  final TextEditingController _contactName = TextEditingController();
  final TextEditingController _contactPhone = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('careschedule_sos_contacts');
    List<Map<String, String>> loaded = [];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        loaded = decoded.map((item) => Map<String, String>.from(item as Map)).toList();
      } catch (_) {
        loaded = [];
      }
    } else {
      // Migrate the single-contact version if one was saved previously.
      final oldName = prefs.getString('careschedule_sos_contact_name') ?? '';
      final oldPhone = prefs.getString('careschedule_sos_contact_phone') ?? '';
      if (oldPhone.isNotEmpty) {
        loaded.add({'name': oldName.isEmpty ? 'Trusted contact' : oldName, 'phone': oldPhone});
        await prefs.setString('careschedule_sos_contacts', jsonEncode(loaded));
      }
    }
    if (!mounted) return;
    setState(() {
      _contacts
        ..clear()
        ..addAll(loaded.take(3));
    });
  }

  Future<void> _saveContacts() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('careschedule_sos_contacts', jsonEncode(_contacts));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trusted contacts saved on this device.')),
    );
  }

  Future<void> _addContact() async {
    if (_contacts.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can save up to 3 trusted contacts.')),
      );
      return;
    }
    _contactName.clear();
    _contactPhone.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add trusted contact ${_contacts.length + 1}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _contactName, textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Contact name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _contactPhone, keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone number', hintText: '+91...', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Add contact')),
        ],
      ),
    );
    if (result != true || !mounted) return;
    final phone = _contactPhone.text.trim();
    if (phone.isEmpty || !RegExp(r'^[+0-9()\-\s]{7,20}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number.')),
      );
      return;
    }
    setState(() => _contacts.add({
      'name': _contactName.text.trim().isEmpty ? 'Trusted contact' : _contactName.text.trim(),
      'phone': phone,
    }));
    await _saveContacts();
  }

  Future<void> _removeContact(int index) async {
    setState(() => _contacts.removeAt(index));
    await _saveContacts();
  }

  Future<void> _openDialer(String number, String label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Call $label?'),
        content: Text('CareSchedule will open your phone dialer for $number. Check the number and tap call in the dialer. It will not call automatically.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Open dialer')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final uri = Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'[^+0-9]'), ''));
    try {
      final opened = await launchUrl(uri);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the phone dialer.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the phone dialer.')));
    }
  }

  Future<void> _sendEmergencyMessage(String number, String name) async {
    const message = 'Emergency help needed. I may need assistance. Please call me as soon as possible. If you cannot reach me and believe I am in immediate danger, please contact emergency services.';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Prepare message for $name?'),
        content: const Text('CareSchedule will open your SMS app with a pre-filled message. Review it and press Send yourself. The app does not send messages automatically or share your GPS location.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Open messages')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final cleanNumber = number.replaceAll(RegExp(r'[^+0-9]'), '');
    final uri = Uri(scheme: 'sms', path: cleanNumber, queryParameters: {'body': message});
    try {
      final opened = await launchUrl(uri);
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open your SMS app on this device.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open your SMS app on this device.')));
    }
  }

  @override
  void dispose() {
    _contactName.dispose();
    _contactPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFFFF0EF), borderRadius: BorderRadius.circular(20)),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.health_and_safety_rounded, color: Color(0xFFB42318), size: 42),
            SizedBox(height: 10),
            Text('Need urgent help?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF8E1B16))),
            SizedBox(height: 6),
            Text('Call emergency services or contact one of your trusted people. Calls and messages require your confirmation.', style: TextStyle(height: 1.4, color: Color(0xFF75413D))),
          ]),
        ),
        const SizedBox(height: 18),
        SizedBox(height: 54, child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB42318), foregroundColor: Colors.white),
          onPressed: () => _openDialer('112', 'emergency services (112)'),
          icon: const Icon(Icons.call_rounded),
          label: const Text('Call emergency services — 112', style: TextStyle(fontWeight: FontWeight.bold)),
        )),
        const SizedBox(height: 24),
        Row(children: [
          const Expanded(child: Text('Trusted contacts', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen))),
          Text('${_contacts.length}/3', style: const TextStyle(color: CareScheduleApp.mutedText)),
        ]),
        const SizedBox(height: 6),
        const Text('Add up to 3 family members or trusted people. Details are saved on this device.', style: TextStyle(color: CareScheduleApp.mutedText)),
        const SizedBox(height: 12),
        if (_contacts.isEmpty)
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Text('No trusted contacts added yet. Add at least one person you can contact in an emergency.', style: TextStyle(color: CareScheduleApp.mutedText))),
        ..._contacts.asMap().entries.map((entry) {
          final index = entry.key;
          final contact = entry.value;
          final name = contact['name'] ?? 'Trusted contact';
          final phone = contact['phone'] ?? '';
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const CircleAvatar(backgroundColor: CareScheduleApp.cream, child: Icon(Icons.person_outline_rounded, color: CareScheduleApp.sage)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
                  Text(phone, style: const TextStyle(color: CareScheduleApp.mutedText)),
                ])),
                IconButton(tooltip: 'Remove contact', onPressed: () => _removeContact(index), icon: const Icon(Icons.delete_outline_rounded)),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: () => _openDialer(phone, name), icon: const Icon(Icons.call_outlined), label: const Text('Call'))),
                const SizedBox(width: 8),
                Expanded(child: FilledButton.icon(onPressed: () => _sendEmergencyMessage(phone, name), icon: const Icon(Icons.sms_outlined), label: const Text('Send message'))),
              ]),
            ])),
          );
        }),
        if (_contacts.length < 3)
          OutlinedButton.icon(onPressed: _saving ? null : _addContact, icon: const Icon(Icons.person_add_alt_1_rounded), label: Text('Add trusted contact (${_contacts.length + 1}/3)')),
        const SizedBox(height: 10),
        OutlinedButton.icon(onPressed: _saving ? null : _saveContacts, icon: const Icon(Icons.save_outlined), label: Text(_saving ? 'Saving...' : 'Save trusted contacts')),
        const SizedBox(height: 18),
        const Text('Safety note: Messages open in your SMS app with text filled in; you must press Send. CareSchedule does not automatically call, send SMS, or share GPS location. In an immediate emergency in India, call 112.', style: TextStyle(fontSize: 12, color: CareScheduleApp.mutedText, height: 1.45)),
      ]),
    );
  }
}

// NOTIFICATIONS AND POP-UP REMINDERS
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _reminders = [];
  Timer? _reminderTicker;

  bool _reminderDialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Check due reminders outside build(). Opening dialogs from build() can
    // trigger repeated route/widget rebuilds and Flutter assertion errors.
    _reminderTicker = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkDueReminders();
    });
  }

  void _checkDueReminders() {
    if (!mounted || _reminderDialogShowing || _reminders.isEmpty) return;
    final now = DateTime.now();
    final nowKey = '${now.year}-${now.month}-${now.day}-${now.hour}:${now.minute}';

    Map<String, dynamic>? dueReminder;
    for (final reminder in _reminders) {
      final time = reminder['time'] as TimeOfDay;
      if (time.hour == now.hour &&
          time.minute == now.minute &&
          reminder['lastShown'] != nowKey) {
        reminder['lastShown'] = nowKey;
        dueReminder = reminder;
        break;
      }
    }
    if (dueReminder == null) return;

    final reminder = dueReminder;
    _reminderDialogShowing = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.notifications_active_rounded,
            color: CareScheduleApp.sage, size: 34),
        title: Text(reminder['title'] as String),
        content: Text(
          reminder['kind'] == 'Medicine'
              ? 'It is time to follow your prescribed medicine schedule. Check the prescription label before taking it.'
              : reminder['kind'] == 'Doctor visit'
                  ? 'Please check your appointment details and prepare for your visit.'
                  : 'A gentle reminder to review your planned health check.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    ).whenComplete(() {
      _reminderDialogShowing = false;
    });
  }

  @override
  void dispose() {
    _reminderTicker?.cancel();
    super.dispose();
  }

  final List<Map<String, String>> _updates = [
    {'title': 'Medicine reminder', 'message': 'Add a reminder for the time your doctor prescribed.'},
    {'title': 'Doctor appointment', 'message': 'Add your appointment time so CareSchedule can remind you while the app is open.'},
    {'title': 'Medical reports', 'message': 'Keep new lab reports organised by date and type.'},
  ];

  Future<void> _addReminder() async {
    final title = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    String kind = 'Medicine';
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text('Create a care reminder'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Reminder title', hintText: 'e.g. Take prescribed medicine')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: kind, decoration: const InputDecoration(labelText: 'Reminder type'), items: const [DropdownMenuItem(value: 'Medicine', child: Text('Medicine')), DropdownMenuItem(value: 'Doctor visit', child: Text('Doctor visit')), DropdownMenuItem(value: 'Health check', child: Text('Health check'))], onChanged: (v) { if (v != null) setDialogState(() => kind = v); }),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () async { final t = await showTimePicker(context: context, initialTime: selectedTime); if (t != null) setDialogState(() => selectedTime = t); }, icon: const Icon(Icons.access_time), label: Text('Reminder time: ${selectedTime.format(context)}')),
      ])),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Save reminder'))],
    )));
    if (result == true && mounted) {
      final name = title.text.trim().isEmpty ? kind == 'Medicine' ? 'Time to take your prescribed medicine' : kind == 'Doctor visit' ? 'Time to prepare for your doctor visit' : 'Time for your health check' : title.text.trim();
      setState(() => _reminders.add({'title': name, 'kind': kind, 'time': selectedTime, 'lastShown': ''}));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder saved for this session. Keep CareSchedule open at the reminder time for its pop-up.')));
    }
    title.dispose();
  }

  @override
  void didChangeDependencies() { super.didChangeDependencies(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [IconButton(tooltip: 'Add reminder', onPressed: _addReminder, icon: const Icon(Icons.add_alert_rounded))]),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addReminder, backgroundColor: CareScheduleApp.sage, foregroundColor: Colors.white, icon: const Icon(Icons.alarm_add_rounded), label: const Text('Add reminder')),
      body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 650), child: ListView(padding: const EdgeInsets.all(18), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: CareScheduleApp.softGreen, borderRadius: BorderRadius.circular(18)), child: const Row(children: [Icon(Icons.notifications_active_outlined, color: CareScheduleApp.darkGreen, size: 30), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Your care reminders', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)), SizedBox(height: 4), Text('Create gentle reminders for medicines, doctor visits and health checks.', style: TextStyle(color: CareScheduleApp.darkGreen))]))])),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('My reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)), Text('${_reminders.length} saved', style: const TextStyle(color: CareScheduleApp.mutedText))]),
        if (_reminders.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('No reminders yet. Tap “Add reminder” to create one.', style: TextStyle(color: CareScheduleApp.mutedText))),
        ..._reminders.asMap().entries.map((entry) { final item = entry.value; return Card(color: Colors.white, child: ListTile(leading: CircleAvatar(backgroundColor: CareScheduleApp.cream, child: Icon(item['kind'] == 'Medicine' ? Icons.medication_outlined : item['kind'] == 'Doctor visit' ? Icons.calendar_month_outlined : Icons.health_and_safety_outlined, color: CareScheduleApp.sage)), title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)), subtitle: Text('${item['kind']} • ${(item['time'] as TimeOfDay).format(context)}'), trailing: IconButton(tooltip: 'Delete reminder', onPressed: () => setState(() => _reminders.removeAt(entry.key)), icon: const Icon(Icons.delete_outline)))) ;}),
        const SizedBox(height: 18),
        const Text('Care updates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
        const SizedBox(height: 8),
        ..._updates.map((n) => Card(color: Colors.white, margin: const EdgeInsets.only(bottom: 10), child: ListTile(isThreeLine: true, leading: CircleAvatar(backgroundColor: CareScheduleApp.cream, child: Icon(n['title'] == 'Medicine reminder' ? Icons.medication_outlined : n['title'] == 'Doctor appointment' ? Icons.calendar_month_outlined : Icons.description_outlined, color: CareScheduleApp.sage)), title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)), subtitle: Text(n['message']!)))),
        const SizedBox(height: 8),
        const Text('Reminder pop-ups work while this screen is open and the app is running. They are not operating-system notifications and will not alert you after closing the browser/app.', style: TextStyle(fontSize: 12, color: CareScheduleApp.mutedText, height: 1.45)),
      ]))),
    );
  }
}

class PreventiveHealthTipsScreen extends StatelessWidget {
  const PreventiveHealthTipsScreen({super.key});

  static const List<Map<String, String>> _tips = [
    {'category': 'Daily habits', 'title': 'Keep water nearby', 'body': 'Drink water regularly through the day. Your needs can change with weather, activity, and medical conditions.'},
    {'category': 'Daily habits', 'title': 'Make movement part of your day', 'body': 'Try a walk, gentle stretching, or another activity that suits your ability. Start slowly if you are not used to exercise.'},
    {'category': 'Food', 'title': 'Aim for balanced meals', 'body': 'Include a variety of vegetables or fruit, protein foods, and whole grains when available. There is no single perfect diet for everyone.'},
    {'category': 'Sleep', 'title': 'Keep a steady sleep routine', 'body': 'Try going to bed and waking up at similar times. Reduce bright screens close to bedtime if they make it harder to sleep.'},
    {'category': 'Prevention', 'title': 'Keep check-ups up to date', 'body': 'Ask a qualified healthcare professional which screenings and vaccinations are suitable for your age, history, and needs.'},
    {'category': 'Medicines', 'title': 'Use medicines as prescribed', 'body': 'Follow the label and your clinician’s instructions. Ask a pharmacist or doctor before changing a dose or combining medicines.'},
    {'category': 'Mental wellbeing', 'title': 'Make room for a pause', 'body': 'Short breaks, slow breathing, and talking to someone you trust may help you manage everyday stress.'},
    {'category': 'Family history', 'title': 'Share family history with your doctor', 'body': 'Tell your clinician about important conditions in close relatives. Family history can guide a conversation, but it does not determine your future health.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preventive Health Tips 🌿')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: CareScheduleApp.softGreen, borderRadius: BorderRadius.circular(22)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.health_and_safety_rounded, size: 34, color: CareScheduleApp.darkGreen),
              SizedBox(height: 10),
              Text('Small habits, steady care', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
              SizedBox(height: 6),
              Text('Simple reminders to support everyday wellbeing. Choose what is realistic for you.', style: TextStyle(color: CareScheduleApp.darkGreen, height: 1.45)),
            ]),
          ),
          const SizedBox(height: 16),
          ..._tips.map((tip) => Card(
            elevation: 0,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: CareScheduleApp.cream, borderRadius: BorderRadius.circular(20)), child: Text(tip['category']!, style: const TextStyle(fontSize: 12, color: CareScheduleApp.sage, fontWeight: FontWeight.w600))),
                const SizedBox(height: 10),
                Text(tip['title']!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: CareScheduleApp.darkGreen)),
                const SizedBox(height: 6),
                Text(tip['body']!, style: const TextStyle(height: 1.45, color: CareScheduleApp.mutedText)),
              ]),
            ),
          )),
          const SizedBox(height: 4),
          const Text('These are general wellbeing tips, not personal medical advice. For symptoms, treatment decisions, or individual recommendations, consult a qualified healthcare professional.', style: TextStyle(fontSize: 12, height: 1.45, color: CareScheduleApp.mutedText)),
        ],
      ),
    );
  }
}