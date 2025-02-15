import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/relax.dart';

class NameInputPage extends StatefulWidget {
  const NameInputPage({Key? key}) : super(key: key);

  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _isSubmitting = true);
    try {
      // Register user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;
      String name = _nameController.text.trim();

      // Save user data to Firestore
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': _emailController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Debugging output
      print("User registered successfully: $userId");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration Successful!")),
      );

      // Navigate to home page
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RelaxScreen()),
      );
    } catch (e) {
      print("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
    setState(() => _isSubmitting = false);
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, "Name"),
              _buildTextField(_emailController, "Email"),
              _buildTextField(_passwordController, "Password", isPassword: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown[700],
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
