import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Your events content goes here
            // For example:
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Math Exam'),
              subtitle: const Text('Date: 25th Aug, 2024'),
            ),
            const SizedBox(height: 16),
            // More events...
          ],
        ),
      ),
    );
  }
}
