import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/Instruction/instruction_abdo.dart';
import 'package:meditation_app/Instruction/instruction_bhramari.dart';
import 'package:meditation_app/Instruction/instruction_chandra.dart';
import 'package:meditation_app/Instruction/instruction_complete.dart';
import 'package:meditation_app/Instruction/instruction_chest.dart';
import 'package:meditation_app/Instruction/instruction_nadi.dart';
import 'package:meditation_app/Instruction/instruction_sheetali.dart';
import 'package:meditation_app/Instruction/instruction_sheetkari.dart';
import 'package:meditation_app/Instruction/instruction_surya.dart';
import 'package:meditation_app/Instruction/instruction_ujjayi.dart';
import 'package:meditation_app/Instruction/instruction_box.dart'; // For BoxBreathingPage
import 'package:meditation_app/panic_breathing_page.dart'; // For PanicBreathingPage
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditation_app/progress/graph.dart';
import 'profile/profile.dart';
import 'package:flutter/rendering.dart';
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
  String? _profileImageUrl; // URL from Google sign-in (if available)

  // Screens for the BottomNavigationBar.
  // For the Meditation tab, we pass username, profile image (File?), photoUrl, and pickImage callback.
  late final List<Widget> _screens = [
    MeditationScreen(
      userName: _userName,
      profileImage: _profileImage,
      photoUrl: _profileImageUrl,
      pickImage: _pickImage,
    ),
    CoursesPage(),
    ProgressScreen(),
    MeditationProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Fetch the user's name and photo URL from Firestore and FirebaseAuth.
  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Load the user's name from Firestore.
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _userName = doc.get('name') ?? 'User';
          // Also, get the photo URL from FirebaseAuth if available.
          _profileImageUrl = user.photoURL;
          _screens[0] = MeditationScreen(
            userName: _userName,
            profileImage: _profileImage,
            photoUrl: _profileImageUrl,
            pickImage: _pickImage,
          );
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
        // Once the user picks an image, update the MeditationScreen.
        _screens[0] = MeditationScreen(
          userName: _userName,
          profileImage: _profileImage,
          photoUrl: _profileImageUrl,
          pickImage: _pickImage,
        );
      });
    }
  }

  // Navigate to Panic Breathing Page.
  void _handlePanicButton() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PanicBreathingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The Meditation tab now has its header built into the screen.
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xff304674), // Accent
        selectedItemColor: const Color(0xff98bad5), // Primary
        unselectedItemColor: const Color(0xffc6d3e3), // Secondary
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
      floatingActionButton: FloatingActionButton(
        onPressed: _handlePanicButton,
        backgroundColor: const Color(0xff98bad5), // Primary
        child: const Icon(Icons.warning, color: Colors.white),
      ),
    );
  }
}

// MeditationScreen now uses a NestedScrollView with a SliverAppBar that integrates the
// profile picture (as a clickable avatar) into the collapsed title.
class MeditationScreen extends StatefulWidget {
  final String userName;
  final File? profileImage;
  final String? photoUrl; // URL from Google sign-in
  final Future<void> Function() pickImage;

  const MeditationScreen({
    Key? key,
    required this.userName,
    required this.profileImage,
    required this.photoUrl,
    required this.pickImage,
  }) : super(key: key);

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
    return NestedScrollView(
      // The SliverAppBar builds the header.
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              // When collapsed, the title shows a row with the avatar and greeting.
              title: Row(
                children: [
                  GestureDetector(
                    onTap: widget.pickImage,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xffc6d3e3), // Secondary
                      backgroundImage: widget.profileImage != null
                          ? FileImage(widget.profileImage!)
                          : (widget.photoUrl != null
                          ? NetworkImage(widget.photoUrl!)
                          : null) as ImageProvider<Object>?,
                      child: (widget.profileImage == null && widget.photoUrl == null)
                          ? const Icon(
                        Icons.add_a_photo,
                        size: 16,
                        color: Colors.blueGrey,
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hello, ${widget.userName}!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff304674), // Accent
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              // Replace the blue gradient with your image background
              background: Image.asset(
                'assets/images/blossoms.png', // Your image asset path
                fit: BoxFit.cover,
              ),
            ),
          ),
        ];
      },
      // The body contains your original Meditation content.
      body: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
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
                  color: Color(0xff304674), // Accent
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
                    // Gradient: Primary -> Secondary
                    gradientColors: [
                      const Color(0xff98bad5),
                      const Color(0xffc6d3e3),
                    ],
                    imagePath: 'assets/images/2.gif',
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
                    // Gradient: Background -> Light Accent
                    gradientColors: [
                      const Color(0xffd8e1e8),
                      const Color(0xffb2cbde),
                    ],
                    imagePath: 'assets/images/1.gif',
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
                    // Gradient: Accent -> Primary
                    gradientColors: [
                      const Color(0xff304674),
                      const Color(0xff98bad5),
                    ],
                    imagePath: 'assets/images/3.gif',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompleteBreathingPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                "PRANAYAMA",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff304674), // Accent
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Grid view for Pranayama boxes.
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 7,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final List<String> boxLabels = [
                    "Bhramari Pranayama",
                    "Nadi shodhana Pranayama",
                    "Ujjayi Pranayama",
                    "Surya Bhedana Pranayama",
                    "Chandra Bhedana Pranayama",
                    "Sheetali Pranayama",
                    "Sheetkari Pranayama",
                  ];

                  final List<String> backgroundImages = [
                    'assets/images/4.gif',
                    'assets/images/5.gif',
                    'assets/images/6.gif',
                    'assets/images/7.gif',
                    'assets/images/8.gif',
                    'assets/images/9.gif',
                    'assets/images/10.gif',
                  ];

                  // Updated gradients based on the new color theme.
                  final List<List<Color>> gradients = [
                    // Bhramari Pranayama: Accent -> Primary
                    [const Color(0xff304674), const Color(0xff98bad5)],
                    // Nadi shodhana Pranayama: Secondary -> Light Accent
                    [const Color(0xffc6d3e3), const Color(0xffb2cbde)],
                    // Ujjayi Pranayama: Primary -> Accent
                    [const Color(0xff98bad5), const Color(0xff304674)],
                    // Surya Bhedana Pranayama: Light Accent -> Primary
                    [const Color(0xffb2cbde), const Color(0xff98bad5)],
                    // Chandra Bhedana Pranayama: Accent -> Light Accent
                    [const Color(0xff304674), const Color(0xffb2cbde)],
                    // Sheetali Pranayama: Primary -> Secondary
                    [const Color(0xff98bad5), const Color(0xffc6d3e3)],
                    // Sheetkari Pranayama: Secondary -> Accent
                    [const Color(0xffc6d3e3), const Color(0xff304674)],
                  ];

                  return BreathingBox(
                    label: boxLabels[index],
                    gradientColors: gradients[index % gradients.length],
                    imagePath: backgroundImages[index],
                    onTap: () {
                      if (boxLabels[index] == "Bhramari Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BhramariBreathingPage(),
                          ),
                        );
                      } else if (boxLabels[index] == "Nadi shodhana Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NadiShodhanaPage(),
                          ),
                        );
                      } else if (boxLabels[index] == "Ujjayi Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UjjayiPranayamaPage(),
                          ),
                        );
                      } else if (boxLabels[index] == "Surya Bhedana Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuryaBhedanaPranayamaPage(),
                          ),
                        );
                      } else if (boxLabels[index] == "Chandra Bhedana Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChandraBhedanaPranayamaPage(),
                          ),
                        );
                      } else if (boxLabels[index] == "Sheetali Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SheetaliPranayamaPage(),
                          ),
                        );
                      } else if (boxLabels[index] == "Sheetkari Pranayama") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SheetkariPranayamaPage(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              // New Section: ADVANCED BREATHING with Box Breathing course
              const SizedBox(height: 40),
              const Text(
                "ADVANCED BREATHING",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff304674), // Accent
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
                    label: "Box Breathing",
                    // Gradient: Accent -> Primary
                    gradientColors: [
                      const Color(0xff304674),
                      const Color(0xff98bad5),
                    ],
                    imagePath: 'assets/images/boxbreathing.jpeg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxBreathingPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.white60,
              blurRadius: 8.0,
              offset: Offset(2, 4),
            ),
          ],
        ),
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
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff304674), // Accent for text contrast
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.white54,
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
