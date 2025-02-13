import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AbdominalBreathingLearnMorePage extends StatefulWidget {
  const AbdominalBreathingLearnMorePage({Key? key}) : super(key: key);

  @override
  _AbdominalBreathingLearnMorePageState createState() => _AbdominalBreathingLearnMorePageState();
}

class _AbdominalBreathingLearnMorePageState extends State<AbdominalBreathingLearnMorePage> {
  YoutubePlayerController? _controller;
  bool _isPlayerInitialized = false;

  // Simulated database with YouTube video links, thumbnails, and durations
  final List<Map<String, String>> chapters = [
    {
      "title": "Chapter 1",
      "videoUrl": "https://www.youtube.com/watch?v=HhDUXFJDgB4&t=17s",
      "thumbnail": "https://img.youtube.com/vi/HhDUXFJDgB4/0.jpg",
      "duration": "17 mins",
    },
    {
      "title": "Chapter 2",
      "videoUrl": "https://www.youtube.com/watch?v=VbGu9pikl7I",
      "thumbnail": "https://img.youtube.com/vi/VbGu9pikl7I/0.jpg",
      "duration": "15 mins",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Do not initialize the player immediately.
  }

  void _initializeVideo(String videoUrl) {
    String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    // Add a listener to the controller to handle full screen orientation changes.
    _controller!.addListener(() {
      if (_controller!.value.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  void _changeChapter(String videoUrl) {
    if (_controller == null) {
      _initializeVideo(videoUrl);
      setState(() {
        _isPlayerInitialized = true;
      });
    } else {
      String videoId = YoutubePlayer.convertUrlToId(videoUrl)!;
      _controller!.load(videoId);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Widget _buildVideoPlayer() {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        aspectRatio: 16 / 9,
      ),
      builder: (context, player) {
        return player;
      },
    );
  }

  Widget _buildPlaceholder() {
    String thumbnailUrl = chapters[0]["thumbnail"]!;
    return GestureDetector(
      onTap: () {
        _initializeVideo(chapters[0]["videoUrl"]!);
        setState(() {
          _isPlayerInitialized = true;
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            thumbnailUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.black38,
          ),
          const Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Abdominal Breathing")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isPlayerInitialized ? _buildVideoPlayer() : _buildPlaceholder(),
              const SizedBox(height: 10),
              const Text(
                "Abdominal Breathing",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Learn deep abdominal breathing to improve relaxation and lung capacity.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                "Chapters",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = chapters[index];
                    return GestureDetector(
                      onTap: () => _changeChapter(chapter["videoUrl"]!),
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    chapter["thumbnail"]!,
                                    width: double.infinity,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  left: 5,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: Colors.black54,
                                    child: Text(
                                      chapter["duration"]!,
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                chapter["title"]!,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
