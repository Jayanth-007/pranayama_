import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meditation_app/courses/abdominal_breathing_page.dart';
import 'package:meditation_app/courses/bhramari_pranayama_page.dart';
import 'package:meditation_app/greeting/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contributers.dart';


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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        'assets/images/fav.jpg', // <-- Replace with your image if needed
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.favorite, color: const Color(0xffE63946)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'View Favorite Courses',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff457B9D),
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xff457B9D)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.0),
            Divider(color: const Color(0xff457B9D).withOpacity(0.3)),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        'assets/images/aboutus.jpg', // <-- Replace with your image if needed
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xff457B9D)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'About Us',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff457B9D),
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xff457B9D)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContributorsPage()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        'assets/images/contri.jpg', // <-- Replace with your image if needed
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xff457B9D)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Contributers',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff457B9D),
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: const Color(0xff457B9D)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // App's color scheme
    final Color primaryBlue = const Color(0xff457B9D);
    final Color lightBlue = const Color(0xffA8DADC);
    final Color cream = const Color(0xffF1FAEE);
    final Color accentRed = const Color(0xffE63946);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom app bar with parallax effect
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'About Us',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/yoga_banner.jpg', // Add this image to your assets
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryBlue, lightBlue],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          primaryBlue.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Container(
              color: cream,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and mission statement
                  _buildLogoSection(context, lightBlue, primaryBlue),

                  // Our story
                  _buildStorySection(context, primaryBlue, lightBlue),

                  // SURYA Program
                  _buildProgramSection(context, 'SURYA Program',
                      'Student Upliftment and Rejuvenation through Yoga',
                      Icons.school, primaryBlue, lightBlue),

                  // PRAME App
                  _buildProgramSection(context, 'PRAME App',
                      'Bringing ancient wisdom to the digital age',
                      Icons.smartphone, primaryBlue, lightBlue),

                  // Our Philosophy
                  _buildPhilosophySection(context, primaryBlue, lightBlue, accentRed),

                  // Founder section
                  _buildFounderSection(context, primaryBlue, lightBlue),

                  // Get in touch
                  _buildContactSection(context, primaryBlue, lightBlue, accentRed),

                  // Footer
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    color: primaryBlue,
                    child: Center(
                      child: Text(
                        '© 2025 Yoga Mandir, Bengaluru - All Rights Reserved',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context, Color lightBlue, Color primaryBlue) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Logo animation
          TweenAnimationBuilder(
            duration: Duration(seconds: 1),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: lightBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.spa, size: 60, color: primaryBlue),
                    Icon(Icons.waterfall_chart, size: 80, color: primaryBlue.withOpacity(0.3)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Yoga Mandir, Bengaluru',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Est. 1989',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: primaryBlue.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: lightBlue, width: 1),
            ),
            child: Text(
              'A registered charitable trust dedicated to promoting yoga as a holistic path to physical, mental, and spiritual well-being.',
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, Color primaryBlue, Color lightBlue) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories, color: primaryBlue, size: 28),
              SizedBox(width: 12),
              Text(
                'Our Story',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Established in 1989 by Yogaratna Dr. S N Omkar, Yoga Mandir has been a beacon of authentic yoga practice and teaching in Bengaluru for over three decades.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryBlue.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'From its humble beginnings, it has grown into a respected institution that has touched thousands of lives through its dedication to the ancient practice of yoga.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryBlue.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSection(BuildContext context, String title, String subtitle, IconData icon, Color primaryBlue, Color lightBlue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightBlue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryBlue, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: primaryBlue.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (title == 'SURYA Program')
            Text(
              'Our flagship program nurtures young minds through Patanjali-inspired teachings, promoting holistic development and well-being among students.',
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue.withOpacity(0.8),
              ),
            )
          else
            Text(
              'The PRAME app is our initiative to bring the timeless wisdom of yoga to the digital age, making authentic practices accessible to everyone, anywhere.',
              style: TextStyle(
                fontSize: 16,
                color: primaryBlue.withOpacity(0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhilosophySection(BuildContext context, Color primaryBlue, Color lightBlue, Color accentRed) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: primaryBlue, size: 28),
              SizedBox(width: 12),
              Text(
                'Our Philosophy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightBlue.withOpacity(0.3), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '"Like a lotus leaf remains untouched by water, one should act without attachment."',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  '— Bhagavad Gita 5.10',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Text(
                  'Our logo symbolizes a drop of water blooming through yoga and pranayama, representing the core philosophy that guides our practice.',
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryBlue.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 24),

                // Core values with interactive elements
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCoreValueItem(context, 'Focus', Icons.lightbulb, primaryBlue, lightBlue),
                    _buildCoreValueItem(context, 'Devotion', Icons.volunteer_activism, primaryBlue, lightBlue),
                    _buildCoreValueItem(context, 'Compassion', Icons.favorite, primaryBlue, accentRed),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreValueItem(BuildContext context, String title, IconData icon, Color primaryBlue, Color backgroundColor) {
    return InkWell(
      onTap: () {
        // Show a tooltip or description when tapped
        final snackBar = SnackBar(
          content: Text(
            title == 'Focus' ? 'The diya represents focus and mental clarity.'
                : title == 'Devotion' ? 'The folded hands symbolize devotion and surrender.'
                : 'The heart embodies compassion and love for all beings.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: primaryBlue,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: backgroundColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderSection(BuildContext context, Color primaryBlue, Color lightBlue) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: lightBlue,
            child: Icon(Icons.person, size: 60, color: primaryBlue),
          ),
          SizedBox(height: 16),
          Text(
            'Yogaratna Dr. S N Omkar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Founder',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: primaryBlue.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Under Dr. Omkar\'s guidance, Yoga Mandir remains a beacon of authentic yoga, fostering personal growth and community upliftment through the timeless wisdom of yoga practices.',
            style: TextStyle(
              fontSize: 16,
              color: primaryBlue.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, Color primaryBlue, Color lightBlue, Color accentRed) {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get In Touch',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildContactItem(Icons.location_on, 'Yoga Mandir, Bengaluru', primaryBlue),
                Divider(color: lightBlue.withOpacity(0.5)),
                _buildContactItem(Icons.email, 'info@yogamandir.org', primaryBlue),
                Divider(color: lightBlue.withOpacity(0.5)),
                _buildContactItem(Icons.phone, '+91 9876543210', primaryBlue),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    const url = 'https://docs.google.com/forms/d/e/1FAIpQLSeFmPPfJqqb3NPP4f0JHQSMOM0Z0WHRd6Ubbl3sRHlL9w-lfg/viewform'; // replace with your actual GForm link
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open the feedback form'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentRed,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Feedback form!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue, size: 20),
          SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: primaryBlue.withOpacity(0.8),
            ),
          ),
        ],
      ),
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