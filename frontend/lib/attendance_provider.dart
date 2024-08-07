import 'package:flutter/foundation.dart';

class AttendanceProvider with ChangeNotifier {
  // Example attendance data
  Map<String, bool> _attendanceData = {};

  Map<String, bool> get attendanceData => _attendanceData;

  // Method to update attendance data
  void updateAttendance(String date, bool isPresent) {
    _attendanceData[date] = isPresent;
    notifyListeners();
  }
}
