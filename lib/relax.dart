import 'package:flutter/material.dart';
import 'package:meditation_app/Instruction/instruction_abdo.dart';
import 'package:meditation_app/Instruction/instruction_complete.dart';
import 'package:meditation_app/Instruction/instruction_chest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditation_app/progress/graph.dart';
import 'profile/profile.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:meditation_app/courses_page.dart'; // Adjust the path as needed

class RelaxScreen extends StatefulWidget {
  const RelaxScreen({Key? key}) : super(key: key);

  @override
  State<RelaxScreen> createState() => RelaxScreenState();
}

class RelaxScreenState extends State<RelaxScreen> {
  int _currentIndex = 0;
  String _userName = 'User';
  File? _profileImage;
  final ScrollController _scrollController = ScrollController();
  double _opacity = 1.0; // Initial opacity for profile container

  // Added CoursesScreen as a placeholder at the second position.
  final List<Widget> _screens = [
    const MeditationScreen(),
    CoursesPage(),
    ProgressScreen(),
    MeditationProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = 'User';
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  // Handle scroll to fade the profile section in/out
  void _handleScroll() {
    double newOpacity = 1.0 - (_scrollController.offset / 200).clamp(0.0, 1.0);
    setState(() {
      _opacity = newOpacity; // Update opacity based on scroll position
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fade profile container based on scroll position only on Meditation tab
            if (_currentIndex == 0)
              AnimatedOpacity(
                opacity: _opacity, // Dynamically change opacity
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? const Icon(Icons.add_a_photo, size: 30, color: Colors.blueGrey)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Hello, $_userName!',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Display the selected screen based on the BottomNavigationBar index
            Expanded(
              child: _screens[_currentIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.spa),
            label: 'Meditation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          const SizedBox(height: 5),
          const SizedBox(height: 20),
          const Text(
            "MEDITATION",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            padding: const EdgeInsets.all(4.0),
            mainAxisSpacing: 16.0,
            crossAxisSpacing: 10.0,
            children: [
              BreathingBox(
                label: "Abdominal Breathing",
                gradientColors: [Colors.blueGrey, Colors.blueAccent],
                imagePath: 'assets/images/abdominal_breathing.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AbdominalBreathingPage(),
                    ),
                  );
                },
              ),
              BreathingBox(
                label: "Chest Breathing",
                gradientColors: [Colors.white, Colors.orange],
                imagePath: 'assets/images/chest_breathing.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChestBreathingPage(),
                    ),
                  );
                },
              ),
              BreathingBox(
                label: "Complete Breathing",
                gradientColors: [Colors.green, Colors.lightGreenAccent],
                imagePath: 'assets/images/complete_breathing.png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompleteBreathingPage(),
                    ),
                  );
                },
              ),
              // Additional boxes can be added here...
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "PRANAYAMA",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Grid view for Pranayama boxes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 10.0,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              // Create a list of custom labels for each box.
              final List<String> boxLabels = [
                "Bhramari Pranayama",
                "Nadi shodhana Pranayama",
                "Ujjayi Pranayama",
                "Surya Bhedana Pranayama",
                "Chandra Bhedana Pranayama",
                "Sheetali Pranayama",
                "Sheetkari Pranayama",
              ];

              // Create a list of image paths for each box.
              final List<String> backgroundImages = [
                'assets/images/bhramari.png',
                'assets/images/nadishodana.png',
                'assets/images/ujjayi.png',
                'assets/images/suryabedhana.png',
                'assets/images/chandrabedhana.png',
                'assets/images/sheetali.png',
                'assets/images/sheetkari.png',
              ];

              // List of gradient color pairs (optional, if you still want gradients).
              final List<List<Color>> gradients = [
                [Colors.indigo, Colors.blue],
                [Colors.cyan, Colors.teal],
                [Colors.red, Colors.orange],
                [Colors.yellow, Colors.orange],
                [Colors.purple, Colors.deepPurple],
                [Colors.green, Colors.lightGreenAccent],
                [Colors.pink, Colors.deepOrangeAccent],
              ];

              return BreathingBox(
                label: boxLabels[index],
                gradientColors: gradients[index % gradients.length],
                imagePath: backgroundImages[index],
                onTap: () {
                  // Add your desired onTap functionality here.
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class BreathingBox extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final String imagePath;
  final VoidCallback onTap;

  const BreathingBox({
    Key? key,
    required this.label,
    required this.gradientColors,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(25), // Rounded edges with radius 25
          boxShadow: const [
            BoxShadow(
              color: Colors.white60,
              blurRadius: 8.0,
              offset: Offset(2, 4),
            ),
          ],
        ),
        // Use ClipRRect to clip the image to the container's rounded edges
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
              // Positioned title at the bottom of the box
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.white54, // Optional: for better readability
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
