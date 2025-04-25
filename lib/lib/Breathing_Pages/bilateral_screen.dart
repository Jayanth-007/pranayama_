import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class BilateralScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;

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
  late AudioPlayer _inhalePlayer;
  late AudioPlayer _exhalePlayer;
  bool isRunning = false;
  bool isAudioPlaying = false;
  String breathingText = "Get Ready";
  int _currentRound = 0;
  String _currentPhase = "prepare";

  // Cache AudioSource to prevent repeated creation
  late final AssetSource _inhaleSound;
  late final AssetSource _exhaleSound;

  // Precalculate timing values
  late final double _inhaleFraction;
  late final double _gapFraction;

  @override
  void initState() {
    super.initState();

    // Initialize audio sources
    _inhaleSound = AssetSource('../assets/music/inhale_bell1.mp3');
    _exhaleSound = AssetSource('../assets/music/exhale_bell1.mp3');

    // Precalculate timing fractions
    final totalDuration = widget.inhaleDuration + 0.10 + widget.exhaleDuration;
    _inhaleFraction = widget.inhaleDuration / totalDuration;
    _gapFraction = (widget.inhaleDuration + 0.10) / totalDuration;

    // Initialize separate audio players for inhale and exhale
    _inhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _exhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    // Preload audio files
    _preloadAudio();

    _controller = AnimationController(
      duration: Duration(seconds: totalDuration.toInt()),
      vsync: this,
    );

    // Optimize animation listener
    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);
  }

  Future<void> _preloadAudio() async {
    try {
      await Future.wait([
        _inhalePlayer.setSource(_inhaleSound),
        _exhalePlayer.setSource(_exhaleSound),
      ]);
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  void _handleAnimationProgress() {
    double progress = _controller.value;
    String newPhase;

    if (progress <= _inhaleFraction) {
      newPhase = "inhale";
    } else if (progress <= _gapFraction) {
      newPhase = "gap"; // Short gap between inhale and exhale
    } else {
      newPhase = "exhale";
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      if (isAudioPlaying) {
        _playPhaseSound(_currentPhase);
      }

      setState(() {
        breathingText = _currentPhase == "gap" ? "" : _currentPhase.capitalize();
      });
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _currentRound++;
      if (_currentRound < widget.rounds) {
        _controller.reset();
        // Reduced delay for smoother transition
        await Future.delayed(const Duration(milliseconds: 2));
        if (isRunning) {
          _startBreathingCycle();
        }
      } else {
        setState(() {
          isRunning = false;
          breathingText = "Complete";
        });
        await _stopAllAudio(); // Stop audio when cycle is complete
      }
    }
  }

  Future<void> _playPhaseSound(String phase) async {
    try {
      if (phase == "inhale") {
        await _exhalePlayer.stop();
        await _inhalePlayer.resume();
      } else if (phase == "exhale") {
        await _inhalePlayer.stop();
        await _exhalePlayer.resume();
      } else {
        await _inhalePlayer.stop();
        await _exhalePlayer.stop();
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _startBreathingCycle() {
    setState(() {
      breathingText = "Inhale";
      _currentPhase = "inhale";
    });
    _controller.forward();
    if (isAudioPlaying) {
      _playPhaseSound(_currentPhase);
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
    await Future.wait([
      _inhalePlayer.stop(),
      _exhalePlayer.stop(),
    ]);
  }

  Future<void> toggleAudio() async {
    final newVolume = isAudioPlaying ? 0.0 : 1.0;
    await Future.wait([
      _inhalePlayer.setVolume(newVolume),
      _exhalePlayer.setVolume(newVolume),
    ]);
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
        } else if (progress <= _gapFraction) {
          scale = 1.5; // Hold the scale during the gap
        } else {
          scale = 1.5 - 0.5 * ((progress - _gapFraction) / (1 - _gapFraction));
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

  Widget _buildTimeProgressBar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = _controller.value;
        int totalSeconds = _controller.duration?.inSeconds ?? 1;
        int remainingSeconds = totalSeconds - (progress * totalSeconds).toInt();
        int minutes = remainingSeconds ~/ 60;
        int seconds = remainingSeconds % 60;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: 1 - progress,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _inhalePlayer.dispose();
    _exhalePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Breathing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                  const SizedBox(height: 20),
                  _buildTimeProgressBar(),
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

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}