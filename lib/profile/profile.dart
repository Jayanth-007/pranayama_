import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/greeting/login_page.dart';

void main() {
  runApp(MaterialApp(
    home: MeditationApp(),
    theme: ThemeData(fontFamily: 'Poppins'),
  ));
}

class MeditationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meditation'),
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
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            _buildAchievementList(),
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
          backgroundImage: AssetImage(
              'assets/user_avatar.png'), // Replace with your asset path
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
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      size: 20,
                    ),
                    onPressed: _logout,
                  ),
                ],
              ),
              Text(
                'Meditation Enthusiast',
                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 5.0),
            Text(
              value,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementList() {
    // Implement logic to fetch or display achievement data here.
    return Text('No achievements unlocked yet. Keep meditating!');
  }
}
