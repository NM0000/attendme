import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'student_login.dart';
import 'teacher_login.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';
import 'landing_screen.dart';

class ChooseOptionScreen extends StatefulWidget {
  const ChooseOptionScreen({super.key});

  @override
  State<ChooseOptionScreen> createState() => _ChooseOptionScreenState();
}

class _ChooseOptionScreenState extends State<ChooseOptionScreen> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Stack(
        children: [
          Positioned(
            top: isMobile ? 40.0 : 64.0,
            left: isMobile ? 16.0 : 24.0,
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              iconSize: isMobile ? 32.0 : 40.0,
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen()),
                );
              },
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: isMobile ? 100.0 : 120.0),
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF00796B).withOpacity(0.3),
                          blurRadius: 15.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Attend Me',
                          style: TextStyle(
                            fontSize: isMobile ? 32.0 : 36.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16.0 : 20.0),
                        Text(
                          'Who are you?',
                          style: TextStyle(
                            fontSize: isMobile ? 20.0 : 24.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212121),
                          ),
                        ),
                        SizedBox(height: isMobile ? 16.0 : 20.0),
                        OptionButton(
                          text: 'Student',
                          color: Colors.teal[300]!,
                          imagePath: 'assets/login.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentLoginScreen()),
                            );
                          },
                          imageSize: isMobile ? 80.0 : 100.0,
                          heightIncrease: 0.1,
                        ),
                        SizedBox(height: isMobile ? 16.0 : 20.0),
                        OptionButton(
                          text: 'Teacher',
                          color: Colors.orange[300]!,
                          imagePath: 'assets/login.png',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TeacherLoginScreen()),
                            );
                          },
                          imageSize: isMobile ? 80.0 : 100.0,
                          heightIncrease: 0.1,
                        ),
                        SizedBox(height: isMobile ? 28.0 : 36.0),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20.0),
                                      topRight: Radius.circular(20.0),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF00796B).withOpacity(0.3),
                                        blurRadius: 15.0,
                                        offset: Offset(0, -5),
                                      ),
                                    ],
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
                                                  MaterialPageRoute(builder: (context) => const StudentRegisterScreen()),
                                                );
                                              },
                                              textAlign: TextAlign.center,
                                              heightIncrease: 0.1,
                                              imageSize: isMobile ? 80.0 : 100.0,
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
                                                  MaterialPageRoute(builder: (context) => const TeacherRegisterScreen()),
                                                );
                                              },
                                              textAlign: TextAlign.center,
                                              heightIncrease: 0.1,
                                              imageSize: isMobile ? 80.0 : 100.0,
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
                              color: Colors.teal[300]!,
                              fontSize: isMobile ? 16.0 : 18.0,
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
    this.imageSize = 100,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180.0,
        height: 220.0 * (1 + heightIncrease),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15.0,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: textAlign,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.0),
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
