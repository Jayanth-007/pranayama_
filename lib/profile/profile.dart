import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/courses/abdominal_breathing_page.dart';
import 'package:meditation_app/courses/bhramari_pranayama_page.dart';
import 'package:meditation_app/greeting/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: MeditationApp(),
    theme: ThemeData(
      fontFamily: 'Poppins',
      primaryColor: const Color(0xffA8DADC), // Pastel blue
      scaffoldBackgroundColor: const Color(0xffF1FAEE), // Pastel cream
      appBarTheme: const AppBarTheme(
        color: Color(0xff457B9D), // Pastel dark blue
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ),
  ));
}

class MeditationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meditation'),
        backgroundColor: const Color(0xff457B9D),
      ),
      body: MeditationProfile(),
    );
  }
}

class MeditationProfile extends StatefulWidget {
  @override
  _MeditationProfileState createState() => _MeditationProfileState();
}

class _MeditationProfileState extends State<MeditationProfile> {
  int meditationSessions = 0;
  double totalMeditationTime = 0.0;
  String userName = "User Name";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          userName = doc.get('name') ?? 'User Name';
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 20.0),
            _buildMeditationStats(),
            SizedBox(height: 20.0),
            Divider(color: const Color(0xff457B9D).withOpacity(0.3)),
            SizedBox(height: 20.0),
            Text(
              'Recent Achievements',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xff457B9D), // Pastel dark blue
              ),
            ),
            SizedBox(height: 10.0),
            _buildAchievementList(),
            SizedBox(height: 20.0),
            Divider(color: const Color(0xff457B9D).withOpacity(0.3)),
            SizedBox(height: 20.0),
            Text(
              'Favorites',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xff457B9D), // Pastel dark blue
              ),
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: const Color(0xffE63946)), // Pastel red
              title: Text('View Favorite Courses',
                  style: TextStyle(color: const Color(0xff457B9D))),
              trailing: Icon(Icons.arrow_forward_ios, color: const Color(0xff457B9D)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 50.0,
          backgroundColor: const Color(0xffA8DADC), // Pastel blue
          child: Icon(Icons.person, size: 50, color: const Color(0xff457B9D)), // Pastel dark blue
        ),
        SizedBox(width: 20.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff457B9D), // Pastel dark blue
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, size: 20, color: const Color(0xff457B9D)),
                    onPressed: _logout,
                  ),
                ],
              ),
              Text(
                'Meditation Enthusiast',
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color(0xffA8DADC).withOpacity(0.8), // Pastel blue
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeditationStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Sessions', '$meditationSessions'),
        _buildStatCard('Total Time', '${totalMeditationTime.toStringAsFixed(1)} min'),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffA8DADC), // Pastel blue
            Color(0xffF1FAEE), // Pastel cream
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures the Column wraps content properly
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              color: const Color(0xff457B9D).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 5.0), // Added const for optimization
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xff457B9D), // Pastel dark blue
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAchievementList() {
    // Implement logic to fetch or display achievement data here.
    return Text(
      'No achievements unlocked yet. Keep meditating!',
      style: TextStyle(color: const Color(0xff457B9D).withOpacity(0.8)),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<String> favoriteCourses = [];
  bool _isLoading = true;
  String currentUserId = 'guest';

  // List of all possible courses.
  final List<String> allCourses = [
    "Abdominal Breathing",
    "Chest Breathing",
    "Complete Breathing",
    "Bhramari Pranayama",
    "Nadi Shodhana Pranayama",
    "Ujjayi Pranayama",
    "Surya Bhedana Pranayama",
    "Chandra Bhedana Pranayama",
    "Sheetali Pranayama",
    "Sheetkari Pranayama",
  ];

  // Mapping of course names to their respective pages.
  final Map<String, WidgetBuilder> coursePages = {
    "Abdominal Breathing": (context) => AbdominalBreathingLearnMorePage(),
    "Chest Breathing": (context) => CoursePage(title: "Chest Breathing"),
    "Complete Breathing": (context) => CoursePage(title: "Complete Breathing"),
    "Bhramari Pranayama": (context) => BhramariBreathingLearnMorePage(),
    "Nadi Shodhana Pranayama": (context) => CoursePage(title: "Nadi Shodhana Pranayama"),
    "Ujjayi Pranayama": (context) => CoursePage(title: "Ujjayi Pranayama"),
    "Surya Bhedana Pranayama": (context) => CoursePage(title: "Surya Bhedana Pranayama"),
    "Chandra Bhedana Pranayama": (context) => CoursePage(title: "Chandra Bhedana Pranayama"),
    "Sheetali Pranayama": (context) => CoursePage(title: "Sheetali Pranayama"),
    "Sheetkari Pranayama": (context) => CoursePage(title: "Sheetkari Pranayama"),
  };

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    currentUserId = user?.uid ?? 'guest';
    _loadFavoriteCourses();
  }

  // Helper: Generate the key used for a course's favorite status.
  String _favoriteKey(String courseTitle) {
    return "favorite_" +
        courseTitle.toLowerCase().replaceAll(" ", "_") +
        "_$currentUserId";
  }

  Future<void> _loadFavoriteCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tempFavorites = [];
    for (String course in allCourses) {
      bool isFav = prefs.getBool(_favoriteKey(course)) ?? false;
      if (isFav) {
        tempFavorites.add(course);
      }
    }
    setState(() {
      favoriteCourses = tempFavorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Courses'),
        backgroundColor: const Color(0xff457B9D),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteCourses.isEmpty
          ? Center(
        child: Text(
          'No favorite courses added yet.',
          style: TextStyle(color: const Color(0xff457B9D)),
        ),
      )
          : ListView.builder(
        itemCount: favoriteCourses.length,
        itemBuilder: (context, index) {
          String course = favoriteCourses[index];
          return ListTile(
            leading: Icon(Icons.spa, color: const Color(0xffA8DADC)), // Pastel blue
            title: Text(course, style: TextStyle(color: const Color(0xff457B9D))),
            trailing: Icon(Icons.arrow_forward_ios, color: const Color(0xff457B9D)),
            onTap: () {
              if (coursePages.containsKey(course)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: coursePages[course]!),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Page not available")));
              }
            },
          );
        },
      ),
    );
  }
}

class CoursePage extends StatelessWidget {
  final String title;
  const CoursePage({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xff457B9D),
      ),
      body: Center(
        child: Text(
          "This is the page for $title",
          style: TextStyle(color: const Color(0xff457B9D)),
        ),
      ),
    );
  }
}