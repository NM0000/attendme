import 'package:flutter/material.dart';

class RecentCoursesScreen extends StatelessWidget {
  const RecentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Courses'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Courses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRecentCourseItem('Human Computer Interaction', 'assets/human_computer_interface.png'),
                  _buildRecentCourseItem('Professionalism at Work Place', 'assets/professionalism_at_work_place.png'),
                  _buildRecentCourseItem('Data Mining', 'assets/data_mining.png'),
                  _buildRecentCourseItem('Capstone Project', 'assets/capstone_project.png'),
                  _buildRecentCourseItem('IoT', 'assets/IoT.png'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourseItem(String title, String assetPath) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(assetPath, width: 150, height: 100),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
