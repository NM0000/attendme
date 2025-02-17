import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String studentId = '';
  String firstName = '';
  String lastName = '';
  String batch = '';
  String enrolledYear = '';
  String email = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentProfile();
  }

  Future<void> _fetchStudentProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access');

    if (accessToken == null) {
      _showErrorDialog('Access token is missing. Please log in again.');
      return;
    }

    print('Access Token: $accessToken'); // Debug print

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.5:8000/api/auth/student/profile/'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}'); // Debug print
      print('Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          studentId = data['student_id'] ?? '';
          firstName = data['first_name'] ?? '';
          lastName = data['last_name'] ?? '';
          batch = data['batch'] ?? '';
          enrolledYear = (data['enrolled_year'] ?? '').toString(); // Convert to String
          email = data['email'] ?? '';
          isLoading = false;
        });
      } else {
        _showErrorDialog('Failed to load profile. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error'); // Debug print
      _showErrorDialog('An error occurred while fetching profile data.');
    }
  }

  void _showErrorDialog(String message) {
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
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: const Text(
            'Student Profile',
            style: TextStyle(color: Colors.white), // White font color
          ),
        ),
        backgroundColor: Colors.brown[300], // Keep the original color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      '${firstName[0]}${lastName[0]}',
                      style: TextStyle(fontSize: 40, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced height
                  Text(
                    '$firstName $lastName',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Student ID: $studentId',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('Batch'),
                    subtitle: Text(batch),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Enrolled Year'),
                    subtitle: Text(enrolledYear),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    subtitle: Text(email),
                  ),
                ],
              ),
      ),
    );
  }
}