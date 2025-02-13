// sheetali_pranayama_page.dart
import 'package:flutter/material.dart';

class SheetaliPranayamaPage extends StatelessWidget {
  const SheetaliPranayamaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sheetali Pranayama")),
      body: const Center(
        child: Text(
          "Dummy content for Sheetali Pranayama.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
