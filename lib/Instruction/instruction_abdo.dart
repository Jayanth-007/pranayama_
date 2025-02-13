import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Import your breathing exercise screen.
import '../Breathing_Pages/bilateral_screen.dart';
// Import the modified TimerPickerWidget.
import '../common_widgets/timer_widget.dart';

import '../courses/abdominal_breathing_page.dart';

enum DurationMode { rounds, minutes }

class AbdominalBreathingPage extends StatefulWidget {
  @override
  _AbdominalBreathingPageState createState() => _AbdominalBreathingPageState();
}

class _AbdominalBreathingPageState extends State<AbdominalBreathingPage> {
  String? _selectedTechnique;
  final List<String> _breathingTechniques = [
    '4:6 Breathing Technique(Recommended)',
    '2:3 Breathing Technique',
    'Customize Breathing Technique',
  ];

  // Hardcoded YouTube video URL.
  final String _videoUrl = "https://www.youtube.com/watch?v=HhDUXFJDgB4";
  late YoutubePlayerController _youtubePlayerController;

  // Default mode: rounds.
  DurationMode _durationMode = DurationMode.rounds;
  // The picker value represents rounds or minutes. (Default set to 5)
  double _pickerValue = 5.0;

  // Custom values for "Customize Breathing Technique"
  int? _customInhale;
  int? _customExhale;

  @override
  void initState() {
    super.initState();
    // Initialize the YouTube player controller.
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    _selectedTechnique =
    _breathingTechniques.isNotEmpty ? _breathingTechniques[0] : null;
  }

  /// Returns the total seconds for one round.
  int _getRoundSeconds() {
    if (_selectedTechnique == "Customize Breathing Technique") {
      if (_customInhale != null && _customExhale != null) {
        return _customInhale! + _customExhale!;
      }
      return 0;
    } else if (_selectedTechnique != null &&
        _selectedTechnique!.contains(":")) {
      try {
        // Extract ratio from the technique string.
        final ratioPart = _selectedTechnique!.split(" ")[0];
        final parts = ratioPart.split(":");
        final inhale = int.tryParse(parts[0]) ?? 0;
        final exhale = int.tryParse(parts[1]) ?? 0;
        return inhale + exhale;
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  /// Calculates total minutes from the selected rounds.
  int _calculateTotalMinutesFromRounds() {
    int secondsPerRound = _getRoundSeconds();
    int totalSeconds = (secondsPerRound * _pickerValue).toInt();
    return (totalSeconds / 60).round();
  }

  /// Calculates maximum rounds possible from the selected minutes.
  int _calculateRoundsFromMinutes() {
    int secondsPerRound = _getRoundSeconds();
    if (secondsPerRound == 0) return 0;
    int totalSeconds = (_pickerValue * 60).toInt();
    return totalSeconds ~/ secondsPerRound;
  }

  /// Displays a dialog for custom inhale/exhale durations.
  void _showCustomDialog() {
    TextEditingController inhaleController = TextEditingController();
    TextEditingController exhaleController = TextEditingController();

    if (_customInhale != null) inhaleController.text = _customInhale.toString();
    if (_customExhale != null) exhaleController.text = _customExhale.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Custom Breathing Values"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: inhaleController,
                decoration: InputDecoration(labelText: "Inhale Duration (seconds)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: exhaleController,
                decoration: InputDecoration(labelText: "Exhale Duration (seconds)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                int? inhale = int.tryParse(inhaleController.text);
                int? exhale = int.tryParse(exhaleController.text);
                if (inhale == null || exhale == null || inhale <= 0 || exhale <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter valid positive numbers.")),
                  );
                  return;
                }
                setState(() {
                  _customInhale = inhale;
                  _customExhale = exhale;
                });
                Navigator.pop(context);
              },
              child: Text("Save"),
            )
          ],
        );
      },
    );
  }

  /// Navigates to the breathing exercise screen.
  void _navigateToTechnique() {
    if (_selectedTechnique == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a technique')),
      );
      return;
    }

    int rounds;
    if (_durationMode == DurationMode.rounds) {
      rounds = _pickerValue.toInt();
    } else {
      rounds = _calculateRoundsFromMinutes();
    }

    switch (_selectedTechnique) {
      case '2:3 Breathing Technique':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BilateralScreen(
              inhaleDuration: 2,
              exhaleDuration: 3,
              rounds: rounds,
            ),
          ),
        );
        break;
      case '4:6 Breathing Technique(Recommended)':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BilateralScreen(
              inhaleDuration: 4,
              exhaleDuration: 6,
              rounds: rounds,
            ),
          ),
        );
        break;
      case 'Customize Breathing Technique':
        if (_customInhale == null || _customExhale == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please set custom breathing values')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BilateralScreen(
              inhaleDuration: _customInhale!,
              exhaleDuration: _customExhale!,
              rounds: rounds,
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Technique not available')),
        );
    }
  }

  Widget _buildInstructionCard(int step, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3.0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: Text(
            "$step",
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(content),
      ),
    );
  }

  Widget _buildDurationModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Radio<DurationMode>(
          value: DurationMode.rounds,
          groupValue: _durationMode,
          onChanged: (value) {
            setState(() {
              _durationMode = value!;
              // Reset the picker value for the new mode.
              _pickerValue = 5.0;
            });
          },
        ),
        Text("Rounds"),
        Radio<DurationMode>(
          value: DurationMode.minutes,
          groupValue: _durationMode,
          onChanged: (value) {
            setState(() {
              _durationMode = value!;
              _pickerValue = 5.0;
            });
          },
        ),
        Text("Minutes"),
      ],
    );
  }

  // Build the picker with dynamic options.
  Widget _buildPicker() {
    // If rounds mode: increments of 5 up to 100.
    // If minutes mode: increments of 5 up to 60.
    final List<int> options = _durationMode == DurationMode.rounds
        ? List<int>.generate(20, (index) => (index + 1) * 5)
        : List<int>.generate(12, (index) => (index + 1) * 5);

    final String titleLabel = _durationMode == DurationMode.rounds
        ? "Select Rounds"
        : "Select Duration";
    final String bottomLabel = _durationMode == DurationMode.rounds
        ? "rounds"
        : "minutes";

    return TimerPickerWidget(
      durations: options,
      initialDuration: _pickerValue.toInt(),
      titleLabel: titleLabel,
      bottomLabel: bottomLabel,
      onDurationSelected: (selectedValue) {
        setState(() {
          _pickerValue = selectedValue.toDouble();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int roundSeconds = _getRoundSeconds();

    return Scaffold(
      appBar: AppBar(
        title: Text("Abdominal Breathing"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Technique selection.
            Text(
              "Select a Breathing Technique",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            DropdownButton<String>(
              value: _selectedTechnique,
              hint: Text("Select a technique"),
              isExpanded: true,
              items: _breathingTechniques.map((technique) {
                return DropdownMenuItem<String>(
                  value: technique,
                  child: Text(technique),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTechnique = value;
                  _pickerValue = 5.0;
                });
              },
            ),
            // Custom values card.
            if (_selectedTechnique == "Customize Breathing Technique")
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  title: Text("Custom Values"),
                  subtitle: Text(
                    "Inhale: ${_customInhale ?? "Not set"} sec, Exhale: ${_customExhale ?? "Not set"} sec",
                  ),
                  trailing: ElevatedButton(
                    onPressed: _showCustomDialog,
                    child: Text("Edit"),
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            // Duration controls.
            if (roundSeconds > 0) ...[
              _buildDurationModeToggle(),
              SizedBox(height: 8.0),
              // Text(
              //   _durationMode == DurationMode.rounds
              //       ? "Select Number of Rounds"
              //       : "Select Total Minutes",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              //   textAlign: TextAlign.center,
              // ),
              _buildPicker(),
              SizedBox(height: 8.0),
              _durationMode == DurationMode.rounds
                  ? Text(
                "Total Time: ${_calculateTotalMinutesFromRounds()} minute(s)",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
                textAlign: TextAlign.center,
              )
                  : Text(
                "Maximum Rounds Possible: ${_calculateRoundsFromMinutes()}",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
            ],
            Text(
              "What is Abdominal Breathing?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              "Abdominal breathing is a technique that focuses on deep breathing by engaging the diaphragm rather than the chest. This method promotes relaxation, improves oxygen flow, and helps reduce stress.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text(
              "Watch a Demonstration",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            YoutubePlayer(
              controller: _youtubePlayerController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.teal,
            ),
            SizedBox(height: 24.0),
            Text(
              "Step-by-Step Instructions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            _buildInstructionCard(
                1, "Sit in a comfortable position and relax your shoulders."),
            _buildInstructionCard(
                2, "Place one hand on your abdomen and the other on your chest."),
            _buildInstructionCard(
                3, "Inhale deeply through your nose for 4 seconds, feeling your abdomen expand."),
            _buildInstructionCard(
                4, "Exhale slowly through your mouth for 6 seconds, noticing your abdomen contract."),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _navigateToTechnique,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: Text("Begin"),
            ),
            ElevatedButton(
              onPressed: () {
                // Add redirection or action for "Learn More" here.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AbdominalBreathingLearnMorePage(),
                  ),
                );
              },
              child: Text("Learn More"),
            ),
          ],
        ),
      ),
    );
  }
}
