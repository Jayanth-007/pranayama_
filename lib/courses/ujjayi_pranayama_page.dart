// ujjayi_pranayama_page.dart
import 'package:flutter/material.dart';

class UjjayiPranayamaPage extends StatelessWidget {
  const UjjayiPranayamaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ujjayi Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Ujjayi Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
