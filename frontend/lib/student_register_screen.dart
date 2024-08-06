import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'choose_option_screen.dart';

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
  final int _maxImages = 10;
  List<File> _images = [];
  bool _isCapturing = false;

  // Angles to capture: front, left, right, up, down
  final List<String> _requiredAngles = ['Front', 'Left', 'Right', 'Up', 'Down'];
  List<String> _capturedAngles = [];

  Future<void> _pickImage(String angle) async {
    // Bypass the actual image picking and add a placeholder image
    setState(() {
      _images.add(File('assets/placeholder.png'));  // Add a placeholder image path
      _capturedAngles.add(angle);
    });

    // Check if all required angles are captured
    if (_capturedAngles.toSet().containsAll(_requiredAngles.toSet()) ||
        _images.length >= _maxImages) {
      setState(() {
        _isCapturing = false;
      });
    } else {
      _showCaptureFaceDialog();
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() &&
        _capturedAngles.toSet().containsAll(_requiredAngles.toSet())) {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://your-django-backend-url/api/accounts/register/'),
      );

      request.fields['studentId'] = _studentIdController.text;
      request.fields['password'] = _passwordController.text;
      request.fields['email'] = _emailController.text;
      request.fields['batch'] = _batchController.text;
      request.fields['first_name'] = _firstNameController.text;
      request.fields['last_name'] = _lastNameController.text;
      request.fields['enrolled_year'] = _enrolledYearController.text;

      for (var image in _images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', image.path),
        );
      }

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
            content: const Text('Registered successfully.'),
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
        print('Registration failed: ${response.reasonPhrase}');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
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
          content:
              const Text('Please capture images from all required angles.'),
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

  void _showCaptureFaceDialog() {
    final remainingAngles = _requiredAngles
        .where((angle) => !_capturedAngles.contains(angle))
        .toList();
    final nextAngle =
        remainingAngles.isNotEmpty ? remainingAngles.first : 'any angle';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture Face'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please capture a photo from the $nextAngle.'),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the dialog
                _pickImage(nextAngle); // Capture image
              },
              child: Image.asset('assets/camera_button.png',
                  width: 40, height: 40),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset('assets/Back.png', width: 40, height: 40),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Register as Student',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _batchController,
                        decoration: const InputDecoration(
                          labelText: 'Batch',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your batch';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _enrolledYearController,
                        decoration: const InputDecoration(
                          labelText: 'Enrolled Year',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your enrolled year';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'Student Id',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Student Id';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _capturedAngles
                                    .toSet()                                    .containsAll(_requiredAngles.toSet()) ||
                                _images.length >= _maxImages
                            ? null
                            : () => _showCaptureFaceDialog(),
                        child: Text(_isCapturing
                            ? 'Capturing…'
                            : 'Capture Facial Data'),
                      ),
                      const SizedBox(height: 16),
                      _images.isEmpty
                          ? const Text('No images selected.')
                          : Wrap(
                              children: _images.map((image) {
                                return Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Image.file(image,
                                      width: 100, height: 100),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

                                   
