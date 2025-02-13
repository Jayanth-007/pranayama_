import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class BilateralScreen extends StatefulWidget {
  final int inhaleDuration; // Duration in seconds for inhale
  final int exhaleDuration; // Duration in seconds for exhale
  final int rounds; // Total number of rounds to perform

  const BilateralScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.rounds,
  }) : super(key: key);

  @override
  _BilateralScreenState createState() => _BilateralScreenState();
}

class _BilateralScreenState extends State<BilateralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  bool isRunning = false;
  bool isAudioPlaying = false;
  String breathingText = "Inhale";
  int _currentRound = 0; // Counts completed rounds
  String _currentPhase = "inhale"; // Tracks the current breathing phase

  @override
  void initState() {
    super.initState();

    // Set up the AnimationController with the sum of inhale and exhale durations.
    _controller = AnimationController(
      duration: Duration(seconds: widget.inhaleDuration + widget.exhaleDuration),
      vsync: this,
    );

    // Update the breathing text and phase based on animation progress.
    _controller.addListener(() {
      double progress = _controller.value;
      double inhaleFraction = widget.inhaleDuration /
          (widget.inhaleDuration + widget.exhaleDuration);

      String newPhase = (progress <= inhaleFraction) ? "inhale" : "exhale";
      if (newPhase != _currentPhase) {
        _currentPhase = newPhase;
        _playPhaseSound(_currentPhase); // Play sound for the new phase
      }

      setState(() {
        breathingText = _currentPhase == "inhale" ? "Inhale" : "Exhale";
      });
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _currentRound++;
        if (_currentRound < widget.rounds) {
          _controller.reset();
          await Future.delayed(const Duration(milliseconds: 5));
          _startBreathingCycle();
        } else {
          setState(() {
            isRunning = false;
          });
        }
      }
    });

    _audioPlayer = AudioPlayer();
  }

  // Play the sound for the current breathing phase
  void _playPhaseSound(String phase) async {
    if (!isAudioPlaying) return; // Skip if audio is muted

    String soundFile = phase == "inhale"
        ? '../assets/music/inhale_bell.mp3'
        : '../assets/music/exhale_bell.mp3';

    await _audioPlayer.stop(); // Stop any ongoing sound
    await _audioPlayer.play(AssetSource(soundFile));
  }

  // Starts the breathing cycle.
  void _startBreathingCycle() {
    _controller.forward();
  }

  // Toggles the breathing cycle.
  void toggleBreathing() {
    if (isRunning) {
      _controller.stop();
      setState(() {
        isRunning = false;
      });
    } else {
      if (_currentRound >= widget.rounds) {
        _currentRound = 0;
      }
      setState(() {
        isRunning = true;
      });
      _startBreathingCycle();
    }
  }

  // Toggles mute/unmute without pausing or resuming playback.
  Future<void> toggleAudio() async {
    if (isAudioPlaying) {
      await _audioPlayer.setVolume(0);
    } else {
      await _audioPlayer.setVolume(1);
    }
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        double inhaleFraction = widget.inhaleDuration /
            (widget.inhaleDuration + widget.exhaleDuration);
        double scale;

        if (progress <= inhaleFraction) {
          scale = 1.0 + 0.5 * (progress / inhaleFraction);
        } else {
          scale = 1.5 - 0.5 * ((progress - inhaleFraction) / (1 - inhaleFraction));
        }

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
    );
  }

  Widget _buildControlButtons() {
    if (_currentRound >= widget.rounds) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            _currentRound = 0;
            isRunning = true;
          });
          _controller.reset();
          _startBreathingCycle();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
          elevation: 10,
        ),
        child: const Text(
          "Repeat",
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: toggleBreathing,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Abdominal Breathing",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
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
                  _buildTextDisplay(breathingText),
                  const SizedBox(height: 20),
                  _buildBreathingImage(),
                  const SizedBox(height: 50),
                  _buildControlButtons(),
                  Text(
                    "Round: ${_currentRound < widget.rounds ? _currentRound + 1 : widget.rounds} / ${widget.rounds}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
}