import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class BoxBreathingScreen extends StatefulWidget {
  final int inhaleDuration;  // seconds for Inhale phase
  final int hold1Duration;   // seconds for first Hold phase
  final int exhaleDuration;  // seconds for Exhale phase
  final int hold2Duration;   // seconds for second Hold phase
  final int rounds;          // number of rounds

  const BoxBreathingScreen({
    Key? key,
    required this.inhaleDuration,
    required this.hold1Duration,
    required this.exhaleDuration,
    required this.hold2Duration,
    required this.rounds,
  }) : super(key: key);

  @override
  _BoxBreathingScreenState createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _inhalePlayer;
  late AudioPlayer _exhalePlayer;
  bool isRunning = false;
  bool isAudioPlaying = false;
  String breathingText = "Get Ready";
  int _currentRound = 0;
  String _currentPhase = "";

  // Audio sources (ensure these assets exist and update paths accordingly)
  late final AssetSource _inhaleSound;
  late final AssetSource _exhaleSound;

  // Total duration and phase fractions
  late final double _totalDuration;
  late final double _f1; // end of Inhale phase
  late final double _f2; // end of Hold1 phase
  late final double _f3; // end of Exhale phase
  // _f4 is implicitly 1.0 (end of Hold2 phase)

  @override
  void initState() {
    super.initState();

    // Update these asset paths to your audio files.
    _inhaleSound = AssetSource('../assets/music/inhale_bell1.mp3');
    _exhaleSound = AssetSource('../assets/music/exhale_bell1.mp3');

    _totalDuration = (widget.inhaleDuration +
        widget.hold1Duration +
        widget.exhaleDuration +
        widget.hold2Duration)
        .toDouble();
    _f1 = widget.inhaleDuration / _totalDuration;
    _f2 = (widget.inhaleDuration + widget.hold1Duration) / _totalDuration;
    _f3 = (widget.inhaleDuration + widget.hold1Duration + widget.exhaleDuration) /
        _totalDuration;

    _inhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _exhalePlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _preloadAudio();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _totalDuration.toInt()),
    );

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
    if (progress < _f1) {
      newPhase = "Inhale";
    } else if (progress < _f2) {
      newPhase = "Hold";
    } else if (progress < _f3) {
      newPhase = "Exhale";
    } else {
      newPhase = "Hold";
    }

    if (newPhase != _currentPhase) {
      _currentPhase = newPhase;
      if (isAudioPlaying) {
        _playPhaseSound(newPhase);
      }
      setState(() {
        breathingText = newPhase;
      });
    }
  }

  void _handleAnimationStatus(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      _currentRound++;
      if (_currentRound < widget.rounds) {
        _controller.reset();
        await Future.delayed(const Duration(milliseconds: 500));
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
    try {
      if (phase == "Inhale") {
        await _exhalePlayer.stop();
        await _inhalePlayer.resume();
      } else if (phase == "Exhale") {
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
      _currentPhase = "Inhale";
    });
    _controller.forward();
    if (isAudioPlaying) {
      _playPhaseSound("Inhale");
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

  /// Computes the center of the moving ball along the square’s perimeter.
  /// The square corners are defined as:
  ///   A (top-left):     (0, 0)
  ///   B (top-right):    (size, 0)
  ///   C (bottom-right): (size, size)
  ///   D (bottom-left):  (0, size)
  /// The phases:
  ///   Phase 1 (Inhale): A → B
  ///   Phase 2 (Hold):   B → C
  ///   Phase 3 (Exhale): C → D
  ///   Phase 4 (Hold):   D → A
  Offset _calculateCirclePosition(double t, double size) {
    if (t < _f1) {
      // Inhale: from A to B
      double fraction = t / _f1;
      double x = fraction * size;
      double y = 0;
      return Offset(x, y);
    } else if (t < _f2) {
      // Hold: from B to C
      double fraction = (t - _f1) / (_f2 - _f1);
      double x = size;
      double y = fraction * size;
      return Offset(x, y);
    } else if (t < _f3) {
      // Exhale: from C to D
      double fraction = (t - _f2) / (_f3 - _f2);
      double x = size * (1 - fraction);
      double y = size;
      return Offset(x, y);
    } else {
      // Hold: from D to A
      double fraction = (t - _f3) / (1 - _f3);
      double x = 0;
      double y = size * (1 - fraction);
      return Offset(x, y);
    }
  }

  /// Builds the box with the moving ball.
  /// (No text overlay inside the box now.)
  Widget _buildBoxAnimation() {
    const double boxSize = 300;
    const double ballDiameter = 20; // constant size
    const double ballRadius = ballDiameter / 2;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The box
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 4),
              ),
            ),
          ),
          // The moving ball
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              Offset circleCenter = _calculateCirclePosition(_controller.value, boxSize);
              return Positioned(
                left: circleCenter.dx - ballRadius,
                top: circleCenter.dy - ballRadius,
                child: Container(
                  width: ballDiameter,
                  height: ballDiameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the control buttons (Start/Pause/Repeat).
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
    _inhalePlayer.dispose();
    _exhalePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Box Breathing"),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the breathing phase text above the box
                  Text(
                    breathingText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // The animated box with the moving ball
                  _buildBoxAnimation(),
                  const SizedBox(height: 30),
                  // Control buttons below the box with extra spacing
                  _buildControlButtons(),
                  const SizedBox(height: 20),
                  // Rounds info
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
          // Audio toggle button positioned at the top-right.
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
