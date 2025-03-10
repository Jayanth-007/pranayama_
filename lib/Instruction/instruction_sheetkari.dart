import 'package:flutter/material.dart';
import 'package:meditation_app/courses/sheetkari_pranayama_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Import your breathing exercise screen.
import '../Breathing_Pages/bilateral_screen.dart';
// Import the modified TimerPickerWidget.
import '../common_widgets/timer_widget.dart';
// Import the common customization popup from customize.dart.
import '../Customization/customize.dart';

enum DurationMode { rounds, minutes }

class SheetkariPranayamaPage extends StatefulWidget {
  @override
  _SheetkariPranayamaPageState createState() => _SheetkariPranayamaPageState();
}

class _SheetkariPranayamaPageState extends State<SheetkariPranayamaPage> {
  String? _selectedTechnique;
  final List<String> _breathingTechniques = [
    '4:4 Sheetkari Pranayama (Standard)',
    'Customize Technique',
  ];

  // Hardcoded YouTube video URL for Sheetkari demonstration.
  final String _videoUrl = "https://www.youtube.com/watch?v=YOUR_SHEETKARI_VIDEO_ID";
  late YoutubePlayerController _youtubePlayerController;

  DurationMode _durationMode = DurationMode.rounds;
  double _pickerValue = 5.0;
  int? _customInhale;
  int? _customExhale;
  final int _customHold = 0;

  @override
  void initState() {
    super.initState();
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(_videoUrl)!,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
    _selectedTechnique = _breathingTechniques.isNotEmpty ? _breathingTechniques[0] : null;
  }

  int _getRoundSeconds() {
    if (_selectedTechnique == "Customize Technique") {
      if (_customInhale != null && _customExhale != null) {
        return _customInhale! + _customExhale!;
      }
      return 0;
    } else if (_selectedTechnique != null && _selectedTechnique!.contains(":")) {
      try {
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

  int _calculateTotalMinutesFromRounds() {
    int secondsPerRound = _getRoundSeconds();
    int totalSeconds = (secondsPerRound * _pickerValue).toInt();
    return (totalSeconds / 60).round();
  }

  int _calculateRoundsFromMinutes() {
    int secondsPerRound = _getRoundSeconds();
    if (secondsPerRound == 0) return 0;
    int totalSeconds = (_pickerValue * 60).toInt();
    return totalSeconds ~/ secondsPerRound;
  }

  void _showCustomDialog() async {
    final result = await showCustomizationDialog(
      context,
      initialInhale: _customInhale ?? 4,
      initialExhale: _customExhale ?? 4,
      initialHold: 0,
    );
    if (result != null) {
      setState(() {
        _customInhale = result['inhale'];
        _customExhale = result['exhale'];
      });
    }
  }

  void _navigateToTechnique() {
    if (_selectedTechnique == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a technique')));
      return;
    }
    int rounds = _durationMode == DurationMode.rounds ? _pickerValue.toInt() : _calculateRoundsFromMinutes();
    switch (_selectedTechnique) {
      case '4:4 Sheetkari Pranayama (Standard)':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BilateralScreen(
              inhaleDuration: 4,
              exhaleDuration: 4,
              rounds: rounds,
            ),
          ),
        );
        break;
      case 'Customize Technique':
        if (_customInhale == null || _customExhale == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please set custom breathing values')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Technique not available')));
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

  Widget _buildPicker() {
    final List<int> options = _durationMode == DurationMode.rounds
        ? List<int>.generate(20, (index) => (index + 1) * 5)
        : List<int>.generate(12, (index) => (index + 1) * 5);
    final String titleLabel = _durationMode == DurationMode.rounds ? "Select Rounds" : "Select Duration";
    final String bottomLabel = _durationMode == DurationMode.rounds ? "rounds" : "minutes";

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
        title: Text("Sheetkari Pranayama"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Select a Breathing Technique", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            DropdownButton<String>(
              value: _selectedTechnique,
              hint: Text("Select a technique"),
              isExpanded: true,
              items: _breathingTechniques.map((technique) => DropdownMenuItem<String>(
                value: technique,
                child: Text(technique),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTechnique = value;
                  _pickerValue = 5.0;
                });
                if (value == "Customize Technique") _showCustomDialog();
              },
            ),
            SizedBox(height: 16.0),
            if (roundSeconds > 0) ...[
              _buildDurationModeToggle(),
              SizedBox(height: 8.0),
              _buildPicker(),
              SizedBox(height: 8.0),
              _durationMode == DurationMode.rounds
                  ? Text("Total Time: ${_calculateTotalMinutesFromRounds()} minute(s)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.center)
                  : Text("Maximum Rounds Possible: ${_calculateRoundsFromMinutes()}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal), textAlign: TextAlign.center),
              SizedBox(height: 16.0),
            ],
            Text("What is Sheetkari Pranayama?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4.0),
            Text(
              "Sheetkari Pranayama is a cooling breath technique where you partially open your mouth and inhale through your teeth, producing a hissing sound. Then, exhale through your nose. This method is believed to cool the body and calm the mind.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24.0),
            Text("Watch a Demonstration", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8.0),
            YoutubePlayer(
              controller: _youtubePlayerController,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.teal,
            ),
            SizedBox(height: 24.0),
            Text("Step-by-Step Instructions", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.0),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal, child: Text("1", style: TextStyle(color: Colors.white))),
                title: Text("Sit comfortably with your spine straight and relax your shoulders."),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal, child: Text("2", style: TextStyle(color: Colors.white))),
                title: Text("Part your lips slightly and press your tongue gently against your upper palate."),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal, child: Text("3", style: TextStyle(color: Colors.white))),
                title: Text("Inhale through your mouth, producing a soft hissing sound."),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal, child: Text("4", style: TextStyle(color: Colors.white))),
                title: Text("Close your mouth and exhale slowly through your nose."),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: 3.0,
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.teal, child: Text("5", style: TextStyle(color: Colors.white))),
                title: Text("Repeat the cycle for several rounds, focusing on the cooling sensation."),
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
              child: Text("Begin"),
            ),
            ElevatedButton(
              onPressed: () {
                // Replace with your actual Learn More page for Sheetkari.
                Navigator.push(context, MaterialPageRoute(builder: (context) => SheetkariPranayamaLearnMorePage()));
              },
              child: Text("Learn More"),
            ),
          ],
        ),
      ),
    );
  }
}
