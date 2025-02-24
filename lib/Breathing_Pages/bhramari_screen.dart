import 'package:flutter/material.dart';
import 'dart:async';
import 'package:just_audio/just_audio.dart';

class BhramariScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;

  const BhramariScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.rounds,
  }) : super(key: key);

  @override
  _BhramariScreenState createState() => _BhramariScreenState();
}

class _BhramariScreenState extends State<BhramariScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Using just_audio's AudioPlayer.
  late AudioPlayer _exhalePlayer;
  Timer? _exhaleTimer;

  bool isRunning = false;
  bool isAudioPlaying = false;
  String breathingText = "Get Ready";
  int _currentRound = 0;
  String _currentPhase = "prepare";

  // Path to your asset (assumed to be 8 seconds long).
  final String _exhaleAssetPath = '../assets/music/humming_sound.mp3';

  // Phase boundary.
  late final double _inhaleFraction;

  @override
  void initState() {
    super.initState();

    // Total duration = inhale + exhale (in seconds)
    final totalDuration = widget.inhaleDuration + widget.exhaleDuration;
    _inhaleFraction = widget.inhaleDuration / totalDuration;

    // Initialize the just_audio AudioPlayer.
    _exhalePlayer = AudioPlayer();

    // Set the audio source from asset.
    _setAudioSource();

    _controller = AnimationController(
      duration: Duration(seconds: totalDuration),
      vsync: this,
    );

    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);
  }

  Future<void> _setAudioSource() async {
    try {
      // Use AudioSource.asset for assets.
      await _exhalePlayer.setAudioSource(AudioSource.asset(_exhaleAssetPath));
    } catch (e) {
      debugPrint('Error setting audio source: $e');
    }
  }

  void _handleAnimationProgress() {
    double progress = _controller.value;
    String newPhase;

    if (progress <= _inhaleFraction) {
      newPhase = "inhale";
    } else {
      newPhase = "exhale";
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      if (isAudioPlaying) {
        _playPhaseSound(_currentPhase);
      }
      setState(() {
        breathingText = _currentPhase.capitalize();
      });
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _currentRound++;
      if (_currentRound < widget.rounds) {
        _controller.reset();
        // Small delay for smoother transition.
        await Future.delayed(const Duration(milliseconds: 2));
        if (isRunning) {
          _startBreathingCycle();
        }
      } else {
        setState(() {
          isRunning = false;
          breathingText = "Complete";
        });
        await _stopAllAudio();
      }
    }
  }

  Future<void> _playPhaseSound(String phase) async {
    if (phase == "inhale") {
      // No audio during inhale.
      _exhaleTimer?.cancel();
      await _exhalePlayer.stop();
    } else if (phase == "exhale") {
      _exhaleTimer?.cancel();
      await _exhalePlayer.stop();

      // Calculate the speed factor:
      // For an 8-second audio, to play in widget.exhaleDuration seconds:
      double speedFactor = 8.0 / widget.exhaleDuration;

      // Set the playback speed (time stretching with pitch correction on supported platforms).
      await _exhalePlayer.setSpeed(speedFactor);

      // Restart the audio from the beginning.
      await _exhalePlayer.seek(Duration.zero);
      await _exhalePlayer.play();

      // Optionally, schedule a stop if needed after the desired duration.
      _exhaleTimer = Timer(Duration(seconds: widget.exhaleDuration), () async {
        await _exhalePlayer.stop();
      });
    }
  }

  void _startBreathingCycle() {
    setState(() {
      breathingText = "Inhale";
      _currentPhase = "inhale";
    });
    _controller.forward();
    if (isAudioPlaying) {
      _playPhaseSound("inhale");
    }
  }

  Future<void> toggleBreathing() async {
    if (isRunning) {
      _controller.stop();
      await _stopAllAudio();
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

  Future<void> _stopAllAudio() async {
    _exhaleTimer?.cancel();
    await _exhalePlayer.stop();
  }

  Future<void> toggleAudio() async {
    final newVolume = isAudioPlaying ? 0.0 : 1.0;
    await _exhalePlayer.setVolume(newVolume);
    setState(() {
      isAudioPlaying = !isAudioPlaying;
    });
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
        double scale;

        if (progress <= _inhaleFraction) {
          scale = 1.0 + 0.5 * (progress / _inhaleFraction);
        } else {
          scale = 1.5 - 0.5 * ((progress - _inhaleFraction) / (1 - _inhaleFraction));
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  @override
  void dispose() {
    _controller.dispose();
    _exhaleTimer?.cancel();
    _exhalePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bhramari Breathing",
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

// Extension to capitalize strings.
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
