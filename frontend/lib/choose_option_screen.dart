import 'package:flutter/material.dart';
import 'student_login.dart';
import 'teacher_login.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Attend Me',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Who are you?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 38),
                      OptionButton(
                        text: 'Student',
                        color: Colors.teal[300]!, // Adjusted color
                        imagePath: 'assets/login.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StudentLoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      OptionButton(
                        text: 'Teacher',
                        color: Colors.orange[300]!, // Adjusted color
                        imagePath: 'assets/login.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TeacherLoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(20.0),
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
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        OptionButton(
                                          text: 'Register\nAs\nStudent',
                                          color: Colors.teal[300]!, // Adjusted color
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
                                          imageSize: 100,
                                        ),
                                        OptionButton(
                                          text: 'Register\nAs\nTeacher',
                                          color: Colors.orange[300]!, // Adjusted color
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
                                          imageSize: 100,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const Text(
                          "Don't have an account? Sign up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 10,
            child: IconButton(
              icon: Image.asset('assets/Back.png'),
              iconSize: 30,
              onPressed: () {
                Navigator.pop(context);
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
        width: 180,
        height: 200 * (1 + heightIncrease), // Increased height by 5%
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
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              imagePath,
              width: imageSize, // Increased image size
            ),
          ],
        ),
      ),
    );
  }
}
