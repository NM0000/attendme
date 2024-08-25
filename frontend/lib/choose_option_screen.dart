//changes done
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'student_login.dart';
import 'teacher_login.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';
import 'landing_screen.dart';

class ChooseOptionScreen extends StatelessWidget {
  const ChooseOptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
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
                    padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Attend Me',
                          style: TextStyle(
                            fontSize: isMobile ? 20.0 : 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isMobile ? 12.0 : 16.0),
                        Text(
                          'Who are you?',
                          style: TextStyle(
                            fontSize: isMobile ? 18.0 : 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: isMobile ? 24.0 : 32.0),
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
                          imageSize: isMobile ? 60.0 : 80.0,
                          heightIncrease: 0.1,
                        ),
                        SizedBox(height: isMobile ? 24.0 : 32.0),
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
                          imageSize: isMobile ? 60.0 : 80.0,
                          heightIncrease: 0.1,
                        ),
                        SizedBox(height: isMobile ? 32.0 : 48.0),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: isMobile ? 12.0 : 16.0),
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
                                              imageSize: isMobile ? 60.0 : 80.0,
                                            ),
                                          ),
                                          SizedBox(width: isMobile ? 12.0 : 16.0),
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
                                              imageSize: isMobile ? 60.0 : 80.0,
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
                              fontSize: isMobile ? 14.0 : 16.0,
                              decoration: TextDecoration.none,
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
            top: isMobile ? 16.0 : 40.0,
            left: isMobile ? 8.0 : 16.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: isMobile ? 24.0 : 32.0,
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
        width: 150.0,
        height: 200.0 * (1 + heightIncrease),
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
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
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
