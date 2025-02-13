import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:meditation_app/relax.dart'; // Relax page
import 'greet.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Sign in the user with Firebase Authentication
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // If successful, navigate to the RelaxPage
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  RelaxScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                // Fade transition
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        });
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        // Handle errors like incorrect email/password
        String errorMessage = "An error occurred. Please try again.";
        if (e.code == 'user-not-found') {
          errorMessage = "No user found for that email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Wrong password provided for that user.";
        }
        _showErrorDialog(errorMessage);
      }
    } else {
      setState(() {
        _isSubmitting = false;
      });
      _showErrorDialog("Please enter both email and password.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
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
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSubmitting ? null : _handleLogin,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Login', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Navigate to signup page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => NameInputPage()),
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
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
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.black54),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}
