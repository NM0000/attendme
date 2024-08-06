import 'package:flutter/material.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Teacher Home Screen!'),
      ),
    );
  }
}