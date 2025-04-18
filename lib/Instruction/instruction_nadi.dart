import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../Breathing_Pages/bilateral_screen.dart';
import '../common_widgets/timer_widget.dart';
import '../Customization/customize.dart';

class NadiShodhanaPage extends StatefulWidget {
  @override
  _NadiShodhanaPageState createState() => _NadiShodhanaPageState();
}

class _NadiShodhanaPageState extends State<NadiShodhanaPage> {
  String _selectedTechnique = '4:4 Nadi Shodhana (Standard)';
  final Map<String, String> _techniques = {
    '4:4': '4:4 Nadi Shodhana (Standard)',
    'custom': 'Customize Technique',
  };

  late YoutubePlayerController _ytController;
  bool _isMinutesMode = false;
  int _selectedDuration = 5;
  int? _customInhale;
  int? _customExhale;

  @override
  void initState() {
    super.initState();
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
          "https://www.youtube.com/watch?v=R2cEQEKn3YM")!,
      flags: YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nadi Shodhana Pranayama"),
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
            SizedBox(height: 8),
            _buildDurationHint(),
            SizedBox(height: 24),
            _buildSectionTitle("About Nadi Shodhana"),
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
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((entry) {
        bool isSelected = _selectedTechnique == entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xff304674) : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () {
                setState(() => _selectedTechnique = entry.value);
                if (entry.key == 'custom') {
                  _showCustomDialog();
                }
              },
              child: Text(
                entry.value,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationControls() {
    final options = _isMinutesMode
        ? [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60] // Minutes
        : [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100]; // Rounds

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
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedDuration = options[index]);
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _selectedDuration == options[index]
                        ? Color(0xff304674)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      options[index].toString(),
                      style: TextStyle(
                        fontSize: 20,
                        color: _selectedDuration == options[index]
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
      ],
    );
  }

  Widget _buildToggleOption(String text, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _isMinutesMode = text == "Minutes"),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? Color(0xff304674) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Color(0xff304674) : Colors.grey[400]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDurationHint() {
    final inhale = _selectedTechnique.startsWith('4:') ? 4 : _customInhale ?? 4;
    final exhale = _selectedTechnique.startsWith('4:') ? 4 : _customExhale ?? 4;
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

  Widget _buildDescriptionText() {
    return Text(
      "Nadi Shodhana Pranayama, or alternate nostril breathing, balances the body's energy and calms the mind. "
          "This technique alternates breath between nostrils to promote mental clarity, reduce stress, and enhance respiratory function.",
      style: TextStyle(fontSize: 15, height: 1.5),
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

  List<Widget> _buildInstructionSteps() {
    return [
      _buildStepCard(1, "Sit comfortably with your spine erect and relax your shoulders."),
      _buildStepCard(2, "Close your right nostril gently with your thumb and inhale slowly through your left nostril."),
      _buildStepCard(3, "Close your left nostril with your ring finger, open your right nostril and exhale slowly."),
      _buildStepCard(4, "Inhale slowly through your right nostril, then close it and open your left nostril to exhale."),
      _buildStepCard(5, "This completes one round. Continue alternating for several rounds."),
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
            Expanded(
              child: Text(text, style: TextStyle(height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                // Learn more navigation
              },
              child: Text(
                "Learn More →",
                style: TextStyle(
                  color: Color(0xff304674),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _navigateToTechnique,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff304674),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "BEGIN EXERCISE",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    if (_selectedTechnique == 'Customize Technique' && (_customInhale == null || _customExhale == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please set custom breathing values')),
      );
      return;
    }

    final inhale = _selectedTechnique.startsWith('4:') ? 4 : _customInhale!;
    final exhale = _selectedTechnique.startsWith('4:') ? 4 : _customExhale!;
    final rounds = _isMinutesMode
        ? (_selectedDuration * 60) ~/ (inhale + exhale)
        : _selectedDuration;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BilateralScreen(
          inhaleDuration: inhale,
          exhaleDuration: exhale,
          rounds: rounds,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }
}