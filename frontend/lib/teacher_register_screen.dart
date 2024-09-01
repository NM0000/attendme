import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'choose_option_screen.dart';

class TeacherRegisterScreen extends StatefulWidget {
  const TeacherRegisterScreen({super.key});

  @override
  State<TeacherRegisterScreen> createState() => _TeacherRegisterScreenState();
}

class _TeacherRegisterScreenState extends State<TeacherRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      print("Form is valid, proceeding with registration...");

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/auth/teachers/register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'teacher_id': _idController.text,
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'password': _passwordController.text,
          'password2': _confirmPasswordController.text,
        }),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', responseBody['access']);
        await prefs.setString('refresh', responseBody['refresh']);

        _showOtpDialog();
      } else {
        _showFailureDialog('Registration failed. Please try again.');
      }
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
      Uri.parse('http://10.0.0.2/api/auth/teacher/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'teacher_id': _idController.text,
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
                  'Register as Teacher',
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTextFormField(
                  controller: _idController,
                  labelText: 'Teacher ID',
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
                  controller: _passwordController,
                  labelText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.02),
                _buildTextFormField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: screenHeight * 0.03),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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
                      minimumSize: Size(screenWidth * 0.7, screenHeight * 0.05),
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