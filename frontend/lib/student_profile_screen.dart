import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Your profile content goes here
            // For example:
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('John Doe'),
              subtitle: const Text('Student ID: 123456'),
            ),
            const SizedBox(height: 16),
            // More profile details...
          ],
        ),
      ),
    );
  }
}
