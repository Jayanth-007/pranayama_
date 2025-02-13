import 'package:flutter/material.dart';
import 'package:meditation_app/common_widgets/timer_widget.dart';

class CustomizationPage extends StatefulWidget {
  @override
  _CustomizationPageState createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  double _inhaleDuration = 4;
  double _exhaleDuration = 6;
  double _holdDuration = 2;
  int _selectedDuration = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customize Breathing"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Inhale Duration (seconds): ${_inhaleDuration.toInt()}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _inhaleDuration,
              min: 1,
              max: 10,
              divisions: 9,
              label: _inhaleDuration.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _inhaleDuration = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Exhale Duration (seconds): ${_exhaleDuration.toInt()}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _exhaleDuration,
              min: 1,
              max: 10,
              divisions: 9,
              label: _exhaleDuration.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _exhaleDuration = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Hold Duration (seconds): ${_holdDuration.toInt()}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _holdDuration,
              min: 1,
              max: 10,
              divisions: 9,
              label: _holdDuration.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _holdDuration = value;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
              child: TimerPickerWidget(
                onDurationSelected: (duration) {
                  setState(() {
                    _selectedDuration = duration;
                  });
                },
                durations: [5, 10, 15, 20, 30],
                initialDuration: _selectedDuration,
                titleLabel: "Select Session Duration",
                bottomLabel: "Minutes",
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BreathingBallPage(
                        inhaleDuration: _inhaleDuration.toInt(),
                        exhaleDuration: _exhaleDuration.toInt(),
                        holdDuration: _holdDuration.toInt(),
                        sessionDuration: _selectedDuration,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text("Begin"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreathingBallPage extends StatelessWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int holdDuration;
  final int sessionDuration;

  BreathingBallPage({
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.holdDuration,
    required this.sessionDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Breathing Ball"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Inhale: $inhaleDuration seconds",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Exhale: $exhaleDuration seconds",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Hold: $holdDuration seconds",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Session Duration: $sessionDuration minutes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
