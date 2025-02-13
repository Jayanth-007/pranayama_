import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase core package
import 'utils/routes.dart'; // Import the centralized routes file (AppRoutes)
import 'start.dart'; // Assuming this is your StartScreen widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that Firebase is initialized before the app starts
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      title: 'Breathing Techniques App',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Theme color
      ),
      initialRoute: AppRoutes.start, // Set initial route to StartScreen
      routes: AppRoutes.routes, // Register all routes from AppRoutes
    );
  }
}
