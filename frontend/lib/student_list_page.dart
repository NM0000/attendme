import 'package:flutter/material.dart';

class StudentListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
      ),
      body: Center(
        child: Text(
          'Student List Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
