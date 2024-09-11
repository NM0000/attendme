import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  String teacherName = 'Loading...';
  String teacherId = 'Loading...';
  String email = 'Loading...';
  String profilePictureUrl = ''; // Placeholder for profile picture URL

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedTeacherId = prefs.getString('teacherId');

    if (storedTeacherId != null) {
      try {
        final response = await http.get(
          Uri.parse('http://192.168.1.28000/api/auth/teachers/$storedTeacherId/'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

        if (response.statusCode == 200) {
          final teacherData = jsonDecode(response.body);
          setState(() {
            teacherName =
                '${teacherData['first_name']} ${teacherData['last_name']}';
            teacherId = teacherData['teacher_id'];
            email = teacherData['email'];
            profilePictureUrl = teacherData['profile_picture'] ??
                ''; // Adjust field based on API response
          });
        } else {
          setState(() {
            teacherName = 'Failed to load data';
          });
        }
      } catch (e) {
        setState(() {
          teacherName = 'Error fetching data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        title: Text(
          'Teacher Profile',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: screenWidth * 0.06),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: screenWidth * 0.15,
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
                backgroundColor: Colors.grey[200],
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                teacherName,
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Teacher ID: $teacherId',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Email: $email',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
