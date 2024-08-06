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
                        color: Colors.teal[200]!,
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
                        color: Colors.orange[200]!,
                        imagePath: 'assets/login.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TeacherLoginScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    OptionButton(
                                      text: 'Register as Student',
                                      color: Colors.teal[200]!,
                                      imagePath: 'assets/register.png',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const StudentRegisterScreen()),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    OptionButton(
                                      text: 'Register as Teacher',
                                      color: Colors.orange[200]!,
                                      imagePath: 'assets/register.png',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const TeacherRegisterScreen()),
                                        );
                                      },
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

  const OptionButton({
    required this.text,
    required this.color,
    required this.imagePath,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Image.asset(
              imagePath,
              width: 100,
            ),
          ],
        ),
      ),
    );
  }
}