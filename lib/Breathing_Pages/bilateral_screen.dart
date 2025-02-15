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
  // Controls mute/unmute state: true means unmuted (audio is audible), false means muted.
  bool isAudioPlaying = false;
  String breathingText = "Inhale";
  int _currentRound = 0; // Counts completed rounds

  @override
  void initState() {
    super.initState();

    // Set up the AnimationController with the sum of inhale and exhale durations.
    _controller = AnimationController(
      duration: Duration(seconds: widget.inhaleDuration + widget.exhaleDuration),
      vsync: this,
    );

    // Update the breathing text based on animation progress.
    _controller.addListener(() {
      setState(() {
        double progress = _controller.value;
        double inhaleFraction =
            widget.inhaleDuration / (widget.inhaleDuration + widget.exhaleDuration);
        breathingText = (progress <= inhaleFraction) ? "Inhale" : "Exhale";
      });
    });

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        _currentRound++;
        if (_currentRound < widget.rounds) {
          _controller.reset();
          // A brief delay before restarting the cycle.
          await Future.delayed(const Duration(milliseconds: 5));
          _startBreathingCycle();
        } else {
          // Completed all rounds; stop the animation.
          setState(() {
            isRunning = false;
          });
          // If using the 4:6 breathing technique, pause the audio.
          if (widget.inhaleDuration == 4 && widget.exhaleDuration == 6) {
            await _audioPlayer.pause();
          }
        }
      }
    });

    _audioPlayer = AudioPlayer();
  }

  // Starts the breathing cycle and, if using 4:6, starts the audio.
  void _startBreathingCycle() {
    _controller.forward();
    if (widget.inhaleDuration == 4 && widget.exhaleDuration == 6) {
      _startBreathingAudio();
    }
  }

  // Sets up the 10-second breathing audio to loop.
  Future<void> _startBreathingAudio() async {
    // Set the source to your 10-second audio file.
    await _audioPlayer.setSource(AssetSource('../assets/music/bell_sound.mp3'));
    // Set the audio to loop.
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // Restart the audio from the beginning.
    await _audioPlayer.seek(Duration.zero);
    // Resume (or start) the audio.
    await _audioPlayer.resume();
    // Respect the current mute state.
    if (!isAudioPlaying) {
      await _audioPlayer.setVolume(0);
    } else {
      await _audioPlayer.setVolume(1);
    }
  }

  // Toggles the breathing cycle. When pausing, it pauses both the animation and audio.
  void toggleBreathing() {
    if (isRunning) {
      _controller.stop();
      // If using the 4:6 breathing technique, pause the audio so it stays in sync.
      if (widget.inhaleDuration == 4 && widget.exhaleDuration == 6) {
        _audioPlayer.pause();
      }
      setState(() {
        isRunning = false;
      });
    } else {
      // If starting a new session, reset the round counter.
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
      // Mute: set volume to 0.
      await _audioPlayer.setVolume(0);
    } else {
      // Unmute: set volume to 1.
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
          // Scale increases during inhale from 1.0 to 1.5.
          scale = 1.0 + 0.5 * (progress / inhaleFraction);
        } else {
          // Scale decreases during exhale from 1.5 back to 1.0.
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
    // If all rounds have been completed, show a "Repeat" button.
    if (_currentRound >= widget.rounds) {
      return ElevatedButton(
        onPressed: () {
          // Reset the counter and start the cycle (and audio) again.
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
                  // Display the current breathing instruction.
                  _buildTextDisplay(breathingText),
                  const SizedBox(height: 20),
                  // Display the breathing image that scales.
                  _buildBreathingImage(),
                  const SizedBox(height: 50),
                  // Show the control button (Start/Pause or Repeat)
                  _buildControlButtons(),
                  // Optionally display the current round out of total rounds.
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
          // Positioned audio toggle button.
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
