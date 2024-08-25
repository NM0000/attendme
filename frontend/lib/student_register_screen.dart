//changes done
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'choose_option_screen.dart';
import 'face_capture_screen.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _enrolledYearController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<String> _recognizedFaces = [];

  Future<void> _navigateToCaptureScreen() async {
    final recognizedFaces = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FaceCaptureScreen()),
    );

    if (recognizedFaces != null && recognizedFaces is List<String>) {
      setState(() {
        _recognizedFaces = recognizedFaces;
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _recognizedFaces.isNotEmpty) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:8000/api/accounts/register/'),
      );

      request.fields['studentId'] = _studentIdController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['email'] = _emailController.text;
      request.fields['batch'] = _batchController.text;
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['enrolled_year'] = _enrolledYearController.text;
      request.fields['recognized_faces'] = jsonEncode(_recognizedFaces);

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await http.Response.fromStream(response);
        final responseData = jsonDecode(responseBody.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', responseData['token']);

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Registration successful.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChooseOptionScreen()),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registration Failed'),
            content: const Text('Registration failed. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please capture your face for recognition.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[800],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenWidth * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Register as Student',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07, // Dynamic font size
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _batchController,
                  labelText: 'Batch',
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _enrolledYearController,
                  labelText: 'Enrolled Year',
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _studentIdController,
                  labelText: 'Student ID',
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  width: double.infinity, // Full-width button
                  child: ElevatedButton(
                    onPressed: _navigateToCaptureScreen,
                    child: Text(
                      'Capture Face',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Smaller font size
                        color: Colors.black, // Black text
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015), // Smaller padding
                      backgroundColor: Colors.white,
                      minimumSize: Size(screenWidth * 0.7, screenHeight * 0.05), // Smaller size
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: double.infinity, // Full-width button
                  child: ElevatedButton(
                    onPressed: _register,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04, // Smaller font size
                        color: Colors.black, // Black text
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015), // Smaller padding
                      backgroundColor: Colors.white,
                      minimumSize: Size(screenWidth * 0.7, screenHeight * 0.05), // Smaller size
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
      ),
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }
}
