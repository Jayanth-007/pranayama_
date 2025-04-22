import 'package:flutter/material.dart';
import 'package:meditation_app/Breathing_Pages/bilateral_screen.dart';
import 'package:meditation_app/Customization/customize.dart';
import 'package:meditation_app/courses/abdominal_breathing_page.dart';

class AbdominalBreathingPage extends StatefulWidget {
  const AbdominalBreathingPage({super.key});

  @override
  _AbdominalBreathingPageState createState() => _AbdominalBreathingPageState();
}

class _AbdominalBreathingPageState extends State<AbdominalBreathingPage> {
  // Breathing technique
  String _selectedTechnique = '4:6';

  // Visualization image
  String _selectedImage = 'assets/images/option3.png';
  final List<Map<String, String>> _imageOptions = [
    {'name': 'Option 1', 'path': 'assets/images/option3.png'},
    {'name': 'Option 2', 'path': 'assets/images/option1.png'},
    {'name': 'Option 3', 'path': 'assets/images/option2.png'},
  ];

  // Duration
  int _selectedDuration = 5;

  // Ambient sounds
  final List<Map<String, String>> _soundOptions = [
    {'name': 'None', 'path': 'assets/images/sound_none.png'},
    {'name': 'Soothing Sitar', 'path': 'assets/images/sound_sitar.png'},
    {'name': 'Mountain Echoes', 'path': 'assets/images/sound_mountain.png'},
    {'name': 'Rest Waves', 'path': 'assets/images/sound_waves.png'},
    {'name': 'Sacred AUM Chants', 'path': 'assets/images/sound_om.png'},
    {'name': 'Himalayan Gong', 'path': 'assets/images/sound_gong.png'},
  ];
  String _selectedSound = 'None';

  // Technique options
  final Map<String, String> _techniques = {
    '4:6': '4:6 Breathing (Recommended)',
    'custom': 'Custom',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abdominal Breathing'),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 60,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Breathing Technique'),
            const SizedBox(height: 8),
            _buildTechniqueButtons(),
            const SizedBox(height: 24),

            _buildSectionTitle('Duration'),
            _buildDurationControls(),
            const SizedBox(height: 24),

            _buildSectionTitle('Visualization Image'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showImagePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _imageOptions.firstWhere((opt) => opt['path'] == _selectedImage)['name']!,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Ambient Sound'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showSoundPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedSound,                            // <- show current selection
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildBeginButton(),
            const SizedBox(height: 24),

            ExpansionTile(
              title: const Text(
                'How To Practice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              children: _buildInstructionSteps(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildLearnMoreButton(),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTechniqueButtons() {
    return Row(
      children: _techniques.entries.map((entry) {
        final isSelected = _selectedTechnique == entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xff98bad5) : Colors.grey[200],
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              onPressed: () async {
                if (entry.key == 'custom') {
                  final result = await showCustomizationDialog(
                    context,
                    initialInhale: 4,
                    initialExhale: 6,
                    initialHold: 0,
                  );
                  if (result != null) {
                    setState(() => _selectedTechnique = 'custom');
                  }
                } else {
                  setState(() => _selectedTechnique = entry.key);
                }
              },
              child: Column(
                children: [
                  Text(
                    entry.key == 'custom' ? 'Custom' : entry.key,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (entry.key == '4:6') ...[
                    const SizedBox(height: 4),
                    Text(
                      'Recommended',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showImagePicker() {
    String tempSelectedImage = _selectedImage; // Temporary variable for selection
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Visualization Image',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context), // Close without saving
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageOptions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, idx) {
                        final image = _imageOptions[idx];
                        final isSelected = tempSelectedImage == image['path'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempSelectedImage = image['path']!; // Update temp selection
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? const Color(0xff98bad5) : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(image['path']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                if (isSelected)
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.check_circle, color: Colors.white),
                                  ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    color: Colors.black54,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      image['name']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage = tempSelectedImage; // Apply selection on Done
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff98bad5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDurationControls() {
    final options = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60];
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final val = options[index];
          final isSelected = _selectedDuration == val;
          return GestureDetector(
            onTap: () => setState(() => _selectedDuration = val),
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xff98bad5) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$val',
                  style: TextStyle(
                    fontSize: 20,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSoundPicker() {
    String tempSelectedSound = _selectedSound; // Temporary variable for selection
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Select Ambient Sound',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context), // Close without saving
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _soundOptions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, idx) {
                        final sound = _soundOptions[idx];
                        final isSelected = tempSelectedSound == sound['name'];
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempSelectedSound = sound['name']!; // Update temp selection
                            });
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? const Color(0xff98bad5) : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(sound['path']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                if (isSelected)
                                  const Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(Icons.check_circle, color: Colors.white),
                                  ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    color: Colors.black54,
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      sound['name']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedSound = tempSelectedSound; // Apply selection on Done
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff98bad5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBeginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          final inhale = 4; // for both 4:6 and custom currently
          final exhale = 6;
          final rounds = (_selectedDuration * 60) ~/ (inhale + exhale);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BilateralScreen(
                inhaleDuration: inhale,
                exhaleDuration: exhale,
                rounds: rounds,
                imagePath: _selectedImage,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff98bad5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'BEGIN',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  List<Widget> _buildInstructionSteps() {
    return [
      _buildStepCard(1, 'Sit comfortably or lie flat. Relax your shoulders.'),
      _buildStepCard(2, 'Place one hand on your chest, one on your abdomen.'),
      _buildStepCard(3, 'Inhale deeply through your nose for 4 seconds, feeling your stomach rise.'),
      _buildStepCard(4, 'Exhale slowly through pursed lips for 6 seconds, engaging your abdomen.'),
      _buildStepCard(5, 'Repeat for your selected duration, maintaining a smooth rhythm.'),
    ];
  }

  Widget _buildStepCard(int num, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xff98bad5),
              child: Text(num.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
          ],
        ),
      ),
    );
  }

  Widget _buildLearnMoreButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AbdominalBreathingLearnMorePage()),
            );
          },
          child: const Text(
            'Learn More →',
            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}