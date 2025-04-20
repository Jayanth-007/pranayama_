import 'package:flutter/material.dart';
import 'package:meditation_app/Customization/customize.dart';
import 'package:meditation_app/courses/complete_breathing_page.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:meditation_app/Breathing_Pages/bilateral_screen.dart';

class CompleteBreathingPage extends StatefulWidget {
  @override
  _CompleteBreathingPageState createState() => _CompleteBreathingPageState();
}

class _CompleteBreathingPageState extends State<CompleteBreathingPage> {
  String _selectedTechnique = '4:6';
  final Map<String, String> _techniques = {
    '2:3': '2:3 Breathing',
    '4:6': '4:6 Breathing (Recommended)',
  };

  late YoutubePlayerController _ytController;
  bool _isMinutesMode = false;
  int _selectedDuration = 5;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        "https://www.youtube.com/watch?v=HhDUXFJDgB4", // replace with your complete‑breathing video URL
      )!,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Breathing"),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Breathing Technique"),
            SizedBox(height: 8),
            _buildTechniqueButtons(),
            SizedBox(height: 24),

            _buildSectionTitle("Duration"),
            _buildDurationControls(),
            SizedBox(height: 24),

            _buildCustomizeButton(),
            SizedBox(height: 16),

            _buildBeginButton(),
            SizedBox(height: 32),

            _buildSectionTitle("About Complete Breathing"),
            _buildDescriptionText(),
            SizedBox(height: 24),

            _buildSectionTitle("Video Demonstration"),
            SizedBox(height: 12),
            _buildVideoPlayer(),
            SizedBox(height: 24),

            _buildSectionTitle("How To Practice"),
            SizedBox(height: 12),
            ..._buildInstructionSteps(),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((entry) {
        bool isSelected = _selectedTechnique == entry.key;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isSelected ? Color(0xff98bad5) : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () => setState(() => _selectedTechnique = entry.key),
              child: Column(
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entry.key == '4:6') SizedBox(height: 4),
                  if (entry.key == '4:6')
                    Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.green,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationControls() {
    final options = _isMinutesMode
        ? [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
        : [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleOption("Rounds", !_isMinutesMode),
            SizedBox(width: 20),
            _buildToggleOption("Minutes", _isMinutesMode),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final val = options[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = val),
                child: Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedDuration == val
                        ? Color(0xff98bad5)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "$val",
                      style: TextStyle(
                        fontSize: 20,
                        color: _selectedDuration == val
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
        _buildDurationHint(),
      ],
    );
  }

  Widget _buildToggleOption(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMinutesMode = text == "Minutes"),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Color(0xff98bad5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Color(0xff98bad5) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isActive ? Colors.white : Colors.black87),
        ),
      ),
    );
  }

  Widget _buildDurationHint() {
    final inhale = _selectedTechnique == '4:6' ? 4 : 2;
    final exhale = _selectedTechnique == '4:6' ? 6 : 3;
    final totalSeconds = _isMinutesMode
        ? _selectedDuration * 60
        : _selectedDuration * (inhale + exhale);

    return Text(
      _isMinutesMode
          ? "≈ ${(_selectedDuration * 60 / (inhale + exhale)).toStringAsFixed(0)} rounds"
          : "≈ ${(totalSeconds / 60).toStringAsFixed(1)} minutes",
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey[600]),
    );
  }

  Widget _buildCustomizeButton() {
    return OutlinedButton.icon(
      icon: Icon(Icons.settings, size: 20, color: Colors.black),
      label: Text("Customize Breathing Pattern"),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Color(0xff98bad5)),
      ),
      onPressed: () async {
        final result = await showCustomizationDialog(
          context,
          initialInhale: _selectedTechnique == '4:6' ? 4 : 2,
          initialExhale: _selectedTechnique == '4:6' ? 6 : 3,
          initialHold: 0,
        );
        if (result != null) {
          final rounds = _isMinutesMode
              ? (_selectedDuration * 60) ~/
              (result['inhale']! + result['exhale']! + result['hold']!)
              : _selectedDuration;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BilateralScreen(
                inhaleDuration: result['inhale']!,
                exhaleDuration: result['exhale']!,
                rounds: rounds,
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final inhale = _selectedTechnique == '4:6' ? 4 : 2;
          final exhale = _selectedTechnique == '4:6' ? 6 : 3;
          final rounds = _isMinutesMode
              ? (_selectedDuration * 60) ~/ (inhale + exhale)
              : _selectedDuration;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BilateralScreen(
                inhaleDuration: inhale,
                exhaleDuration: exhale,
                rounds: rounds,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff98bad5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "BEGIN EXERCISE",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      "Complete breathing combines diaphragmatic (abdominal), thoracic (chest), "
          "and clavicular (upper chest) breathing into one fluid cycle. It engages "
          "all parts of your lungs for maximum oxygen exchange and deep relaxation.",
      style: TextStyle(fontSize: 15, height: 1.5),
    );
  }

  List<Widget> _buildInstructionSteps() {
    return [
      _buildStepCard(1, "Sit comfortably with your spine straight and shoulders relaxed."),
      _buildStepCard(2, "Place one hand on your abdomen and one on your chest."),
      _buildStepCard(3, "Inhale slowly: first fill your abdomen, then chest, then collarbones."),
      _buildStepCard(4, "Exhale fully: release collarbones, then chest, then abdomen."),
      _buildStepCard(5, "Continue this full breath cycle for your selected duration."),
    ];
  }

  Widget _buildStepCard(int num, String text) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Color(0xff98bad5),
              child: Text(
                num.toString(),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            SizedBox(width: 12),
            Expanded(child: Text(text, style: TextStyle(height: 1.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: _ytController,
        aspectRatio: 16 / 9,
        showVideoProgressIndicator: true,
      ),
    );
  }

  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompleteBreathingLearnMorePage(),
              ),
            );
          },
          child: Text(
            "Learn More →",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
