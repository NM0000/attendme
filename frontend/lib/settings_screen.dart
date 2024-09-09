import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  Future<bool> _validateCurrentPassword(String currentPassword) async {
    // Replace with your backend API URL for password validation
    const url = 'https://your-backend-api.com/validate-current-password';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'password': currentPassword}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['valid']; // Ensure this is a boolean value
    } else {
      throw Exception('Failed to validate password.');
    }
  }

  Future<void> _changePassword(
      BuildContext context,
      String currentPassword,
      String newPassword,
      String confirmPassword) async {
    try {
      final isCurrentPasswordValid = await _validateCurrentPassword(currentPassword);

      if (!isCurrentPasswordValid) {
        _showFeedbackDialog(context, 'Error', 'Current password is incorrect.');
        return;
      }

      if (newPassword != confirmPassword) {
        _showFeedbackDialog(context, 'Error', 'New password and confirm password do not match.');
        return;
      }

      if (newPassword == currentPassword) {
        _showFeedbackDialog(context, 'Error', 'New password cannot be the same as the current password.');
        return;
      }

      // Replace with your backend API URL for password change
      const url = 'http://192.168.1.2:8000/api/auth/changepassword/';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('password', newPassword);
          Navigator.of(context).pop(); // Close the change password dialog
          _showFeedbackDialog(context, 'Success', 'Password has been changed successfully.');
        } else {
          _showFeedbackDialog(context, 'Error', data['message']);
        }
      } else {
        _showFeedbackDialog(context, 'Error', 'Failed to change password. Please try again later.');
      }
    } catch (e) {
      _showFeedbackDialog(context, 'Error', e.toString());
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(labelText: 'Current Password'),
                obscureText: true,
              ),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password'),
                obscureText: true,
              ),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Change Password'),
              onPressed: () async {
                String currentPassword = currentPasswordController.text.trim();
                String newPassword = newPasswordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();

                await _changePassword(context, currentPassword, newPassword, confirmPassword);
              },
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                await _logout(context); // Call the _logout method
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        backgroundColor: Colors.brown[300], // Consistent with ChooseOptionScreen
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: isMobile ? 32.0 : 40.0),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      backgroundColor: Colors.brown[50], // Consistent with ChooseOptionScreen
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  _showChangePasswordDialog(context);
                },
                icon: const Icon(Icons.lock, size: 30),
                label: const Text('Change Password'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 20.0, vertical: isMobile ? 12.0 : 16.0),
                  textStyle: TextStyle(fontSize: isMobile ? 16.0 : 18.0),
                  backgroundColor: Colors.teal[300], // Attractive color
                  foregroundColor: Colors.white, // Text color
                  elevation: 5,
                  shadowColor: Colors.teal[300]?.withOpacity(0.5), // Subtle shadow effect
                ),
              ),
              SizedBox(height: isMobile ? 20.0 : 24.0),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/help_screen');
                },
                icon: const Icon(Icons.help, size: 30),
                label: const Text('Help'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 20.0, vertical: isMobile ? 12.0 : 16.0),
                  textStyle: TextStyle(fontSize: isMobile ? 16.0 : 18.0),
                  backgroundColor: Colors.orange[300], // Attractive color
                  foregroundColor: Colors.white, // Text color
                  elevation: 5,
                  shadowColor: Colors.orange[300]?.withOpacity(0.5), // Subtle shadow effect
                ),
              ),
              SizedBox(height: isMobile ? 20.0 : 24.0),
              ElevatedButton.icon(
                onPressed: () {
                  _showLogoutConfirmation(context);
                },
                icon: const Icon(Icons.logout, size: 30),
                label: const Text('Log Out'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 20.0, vertical: isMobile ? 12.0 : 16.0),
                  textStyle: TextStyle(fontSize: isMobile ? 16.0 : 18.0),
                  backgroundColor: Colors.red[300], // Attractive color
                  foregroundColor: Colors.white, // Text color
                  elevation: 5,
                  shadowColor: Colors.red[300]?.withOpacity(0.5), // Subtle shadow effect
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}