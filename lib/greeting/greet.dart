import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'login_page.dart'; // Import the LoginPage
import 'greeting_page.dart';  // Import GreetingPage


class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveToFirestore(String name, String email, String password, String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'password': password, // Ideally, hash this password before storing it
        'createdAt': DateTime.now(),
      });
      print('User saved to Firestore!');
    } catch (e) {
      print('Error saving user to Firestore: $e');
    }
  }

  // Email validation function
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  void _handleSubmit() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      if (_isValidEmail(email)) {
        setState(() {
          _isSubmitting = true;
        });

        try {
          // Register user with Firebase Authentication
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          String userId = userCredential.user!.uid;

          // Save user to Firestore
          await _saveToFirestore(name, email, password, userId);

          // Navigate to login page after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => GreetingPage(userName: name),),
          );
        } catch (e) {
          print("Error during registration: $e");
          setState(() {
            _isSubmitting = false;
          });
        }
      } else {
        print("Invalid email format");
      }
    } else {
      print("All fields are required!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Please enter your details to create an account',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildInputField(_nameController, 'Enter your name'),
                  SizedBox(height: 20),
                  _buildInputField(_emailController, 'Enter your email'),
                  SizedBox(height: 20),
                  _buildInputField(
                    _passwordController,
                    'Enter your password',
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.blueAccent)
                        : Text(
                      'Submit',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String hintText,
      {bool obscureText = false}) {
    return AnimatedOpacity(
      opacity: _isSubmitting ? 0.5 : 1.0,
      duration: Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
