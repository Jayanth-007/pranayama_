import 'package:flutter/material.dart';

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
          backgroundImage: AssetImage('assets/user_avatar.png'), // Replace with your asset path
        ),
        SizedBox(width: 20.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Name',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Text(
              'Meditation Enthusiast',
              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
          ],
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
    // Implement logic to fetch or display achievement data here
    // You can use a ListView or other widgets to display achievements
    return Text('No achievements unlocked yet. Keep meditating!');
  }
}