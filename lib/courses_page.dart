// courses_page.dart
import 'package:flutter/material.dart';
import 'courses_grid_page.dart';

// Import your dedicated course pages:
import 'courses/abdominal_breathing_page.dart';
import 'courses/chest_breathing_page.dart';
import 'courses/complete_breathing_page.dart';
import 'courses/bhramari_pranayama_page.dart';
import 'courses/nadi_shodhana_pranayama_page.dart';
import 'courses/ujjayi_pranayama_page.dart';
import 'courses/surya_bhedana_pranayama_page.dart';
import 'courses/chandra_bhedana_pranayama_page.dart';
import 'courses/sheetali_pranayama_page.dart';
import 'courses/sheetkari_pranayama_page.dart';

class CoursesPage extends StatelessWidget {
  CoursesPage({Key? key}) : super(key: key);

  // Mapping of course titles to their dedicated pages.
  final Map<String, Widget Function()> coursePages = {
    "Abdominal Breathing": () => const AbdominalBreathingLearnMorePage(),
    "Chest Breathing": () => const ChestBreathingPage(),
    "Complete Breathing": () => const CompleteBreathingPage(),
    "Bhramari Pranayama": () => const BhramariPranayamaPage(),
    "Nadi Shodhana Pranayama": () => const NadiShodhanaPranayamaPage(),
    "Ujjayi Pranayama": () => const UjjayiPranayamaPage(),
    "Surya Bhedana Pranayama": () => const SuryaBhedanaPranayamaPage(),
    "Chandra Bhedana Pranayama": () => const ChandraBhedanaPranayamaPage(),
    "Sheetali Pranayama": () => const SheetaliPranayamaPage(),
    "Sheetkari Pranayama": () => const SheetkariPranayamaPage(),
  };

  // Sample course data for each section.
  final List<Map<String, String>> breathingCourses = [
    {"title": "Abdominal Breathing", "image": "assets/images/abdominal_breathing.png"},
    {"title": "Chest Breathing", "image": "assets/images/chest_breathing.png"},
    {"title": "Complete Breathing", "image": "assets/images/complete_breathing.png"},
  ];

  final List<Map<String, String>> pranayamaCourses = [
    {"title": "Bhramari Pranayama", "image": "assets/images/bhramari.png"},
    {"title": "Nadi Shodhana Pranayama", "image": "assets/images/nadishodana.png"},
    {"title": "Ujjayi Pranayama", "image": "assets/images/ujjayi.png"},
    {"title": "Surya Bhedana Pranayama", "image": "assets/images/suryabedhana.png"},
    {"title": "Chandra Bhedana Pranayama", "image": "assets/images/chandrabedhana.png"},
    {"title": "Sheetali Pranayama", "image": "assets/images/sheetali.png"},
    {"title": "Sheetkari Pranayama", "image": "assets/images/sheetkari.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Courses")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              title: "Breathing Techniques",
              courses: breathingCourses,
            ),
            const SizedBox(height: 20),
            _buildSection(
              context,
              title: "Pranayama",
              courses: pranayamaCourses,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section with a header and a horizontal list of courses.
  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Map<String, String>> courses,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with "View All" button.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                // Navigate to the grid view page.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursesGridPage(
                      title: title,
                      courses: courses,
                      coursePages: coursePages,
                    ),
                  ),
                );
              },
              child: const Text("View All", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        // Horizontal list of course cards.
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return _buildCourseCard(context, course);
            },
          ),
        ),
      ],
    );
  }

  /// Builds an individual course card.
  Widget _buildCourseCard(BuildContext context, Map<String, String> course) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          final courseTitle = course["title"];
          if (courseTitle != null && coursePages.containsKey(courseTitle)) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => coursePages[courseTitle]!()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No page found for $courseTitle")),
            );
          }
        },
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage(course["image"]!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Wrap title in a fixed-height container so spacing is equal
            Container(
              width: 100,
              height: 20, // Fixed height for the title area
              alignment: Alignment.center,
              child: Text(
                course["title"]!,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
