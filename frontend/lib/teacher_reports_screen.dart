import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> _studentsData = [];
  String _searchQuery = "";
  final String apiUrl = 'http://192.168.1.5:8000/api/auth/attendance/'; // Replace with your API URL

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _studentsData = data.map((student) {
            return {
              'id': student['student']['student_id'],
              'studentName': '${student['student']['first_name']} ${student['student']['last_name']}',
              'totalClasses': student['total_classes'],
              'presentCount': student['present_count'],
              'absentCount': student['absent_count'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load student data');
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _incrementAttendance(List<String> recognizedStudents) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'recognized_students': recognizedStudents,
        }),
      );

      if (response.statusCode == 200) {
        _fetchStudentData(); // Refresh the data after updating attendance
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Attendance updated successfully"),
        ));
      } else {
        throw Exception('Failed to update attendance');
      }
    } catch (e) {
      print("Error updating attendance: $e");
    }
  }

  double _calculatePercentage(int present, int total) {
    return total > 0 ? (present / total) * 100 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Student ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Total No. of Classes')),
                  DataColumn(label: Text('Present')),
                  DataColumn(label: Text('Absent')),
                  DataColumn(label: Text('Percentage')),
                ],
                rows: _studentsData
                    .where((student) =>
                        student['id'].toString().contains(_searchQuery))
                    .map(
                      (student) => DataRow(
                        cells: [
                          DataCell(Text(student['id'].toString())),
                          DataCell(Text(student['studentName'])),
                          DataCell(Text(student['totalClasses'].toString())),
                          DataCell(Text(student['presentCount'].toString())),
                          DataCell(Text(student['absentCount'].toString())),
                          DataCell(
                            Text(
                              '${_calculatePercentage(student['presentCount'], student['totalClasses']).toStringAsFixed(2)}%',
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
