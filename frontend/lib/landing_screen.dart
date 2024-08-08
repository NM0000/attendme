import 'package:flutter/material.dart';
import 'choose_option_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.png', width: 250, height: 250),
            const SizedBox(height: 30),
            const Text(
              'AttendMe',
              style: TextStyle(
                fontSize: 36,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 100),
            GestureDetector(
              onTap: () {
                // Navigate to ChooseOptionScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChooseOptionScreen()),
                );
              },
              child: Image.asset('assets/next.png', width: 300, height: 300),
            ),
          ],
        ),
      ),
    );
  }
}