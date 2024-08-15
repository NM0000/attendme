import 'package:flutter/material.dart';
import 'student_login.dart';
import 'teacher_login.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';
import 'landing_screen.dart';

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.brown[200],
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Attend Me',
                          style: TextStyle(
                            fontSize: screenWidth * 0.1, // Responsive font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Who are you?',
                          style: TextStyle(
                            fontSize: screenWidth * 0.08, // Responsive font size
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        OptionButton(
                          text: 'Student',
                          color: Colors.teal[300]!,
                          imagePath: 'assets/login.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const StudentLoginScreen()),
                            );
                          },
                          imageSize: screenWidth * 0.2, // Increased image size
                          heightIncrease: 0.1, // Increased height multiplier
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        OptionButton(
                          text: 'Teacher',
                          color: Colors.orange[300]!,
                          imagePath: 'assets/login.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const TeacherLoginScreen()),
                            );
                          },
                          imageSize: screenWidth * 0.2, // Increased image size
                          heightIncrease: 0.1, // Increased height multiplier
                        ),
                        SizedBox(height: screenHeight * 0.06),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: screenHeight * 0.02),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OptionButton(
                                              text: 'Register\nAs\nStudent',
                                              color: Colors.teal[300]!,
                                              imagePath: 'assets/register.png',
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const StudentRegisterScreen()),
                                                );
                                              },
                                              textAlign: TextAlign.center,
                                              heightIncrease: 0.05,
                                              imageSize: screenWidth * 0.2, // Responsive image size
                                            ),
                                          ),
                                          SizedBox(width: screenWidth * 0.04),
                                          Expanded(
                                            child: OptionButton(
                                              text: 'Register\nAs\nTeacher',
                                              color: Colors.orange[300]!,
                                              imagePath: 'assets/register.png',
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          const TeacherRegisterScreen()),
                                                );
                                              },
                                              textAlign: TextAlign.center,
                                              heightIncrease: 0.05,
                                              imageSize: screenWidth * 0.2, // Responsive image size
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(
                              color: Colors.indigo[900],
                              fontSize: screenWidth * 0.04, // Responsive font size
                              decoration: TextDecoration.none, // Removed underline
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.05,
            left: screenWidth * 0.02,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: screenWidth * 0.08, // Responsive icon size
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String text;
  final Color color;
  final String imagePath;
  final VoidCallback onTap;
  final TextAlign textAlign;
  final double heightIncrease;
  final double imageSize;

  const OptionButton({
    required this.text,
    required this.color,
    required this.imagePath,
    required this.onTap,
    this.textAlign = TextAlign.left,
    this.heightIncrease = 0,
    this.imageSize = 80,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: 200 * (1 + heightIncrease), // Adjusted height based on the multiplier
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.06, // Responsive font size
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Image.asset(
              imagePath,
              width: imageSize,
            ),
          ],
        ),
      ),
    );
  }
}
