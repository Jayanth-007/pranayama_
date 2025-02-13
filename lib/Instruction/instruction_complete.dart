import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class CompleteBreathingPage extends StatefulWidget {
  @override
  _CompleteBreathingPageState createState() => _CompleteBreathingPageState();
}

class _CompleteBreathingPageState extends State<CompleteBreathingPage> {
  String? _selectedTechnique;
  final List<String> _breathingTechniques = [
    '2:3 Breathing Technique',
    '4:6 Breathing Technique',
    'Meditation Breathing',
    '5:6 Breathing',
    'Customize Breathing Technique',
  ];

  String? _videoUrl; // To store the YouTube video URL
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();
    _fetchVideoUrlFromFirestore();
    _selectedTechnique = _breathingTechniques.isNotEmpty ? _breathingTechniques[0] : null;
  }

  Future<void> _fetchVideoUrlFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc('complete_breathing')
          .get();

      if (snapshot.exists) {
        String? videoUrl = snapshot.get('videoUrl');
        setState(() {
          _videoUrl = videoUrl;
          _youtubePlayerController = YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(videoUrl!)!,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching video URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Breathing"),
        centerTitle: true,
      ),
      body: _videoUrl == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Select a Breathing Technique",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                });
              },
            ),
            SizedBox(height: 16.0),
            // New Informational Section
            Text(
              "What is Complete Breathing?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              "Complete breathing is a combination of abdominal, thoracic, and clavicular breathing techniques. It focuses on utilizing the full capacity of the lungs for each breath, promoting better oxygen intake, relaxation, and mental clarity. Practicing complete breathing can improve overall respiratory health and reduce stress levels.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 24.0),
            Text(
              "Watch a Demonstration",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            _buildInstructionCard(1, "Sit in a comfortable position and relax your shoulders."),
            _buildInstructionCard(2, "Place one hand on your abdomen and the other on your chest."),
            _buildInstructionCard(3, "Inhale deeply through your nose for 4 seconds, feeling your abdomen expand."),
            _buildInstructionCard(4, "Exhale slowly through your mouth for 6 seconds, noticing your abdomen contract."),
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
                // Add redirection or action for "Learn More" button here
              },
              child: Text("Learn More"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTechnique() {
    if (_selectedTechnique == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a technique')),
      );
      return;
    }

    switch (_selectedTechnique) {
      case '2:3 Breathing Technique':
        Navigator.pushNamed(context, '/breathing24');
        break;
      case '4:6 Breathing Technique':
        Navigator.pushNamed(context, '/breathing46');
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
}
