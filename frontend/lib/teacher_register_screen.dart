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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.2:8000/api/auth/teacher/register/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'teacher_id': _idController.text,
            'first_name': _firstNameController.text,
            'last_name': _lastNameController.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'password2': _confirmPasswordController.text,
          }),
        );

        if (response.statusCode == 201) {
          final jsonResponse = jsonDecode(response.body);

          // Extract tokens from the response
          final tokenData = jsonResponse['token'];
          final accessToken = tokenData['access'];
          final refreshToken = tokenData['refresh'];

          if (accessToken != null && refreshToken != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('access', accessToken);
            await prefs.setString('refresh', refreshToken);

            // After registration, call the GET request to fetch teacher data
            await _getTeacherData(_idController.text); // Call GET after registration

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const ChooseOptionScreen()),
              (route) => false,
            );
          } else {
            _showFailureDialog('Failed to retrieve tokens from the response.');
          }
        } else {
          _showFailureDialog('Registration failed. Status Code: ${response.statusCode}');
        }
      } catch (e) {
        _showFailureDialog('An error occurred: $e');
      }
    }
  }

  Future<void> _getTeacherData(String teacherId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.2:8000/api/auth/teacher/$teacherId/'), // Adjust URL based on your backend endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Use the response data (this can be displayed, processed, etc.)
        final teacherData = jsonDecode(response.body);
        print('Teacher Data: $teacherData'); // Example of using the data
      } else {
        print('Failed to fetch teacher data');
      }
    } catch (e) {
      print('Error fetching teacher data: $e');
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
        title: Text(
          'Register as Teacher',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
                SizedBox(height: screenHeight * 0.02), // Reduced top margin
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.04),
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
                      SizedBox(height: screenHeight * 0.02),
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
                        controller: _emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
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
                          minimumSize: Size(screenWidth * 0.7, screenHeight * 0.05),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          side: BorderSide(
                            color: Colors.brown[800]!,
                            width: 2.0,
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
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
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