import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'teacher_home_screen.dart';
import 'forgot_password_screen.dart';

class TeacherLoginScreen extends StatefulWidget {
  const TeacherLoginScreen({super.key});

  @override
  _TeacherLoginScreenState createState() => _TeacherLoginScreenState();
}

class _TeacherLoginScreenState extends State<TeacherLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      String emailOrTeacherId = _emailController.text;
      String password = _passwordController.text;

      var response = await http.post(
        Uri.parse('http://192.168.1.2:8000/api/auth/teacher/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email_or_teacher_id': emailOrTeacherId,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Print the entire response for debugging
        print('Response: $jsonResponse');

        // Check if token is present
        if (jsonResponse.containsKey('token')) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TeacherHomeScreen()),
          );
        } else {
          _showErrorDialog(jsonResponse['message'] ?? 'Login failed');
        }
      } else {
        _showErrorDialog('Invalid credentials! Please try again');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: screenHeight * 0.05,
              left: screenWidth * 0.03,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.brown[800], // Deep Brown color
                  size: screenWidth * 0.1,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: MediaQuery.of(context).viewInsets.bottom > 0
                    ? screenHeight * 0.05
                    : screenHeight * 0.02,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.1),
                  Image.asset(
                    'assets/logo.png',
                    width: screenWidth * 0.4,
                    height: screenHeight * 0.2,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Welcome to Attend Me',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.brown, // Sombre Brown
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      color: Colors.brown, // Sombre Brown
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Teacher Id/ Email',
                            border: OutlineInputBorder(),
                            labelStyle:
                                TextStyle(color: Colors.brown), // Sombre Brown
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your teacher ID or email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            labelStyle:
                                TextStyle(color: Colors.brown), // Sombre Brown
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ForgotPasswordScreen(isTeacher: true),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: screenWidth * 0.045, // Highlight Color
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        GestureDetector(
                          onTap: _login,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.brown, // Sombre Brown
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.02),
                            ),
                            child: Center(
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}