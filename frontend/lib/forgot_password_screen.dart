import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final bool isTeacher;

  ForgotPasswordScreen({required this.isTeacher});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _idController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot Password',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.brown,
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: Container(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center align items
            children: <Widget>[
              const SizedBox(height: 30), // Gap from the top
              Center(
                child: const Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: const Text(
                  'Please enter your ID below to request a password reset.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Adjusted gap
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _idController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: widget.isTeacher ? 'Teacher ID' : 'Student ID',
                    labelStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.black54),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return widget.isTeacher
                          ? 'Please enter your Teacher ID'
                          : 'Please enter your Student ID';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20), // Adjusted gap
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      String id = _idController.text;
                      _resetPasswordRequest(id, context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Request Reset',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetPasswordRequest(String id, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text('Request Sent'),
          content: const Text(
            'Your request has been sent. The IT department will reach out to you soon for further assistance.',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the login page
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
