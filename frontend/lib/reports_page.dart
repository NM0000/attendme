import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Center(
        child: Text(
          'Reports Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}