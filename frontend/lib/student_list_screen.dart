import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<dynamic> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/students/'));//change gar hai chaiyema

    if (response.statusCode == 200) {
      setState(() {
        students = jsonDecode(response.body);
      });
    } else {
      // Handle error
      print('Failed to load students');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
      ),
      body: students.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text('${student['first_name']} ${student['last_name']}'),
                  subtitle: Text('ID: ${student['studentId']}, Batch: ${student['batch']}, Year: ${student['enrolled_year']}'),
                  trailing: Text('Email: ${student['email']}'),
                );
              },
            ),
    );
  }
}
