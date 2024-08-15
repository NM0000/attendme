import 'package:flutter/material.dart';

class RecentCoursesScreen extends StatelessWidget {
  const RecentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Recent Courses',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16), // Space between title and course list
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
                    'Lorem ipsum dolor jashfkahfauifhwfhakjfhwofhakfhfkalfjhoiihfahfoihfahfoifhaoifhoaifhohfaofsit amet, consectetur adipiscing elit.',
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
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        _showCourseInfo(context, title, description);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(screenWidth * 0.02),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              assetPath,
              width: screenWidth * 0.3, // Adjust width based on screen size
              height: screenWidth * 0.2, // Adjust height based on screen size
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
