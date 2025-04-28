import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class BilateralScreen extends StatefulWidget {
  final int inhaleDuration;
  final int exhaleDuration;
  final int rounds;
  final String imagePath;

  const BilateralScreen({
    Key? key,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.rounds,
    required this.imagePath,
  }) : super(key: key);

  @override
  _BilateralScreenState createState() => _BilateralScreenState();
}

class _BilateralScreenState extends State<BilateralScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer; // Single player for all audio
  bool isRunning = false;
  bool isAudioPlaying = true;
  String breathingText = "Starting Session...";
  int _currentRound = 0;
  String _currentPhase = "prepare";

  // Guide states
  bool _isGuide1Playing = false;
  bool _isGuide2Playing = false;
  bool _showSkipGuide1 = false;
  late Timer _skipButtonTimer;

  late final AssetSource _inhaleSound;
  late final AssetSource _exhaleSound;
  late final AssetSource _guide1Sound;
  late final AssetSource _guide2Sound;

  late final double _inhaleFraction;
  late final double _gapFraction;

  @override
  void initState() {
    super.initState();

    _inhaleSound = AssetSource('../assets/music/inhale_bell1.mp3');
    _exhaleSound = AssetSource('../assets/music/exhale_bell1.mp3');
    _guide1Sound = AssetSource('../assets/music/guide-calm1.mp3');
    _guide2Sound = AssetSource('../assets/music/guide_calm2.mp3');

    final totalDuration = widget.inhaleDuration + 0.10 + widget.exhaleDuration;
    _inhaleFraction = widget.inhaleDuration / totalDuration;
    _gapFraction = (widget.inhaleDuration + 0.10) / totalDuration;

    _audioPlayer = AudioPlayer()
      ..setReleaseMode(ReleaseMode.stop)
      ..setVolume(isAudioPlaying ? 1.0 : 0.0);

    _controller = AnimationController(
      duration: Duration(seconds: totalDuration.toInt()),
      vsync: this,
    );

    _controller.addListener(_handleAnimationProgress);
    _controller.addStatusListener(_handleAnimationStatus);

    _startGuides();
  }

  Future<void> _startGuides() async {
    await _playGuide1();
  }

  Future<void> _playGuide1() async {
    try {
      setState(() {
        _isGuide1Playing = true;
        breathingText = "Relax and Prepare";
        _showSkipGuide1 = false;
      });

      // Show skip button after 3 seconds
      _skipButtonTimer = Timer(const Duration(seconds: 3), () {
        if (mounted && _isGuide1Playing) {
          setState(() => _showSkipGuide1 = true);
        }
      });

      await _audioPlayer.stop(); // Stop any previous audio
      await _audioPlayer.play(_guide1Sound);

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          _skipButtonTimer.cancel();
          _playGuide2();
        }
      });
    } catch (e) {
      debugPrint('Error playing Guide 1: $e');
      _playGuide2();
    }
  }

  Future<void> _skipGuide1() async {
    if (!_isGuide1Playing) return;

    await _audioPlayer.stop();
    _skipButtonTimer.cancel();
    if (mounted) _playGuide2();
  }

  Future<void> _playGuide2() async {
    try {
      setState(() {
        _isGuide1Playing = false;
        _isGuide2Playing = true;
        breathingText = "    Focus on\nYour Breathing";
        _showSkipGuide1 = false;
      });

      await _audioPlayer.stop(); // Stop any previous audio
      await _audioPlayer.play(_guide2Sound);

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isGuide2Playing = false;
            isRunning = true;
            breathingText = "Inhale";
            _currentPhase = "inhale";
          });
          _startBreathingCycle();
        }
      });
    } catch (e) {
      debugPrint('Error playing Guide 2: $e');
      if (mounted) {
        setState(() {
          _isGuide2Playing = false;
          isRunning = true;
          breathingText = "Inhale";
          _currentPhase = "inhale";
        });
        _startBreathingCycle();
      }
    }
  }

  Future<void> _preloadAudio() async {
    try {
      await Future.wait([
        _audioPlayer.setSource(_guide1Sound),
        _audioPlayer.setSource(_guide2Sound),
        _audioPlayer.setSource(_inhaleSound),
        _audioPlayer.setSource(_exhaleSound),
      ]);
    } catch (e) {
      debugPrint('Error preloading audio: $e');
    }
  }

  void _handleAnimationProgress() {
    if (_isGuide1Playing || _isGuide2Playing) return;

    double progress = _controller.value;
    String newPhase;

    if (progress <= _inhaleFraction) {
      newPhase = "inhale";
    } else if (progress <= _gapFraction) {
      newPhase = "gap";
    } else {
      newPhase = "exhale";
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      if (isAudioPlaying && isRunning) {
        _playPhaseSound(_currentPhase);
      }

      setState(() {
        breathingText = _currentPhase == "gap" ? "" : _currentPhase.capitalize();
      });
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (_isGuide1Playing || _isGuide2Playing) return;

    if (status == AnimationStatus.completed) {
      _currentRound++;
      if (_currentRound < widget.rounds) {
        _controller.reset();
        await Future.delayed(const Duration(milliseconds: 2));
        if (isRunning) {
          _startBreathingCycle();
        }
      } else {
        setState(() {
          isRunning = false;
          breathingText = "Complete";
        });
        await _audioPlayer.stop();
      }
    }
  }

  Future<void> _playPhaseSound(String phase) async {
    try {
      await _audioPlayer.stop(); // Stop any previous sound
      if (phase == "inhale") {
        await _audioPlayer.play(_inhaleSound);
      } else if (phase == "exhale") {
        await _audioPlayer.play(_exhaleSound);
      }
    } catch (e) {
      debugPrint('Error playing phase sound: $e');
    }
  }

  void _startBreathingCycle() {
    if (_isGuide1Playing || _isGuide2Playing) return;

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
    if (_isGuide1Playing || _isGuide2Playing) return;

    if (isRunning) {
      _controller.stop();
      await _audioPlayer.stop();
      setState(() => isRunning = false);
    } else {
      if (_currentRound >= widget.rounds) {
        _currentRound = 0;
      }
      setState(() => isRunning = true);
      _startBreathingCycle();
    }
  }

  Future<void> toggleAudio() async {
    final newVolume = isAudioPlaying ? 0.0 : 1.0;
    await _audioPlayer.setVolume(newVolume);
    setState(() => isAudioPlaying = !isAudioPlaying);
  }

  Widget _buildTextDisplay(String text) {
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
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
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
          scale = 1.5;
        } else {
          scale = 1.5 - 0.5 * ((progress - _gapFraction) / (1 - _gapFraction));
        }

        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        height: 300,
        width: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    if (_isGuide1Playing || _isGuide2Playing) {
      return const SizedBox.shrink();
    }

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
            borderRadius: BorderRadius.circular(30),
          ),
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
            borderRadius: BorderRadius.circular(30),
          ),
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
    if (_isGuide1Playing || _isGuide2Playing) {
      return const SizedBox.shrink();
    }

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
    _audioPlayer.dispose();
    _skipButtonTimer.cancel();
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
          if (_showSkipGuide1)
            Positioned(
              bottom: 100,
              right: 20,
              child: ElevatedButton(
                onPressed: _skipGuide1,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Skip Guide",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}