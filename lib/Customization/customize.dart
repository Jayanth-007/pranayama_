import 'package:flutter/material.dart';

/// This function displays a customization popup dialog for setting
/// custom inhale, exhale, and hold durations (in seconds).
Future<Map<String, int>?> showCustomizationDialog(
    BuildContext context, {
      required int initialInhale,
      required int initialExhale,
      required int initialHold,
    }) {
  double inhaleDuration = initialInhale.toDouble();
  double exhaleDuration = initialExhale.toDouble();
  double holdDuration = initialHold.toDouble();

  return showDialog<Map<String, int>>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text("Customize Breathing"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Inhale Duration (seconds): ${inhaleDuration.toInt()}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: inhaleDuration,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: inhaleDuration.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        inhaleDuration = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Exhale Duration (seconds): ${exhaleDuration.toInt()}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: exhaleDuration,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: exhaleDuration.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        exhaleDuration = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Hold Duration (seconds): ${holdDuration.toInt()}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Slider(
                    value: holdDuration,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: holdDuration.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        holdDuration = value;
                      });
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(), // Cancel
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Return the custom inhale, exhale, and hold values.
              Navigator.of(dialogContext).pop({
                'inhale': inhaleDuration.toInt(),
                'exhale': exhaleDuration.toInt(),
                'hold': holdDuration.toInt(),
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text("Set"),
          ),
        ],
      );
    },
  );
}
