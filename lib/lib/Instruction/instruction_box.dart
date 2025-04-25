import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meditation_app/Breathing_Pages/boxbreathing_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


// Import the modified TimerPickerWidget if you have one.
import '../common_widgets/timer_widget.dart';

// A placeholder for a “Learn More” page about Box Breathing
class BoxBreathingLearnMorePage extends StatelessWidget {
  const BoxBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn More: Box Breathing"),
      ),
      body: const Center(
        child: Text(
          "Detailed information about Box Breathing goes here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

enum DurationMode { rounds, minutes }

class BoxBreathingPage extends StatefulWidget {
  const BoxBreathingPage({Key? key}) : super(key: key);

  @override
  _BoxBreathingPageState createState() => _BoxBreathingPageState();
}

class _BoxBreathingPageState extends State<BoxBreathingPage> {
  // Selected technique from the dropdown
  String? _selectedTechnique;

  // Two predefined box breathing ratios: 4:4:4:4 and 4:4:6:4
  final List<String> _breathingTechniques = [
    '4:4:4:4 (Recommended)',
    '4:4:6:4',
  ];

  // Example YouTube video link demonstrating Box Breathing
  final String _videoUrl = "https://www.youtube.com/watch?v=tEmt1Znux58";
  late YoutubePlayerController _youtubePlayerController;

  // Default mode: rounds
  DurationMode _durationMode = DurationMode.rounds;

  // The picker value represents either # of rounds or # of minutes. Default = 5.
  double _pickerValue = 5.0;

  @override
  void initState() {
    super.initState();
    // Initialize the YouTube player controller
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    // Default technique (first in list)
    _selectedTechnique = _breathingTechniques.isNotEmpty
        ? _breathingTechniques[0]
        : null;
  }

  /// Returns the total seconds for one round based on the selected technique.
  int _getRoundSeconds() {
    if (_selectedTechnique == null) return 0;

    // Example: "4:4:4:4 (Recommended)" -> ratioPart = "4:4:4:4"
    final ratioPart = _selectedTechnique!.split(" ")[0]; // e.g. "4:4:4:4"
    final parts = ratioPart.split(":"); // e.g. ["4","4","4","4"]
    if (parts.length != 4) return 0;

    final inhale = int.tryParse(parts[0]) ?? 0;
    final hold1 = int.tryParse(parts[1]) ?? 0;
    final exhale = int.tryParse(parts[2]) ?? 0;
    final hold2 = int.tryParse(parts[3]) ?? 0;

    return inhale + hold1 + exhale + hold2;
  }

  /// Calculates total minutes from the selected number of rounds.
  int _calculateTotalMinutesFromRounds() {
    final secondsPerRound = _getRoundSeconds();
    final totalSeconds = (secondsPerRound * _pickerValue).toInt();
    return (totalSeconds / 60).round();
  }

  /// Calculates maximum rounds possible from the selected minutes.
  int _calculateRoundsFromMinutes() {
    final secondsPerRound = _getRoundSeconds();
    if (secondsPerRound == 0) return 0;
    final totalSeconds = (_pickerValue * 60).toInt();
    return totalSeconds ~/ secondsPerRound;
  }

  /// Navigates to the actual Box Breathing exercise screen.
  void _navigateToTechnique() {
    if (_selectedTechnique == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a technique')),
      );
      return;
    }

    // Decide how many rounds based on user selection of Rounds vs Minutes.
    int rounds;
    if (_durationMode == DurationMode.rounds) {
      rounds = _pickerValue.toInt();
    } else {
      rounds = _calculateRoundsFromMinutes();
    }

    // Parse the technique ratios.
    final ratioPart = _selectedTechnique!.split(" ")[0]; // e.g. "4:4:4:4"
    final parts = ratioPart.split(":");
    if (parts.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid technique format')),
      );
      return;
    }
    final inhale = int.parse(parts[0]);
    final hold1 = int.parse(parts[1]);
    final exhale = int.parse(parts[2]);
    final hold2 = int.parse(parts[3]);

    // Navigate to the Box Breathing exercise screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoxBreathingScreen(
          inhaleDuration: inhale,
          hold1Duration: hold1,
          exhaleDuration: exhale,
          hold2Duration: hold2,
          rounds: rounds,
        ),
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
              _pickerValue = 5.0;
            });
          },
        ),
        const Text("Rounds"),
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
        const Text("Minutes"),
      ],
    );
  }

  Widget _buildPicker() {
    final List<int> options = _durationMode == DurationMode.rounds
        ? List<int>.generate(20, (index) => (index + 1) * 5) // 5,10,15,...
        : List<int>.generate(12, (index) => (index + 1) * 5); // 5,10,15,... minutes

    final String titleLabel =
    _durationMode == DurationMode.rounds ? "Select Rounds" : "Select Duration";
    final String bottomLabel =
    _durationMode == DurationMode.rounds ? "rounds" : "minutes";

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
    final roundSeconds = _getRoundSeconds();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Box Breathing"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Technique selection.
            const Text(
              "Select a Breathing Technique",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DropdownButton<String>(
              value: _selectedTechnique,
              hint: const Text("Select a technique"),
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
                  _pickerValue = 5.0; // Reset the picker when technique changes.
                });
              },
            ),
            const SizedBox(height: 16.0),

            // Duration controls (only show if we can calculate a round's length).
            if (roundSeconds > 0) ...[
              _buildDurationModeToggle(),
              const SizedBox(height: 8.0),
              _buildPicker(),
              const SizedBox(height: 8.0),
              _durationMode == DurationMode.rounds
                  ? Text(
                "Total Time: ${_calculateTotalMinutesFromRounds()} minute(s)",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              )
                  : Text(
                "Maximum Rounds Possible: ${_calculateRoundsFromMinutes()}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
            ],

            // Explanation of Box Breathing.
            const Text(
              "What is Box Breathing?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            const Text(
              "Box Breathing is a simple yet powerful breathing technique that "
                  "involves inhaling, holding, exhaling, and holding again for equal durations. "
                  "This method helps calm the mind, reduce stress, and improve focus.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24.0),

            // YouTube demonstration.
            const Text(
              "Watch a Demonstration",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            YoutubePlayer(
              controller: _youtubePlayerController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.teal,
            ),
            const SizedBox(height: 24.0),

            // Step-by-step instructions.
            const Text(
              "Step-by-Step Instructions",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),

            // Example instruction cards.
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text("1", style: TextStyle(color: Colors.white)),
                ),
                title: const Text("Sit upright and relax your shoulders."),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text("2", style: TextStyle(color: Colors.white)),
                ),
                title: const Text(
                  "Inhale deeply through your nose for the set count (e.g., 4 seconds).",
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text("3", style: TextStyle(color: Colors.white)),
                ),
                title: const Text(
                  "Hold your breath for the same count (e.g., 4 seconds).",
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text("4", style: TextStyle(color: Colors.white)),
                ),
                title: const Text(
                  "Exhale gently through your mouth for the same count (e.g., 4 seconds).",
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text("5", style: TextStyle(color: Colors.white)),
                ),
                title: const Text(
                  "Hold your breath again for the same count (e.g., 4 seconds).",
                ),
              ),
            ),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text("Begin"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BoxBreathingLearnMorePage(),
                  ),
                );
              },
              child: const Text("Learn More"),
            ),
          ],
        ),
      ),
    );
  }
}
