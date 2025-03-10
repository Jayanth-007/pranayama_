import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class PanicBreathingPage extends StatefulWidget {
  const PanicBreathingPage({Key? key}) : super(key: key);

  @override
  _PanicBreathingPageState createState() => _PanicBreathingPageState();
}

class _PanicBreathingPageState extends State<PanicBreathingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  Timer? _timer;

  bool isRunning = false;
  bool isAudioPlaying = false;

  int _breathPhase = 0; // 0: Inhale, 1: Sharp Inhale, 2: Hold, 3: Exhale
  final List<String> _breathStages = ["Inhale", "Sharp Inhale", "Hold", "Exhale"];
  final List<int> _breathDurations = [4, 2, 2, 6]; // Durations in seconds

  @override
  void initState() {
    super.initState();

    // Animation setup for smooth breathing transitions
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _audioPlayer = AudioPlayer();
  }

  // Start Breathing Cycle Logic
  void _startBreathingCycle() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
      _breathPhase = 0;
    });

    _timer = Timer.periodic(Duration(seconds: _breathDurations[_breathPhase]), (timer) {
      setState(() {
        _breathPhase = (_breathPhase + 1) % 4;
      });
      if (_breathPhase == 0) {
        _controller.forward(from: 0.0); // Restart animation for new cycle
      }
    });
  }

  // Stop Breathing Cycle
  void _stopBreathingCycle() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      isRunning = false;
      _breathPhase = 0;
    });
  }

  // Toggle Audio Guide
  Future<void> toggleAudio() async {
    if (isAudioPlaying) {
      await _audioPlayer.pause();
    } else {
      try {
        await _audioPlayer.play(AssetSource('audio/breathing_guide.mp3'));
      } catch (e) {
        print('Error playing audio: $e');
      }
    }
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Panic Breathing Exercise",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.red,
        elevation: 10,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTextDisplay(_breathStages[_breathPhase]),
                  const SizedBox(height: 20),
                  _buildBreathingImage(),
                  const SizedBox(height: 50),
                  _buildControlButtons(),
                ],
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 10,
            right: 15,
            child: IconButton(
              icon: Icon(
                isAudioPlaying ? Icons.music_note : Icons.music_off,
                color: Colors.teal,
                size: 36.0,
              ),
              onPressed: toggleAudio,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextDisplay(String text) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black38.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreathingImage() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress = _controller.value;
          double scale = 1.0 + 0.5 * progress;

          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: Container(
          height: 150,
          width: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/images/muladhara_chakra3.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade600.withOpacity(0.75),
                blurRadius: 10,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return ElevatedButton.icon(
      onPressed: isRunning ? _stopBreathingCycle : _startBreathingCycle,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      icon: Icon(isRunning ? Icons.pause : Icons.play_arrow),
      label: Text(
        isRunning ? "Pause" : "Start",
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
