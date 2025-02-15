// bhramari_pranayama_page.dart
import 'package:flutter/material.dart';

class BhramariPranayamaPage extends StatelessWidget {
  const BhramariPranayamaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bhramari Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Bhramari Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
