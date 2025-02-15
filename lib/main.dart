import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meditation_app/greeting/login_page.dart';
import 'utils/routes.dart';
import 'relax.dart'; // Your home screen (when logged in)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
