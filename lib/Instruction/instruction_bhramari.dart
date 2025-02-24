import 'package:flutter/material.dart';
import 'package:meditation_app/Breathing_Pages/bhramari_screen.dart';
import 'package:meditation_app/courses/bhramari_pranayama_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// Import the modified TimerPickerWidget.
import '../common_widgets/timer_widget.dart';
// Import the common customization popup from customize.dart.
import '../Customization/customize.dart';

enum DurationMode { rounds, minutes }

class BhramariBreathingPage extends StatefulWidget {
  @override
  _BhramariBreathingPageState createState() => _BhramariBreathingPageState();
}

class _BhramariBreathingPageState extends State<BhramariBreathingPage> {
  String? _selectedTechnique;
  final List<String> _breathingTechniques = [
    'Standard Breathing (4:6)',
    'Extended Breathing (5:8)',
    'Customize Breathing Technique',
  ];

  // Hardcoded YouTube video URL for Bhramari demonstration.
  final String _videoUrl = "https://www.youtube.com/watch?v=H7XI-EsIkCY";
  late YoutubePlayerController _youtubePlayerController;

  // Default mode: rounds.
  DurationMode _durationMode = DurationMode.rounds;
  // The picker value represents rounds or minutes (default set to 5).
  double _pickerValue = 5.0;

  // Custom values for "Customize Breathing Technique".
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

  /// Returns the total seconds for one round (inhale + exhale).
  int _getRoundSeconds() {
    if (_selectedTechnique == "Customize Breathing Technique") {
      if (_customInhale != null && _customExhale != null) {
        return _customInhale! + _customExhale!;
      }
      return 0;
    } else if (_selectedTechnique != null &&
        _selectedTechnique!.contains("(") &&
        _selectedTechnique!.contains(")")) {
      try {
        final startIndex = _selectedTechnique!.indexOf('(');
        final endIndex = _selectedTechnique!.indexOf(')');
        final ratioPart =
        _selectedTechnique!.substring(startIndex + 1, endIndex); // e.g., "4:6" or "5:8"
        final parts = ratioPart.split(":");
        if (parts.length == 2) {
          final inhale = int.tryParse(parts[0]) ?? 0;
          final exhale = int.tryParse(parts[1]) ?? 0;
          return inhale + exhale;
        }
        return 0;
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

  /// Uses the imported common popup from customize.dart.
  /// Ensure your customization dialog now accepts initialInhale and initialExhale parameters
  /// and returns a Map with keys 'inhale' and 'exhale'.
  void _showCustomDialog() async {
    final result = await showCustomizationDialog(
      context,
      initialInhale: _customInhale ?? 4,
      initialExhale: _customExhale ?? 6,
      initialHold: 0,
    );
    if (result != null) {
      setState(() {
        _customInhale = result['inhale'];
        _customExhale = result['exhale'];
      });
    }
  }

  /// Navigates to the Bhramari breathing exercise screen.
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
      case 'Standard Breathing (4:6)':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BhramariScreen(
              inhaleDuration: 4,
              exhaleDuration: 6,
              rounds: rounds,
            ),
          ),
        );
        break;
      case 'Extended Breathing (5:8)':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BhramariScreen(
              inhaleDuration: 5,
              exhaleDuration: 8,
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
            builder: (context) => BhramariScreen(
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
    final List<int> options = _durationMode == DurationMode.rounds
        ? List<int>.generate(20, (index) => (index + 1) * 5)
        : List<int>.generate(12, (index) => (index + 1) * 5);

    final String titleLabel = _durationMode == DurationMode.rounds
        ? "Select Rounds"
        : "Select Duration";
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
    int roundSeconds = _getRoundSeconds();

    return Scaffold(
      appBar: AppBar(
        title: Text("Bhramari Breathing"),
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
                // Immediately show the customization popup if the option is selected.
                if (value == "Customize Breathing Technique") {
                  _showCustomDialog();
                }
              },
            ),
            SizedBox(height: 16.0),
            // Duration controls.
            if (roundSeconds > 0) ...[
              _buildDurationModeToggle(),
              SizedBox(height: 8.0),
              _buildPicker(),
              SizedBox(height: 8.0),
              _durationMode == DurationMode.rounds
                  ? Text(
                "Total Time: ${_calculateTotalMinutesFromRounds()} minute(s)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              )
                  : Text(
                "Maximum Rounds Possible: ${_calculateRoundsFromMinutes()}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
            ],
            Text(
              "What is Bhramari Breathing?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(
              "Bhramari breathing is a yogic practice that involves making a gentle humming sound during exhalation. This technique helps calm the mind, reduce stress, and promote inner peace.",
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
            // Instruction cards.
            Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child:
                  Text("1", style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                    "Sit comfortably with your spine straight and relax your shoulders."),
              ),
            ),
            Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child:
                  Text("2", style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                    "Close your eyes and, if you prefer, gently press your thumbs against your ears to reduce external noise."),
              ),
            ),
            Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child:
                  Text("3", style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                    "Take a deep, natural inhale through your nose."),
              ),
            ),
            Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child:
                  Text("4", style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                    "Exhale slowly while producing a soft humming sound like a bee."),
              ),
            ),
            Card(
              margin:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child:
                  Text("5", style: TextStyle(color: Colors.white)),
                ),
                title: Text(
                    "Repeat the process for the set number of rounds or duration."),
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
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: Text("Begin"),
            ),
            ElevatedButton(
              onPressed: () {
                // You can add functionality for a Learn More page here.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const BhramariBreathingLearnMorePage(),
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
