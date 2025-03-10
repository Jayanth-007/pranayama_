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
      primaryColor: const Color(0xff98bad5),
      scaffoldBackgroundColor: const Color(0xffd8e1e8),
      appBarTheme: const AppBarTheme(
        color: Color(0xff304674), // Accent
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
        backgroundColor: const Color(0xff304674),
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
            Text(
              'Recent Achievements',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xff304674), // Accent
              ),
            ),
            SizedBox(height: 10.0),
            _buildAchievementList(),
            SizedBox(height: 20.0),
            // Favorites Section
            Text(
              'Favorites',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xff304674),
              ),
            ),
            ListTile(
              title: Text('View Favorite Courses',
                  style: TextStyle(color: const Color(0xff304674))),
              trailing: Icon(Icons.arrow_forward_ios, color: const Color(0xff304674)),
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
          backgroundImage: AssetImage('assets/user_avatar.png'),
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
                        color: const Color(0xff304674),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, size: 20, color: const Color(0xff304674)),
                    onPressed: _logout,
                  ),
                ],
              ),
              Text(
                'Meditation Enthusiast',
                style: TextStyle(
                  fontSize: 14.0,
                  color: const Color(0xffc6d3e3), // Secondary
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
            Color(0xff304674), // Accent
            Color(0xff98bad5), // Primary
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
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.0, color: Colors.white70),
          ),
          SizedBox(height: 5.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
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
      style: TextStyle(color: const Color(0xff304674)),
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
        backgroundColor: const Color(0xff304674),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteCourses.isEmpty
          ? Center(
        child: Text(
          'No favorite courses added yet.',
          style: TextStyle(color: const Color(0xff304674)),
        ),
      )
          : ListView.builder(
        itemCount: favoriteCourses.length,
        itemBuilder: (context, index) {
          String course = favoriteCourses[index];
          return ListTile(
            title: Text(course, style: TextStyle(color: const Color(0xff304674))),
            trailing: Icon(Icons.arrow_forward_ios, color: const Color(0xff304674)),
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
        backgroundColor: const Color(0xff304674),
      ),
      body: Center(
        child: Text(
          "This is the page for $title",
          style: TextStyle(color: const Color(0xff304674)),
        ),
      ),
    );
  }
}
