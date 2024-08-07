import 'package:flutter/material.dart';

class RecentCoursesScreen extends StatelessWidget {
  const RecentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Courses', 
          style:TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold
            ) 
          ),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            const SizedBox(height: 16), // Increased space between title and course list
            Expanded(
              child: ListView(
                children: [
                  _buildRecentCourseItem(
                    context,
                    'Human Computer Interaction',
                    'assets/human_computer_interface.png',
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  ),
                  _buildRecentCourseItem(
                    context,
                    'Professionalism at Work Place',
                    'assets/professionalism_at_work_place.png',
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  ),
                  _buildRecentCourseItem(
                    context,
                    'Data Mining',
                    'assets/data_mining.png',
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  ),
                  _buildRecentCourseItem(
                    context,
                    'Capstone Project',
                    'assets/capstone_project.png',
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  ),
                  _buildRecentCourseItem(
                    context,
                    'IoT',
                    'assets/IoT.png',
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentCourseItem(BuildContext context, String title, String assetPath, String description) {
    return GestureDetector(
      onTap: () {
        _showCourseInfo(context, title, description);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(assetPath, width: 100, height: 75, fit: BoxFit.cover),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCourseInfo(BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
