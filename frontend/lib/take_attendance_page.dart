import 'package:flutter/material.dart';

class TakeAttendancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
      ),
      body: Center(
        child: Text(
          'Take Attendance Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
