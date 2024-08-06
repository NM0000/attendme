import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key}); // Use 'super.key' for the key parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'), // Use 'const' with the constructor
      ),
      body: const Center(
        child: Text('Welcome to the Home Screen!'), // Use 'const' with the constructor
      ),
    );
  }
}