import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditation_app/greeting/login_page.dart';
import 'utils/routes.dart';
import 'relax.dart'; // Your home screen (when logged in)
import 'package:shared_preferences/shared_preferences.dart'; // For local tracking

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

/// Convert your top-level widget to a StatefulWidget so that it can observe lifecycle events.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _logDailyUsage();
  }

  @override
  void dispose() {
    _logSessionTime();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// This method is called whenever the app’s lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _logSessionTime();
    } else if (state == AppLifecycleState.resumed) {
      _sessionStart = DateTime.now();
      _logDailyUsage();
    }
  }

  /// Calculate the session duration and store it locally.
  Future<void> _logSessionTime() async {
    if (_sessionStart == null) return;
    final sessionEnd = DateTime.now();
    final sessionDuration = sessionEnd.difference(_sessionStart!);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int totalSeconds = prefs.getInt('total_usage_seconds') ?? 0;
    totalSeconds += sessionDuration.inSeconds;
    await prefs.setInt('total_usage_seconds', totalSeconds);

    print('Logged session of ${sessionDuration.inSeconds} seconds. Total usage: $totalSeconds seconds.');
  }

  /// Record the current day as a day the app was used.
  Future<void> _logDailyUsage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10); // Format: YYYY-MM-DD
    List<String> daysUsed = prefs.getStringList('days_used') ?? [];

    if (!daysUsed.contains(today)) {
      daysUsed.add(today);
      await prefs.setStringList('days_used', daysUsed);
      print('New day logged: $today');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Breathing Techniques App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      // Instead of using initialRoute, use the home property with an AuthWrapper:
      home: AuthWrapper(),
      routes: AppRoutes.routes,
    );
  }
}

/// This widget checks the auth state and routes the user accordingly.
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // When the connection is active, check if the user is logged in.
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            // Not logged in: show the login page.
            return LoginPage();
          } else {
            // Logged in: show the home page (RelaxScreen).
            return RelaxScreen();
          }
        }
        // Otherwise, display a loading indicator.
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
