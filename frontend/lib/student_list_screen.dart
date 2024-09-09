import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentListPage extends StatefulWidget {
  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  List<dynamic> students = [];
  List<dynamic> filteredStudents = [];
  String searchQuery = '';
  String selectedBatch = '';
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    final response = await http.get(Uri.parse('http://192.168.1.2:8000/api/student/'));

    if (response.statusCode == 200) {
      setState(() {
        students = jsonDecode(response.body);
        filteredStudents = students; // Initially, filtered students are all students
      });
    } else {
      // Handle error
      print('Failed to load students');
    }
  }

  void _filterStudents() {
    setState(() {
      filteredStudents = students.where((student) {
        final matchesBatch = selectedBatch.isEmpty || student['batch'] == selectedBatch;
        final matchesYear = selectedYear == null || student['enrolled_year'] == selectedYear;
        final matchesSearch = searchQuery.isEmpty ||
            student['first_name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
            student['last_name'].toLowerCase().contains(searchQuery.toLowerCase());

        return matchesBatch && matchesYear && matchesSearch;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Students'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Select Batch (Month)'),
                value: selectedBatch.isEmpty ? null : selectedBatch,
                items: [
                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                ].map((month) => DropdownMenuItem(value: month, child: Text(month))).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedBatch = value ?? '';
                  });
                },
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Select Year'),
                value: selectedYear,
                items: List.generate(
                        101, (index) => 2000 + index)
                    .map((year) => DropdownMenuItem(value: year, child: Text('$year')))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _filterStudents();
              },
              child: Text('Apply'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  selectedBatch = '';
                  selectedYear = null;
                });
                _filterStudents();
              },
              child: Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search and Filter Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filterStudents();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
          // Student List
          Expanded(
            child: filteredStudents.isEmpty
                ? Center(child: Text('No students found'))
                : ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];
                      return ListTile(
                        title: Text('${student['first_name']} ${student['last_name']}'),
                        subtitle: Text(
                            'ID: ${student['student_id']}, Batch: ${student['batch']}, Year: ${student['enrolled_year']}'),
                        trailing: Text('Email: ${student['email']}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}