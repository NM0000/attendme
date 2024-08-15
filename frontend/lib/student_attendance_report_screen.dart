import 'package:flutter/material.dart';

class StudentAttendanceReportScreen extends StatelessWidget {
  const StudentAttendanceReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Report'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: List.generate(10, (index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text('Subject $index'),
                subtitle: Text('Attendance details here'),
                trailing: Text('95%'),
                onTap: () {
                  // Handle attendance report tap
                  Navigator.pushNamed(context, '/attendance_report_detail_screen');
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
