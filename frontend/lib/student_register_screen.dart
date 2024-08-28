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
  final TextEditingController _otpController = TextEditingController();
  List<String> _recognizedFaces = [];

    Future<void> _navigateToCaptureScreen() async {
    final recognizedFaces = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceCaptureScreen(studentId: _studentIdController.text),
      ),
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
        Uri.parse('http://192.168.1.5:8000/api/auth/student/register/'),
      );

      request.fields['studentId'] = _studentIdController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['email'] = _emailController.text;
      request.fields['batch'] = _batchController.text;
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['enrolled_year'] = _enrolledYearController.text;

      // Attach images to the request
      for (String imagePath in _recognizedFaces) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          imagePath,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseBody = await response.stream.bytesToString();
        final parsedResponse = jsonDecode(responseBody);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', parsedResponse['access']);
        await prefs.setString('refresh', parsedResponse['refresh']);

        _showOtpDialog();
      } else {
        _showFailureDialog('Registration failed. Please try again.');
      }
    } else {
      _showFailureDialog('Please complete the form and capture your face.');
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: _otpController,
            decoration: const InputDecoration(hintText: 'OTP'),
          ),
          actions: [
            TextButton(
              onPressed: _verifyOtp,
              child: const Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyOtp() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/accounts/verify_otp/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'studentId': _studentIdController.text,
        'otp': _otpController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ChooseOptionScreen()),
        (route) => false,
      );
    } else {
      _showFailureDialog('OTP verification failed. Please try again.');
    }
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Register as Student',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTextFormField(
                  controller: _studentIdController,
                  labelText: 'Student ID',
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
                  controller: _emailController,
                  labelText: 'Email',
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _navigateToCaptureScreen,
                  child: Text(
                    _recognizedFaces.isEmpty
                        ? 'Capture Face'
                        : 'Retake Face Capture',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015),
                    backgroundColor: Colors.white,
                    minimumSize:
                        Size(screenWidth * 0.7, screenHeight * 0.05),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                ElevatedButton(
                  onPressed: _register,
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015),
                    backgroundColor: Colors.white,
                    minimumSize:
                        Size(screenWidth * 0.7, screenHeight * 0.05),
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
    FormFieldValidator<String>? validator,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
      ),
      obscureText: obscureText,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your $labelText';
            }
            return null;
          },
    );
  }
}