import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'reminder_screen.dart';
import 'attendance_page.dart';
import 'student_list_screen.dart';
import 'teacher_reports_screen.dart';
import 'settings_screen.dart';
import 'teacher_profile_screen.dart'; 
import 'package:camera/camera.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  _TeacherHomeScreenState createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  String teacherName = 'Teacher';
  DateTime _selectedDay = DateTime.now();
  Map<String, List<String>> _reminders = {};

  @override
  void initState() {
    super.initState();
    _loadTeacherName();
    _loadReminders();
  }

  Future<void> _loadTeacherName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      teacherName = prefs.getString('teacherName') ?? 'Teacher';
    });
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final reminderList = prefs.getStringList('reminders') ?? [];

    Map<String, List<String>> loadedReminders = {};

    for (String reminder in reminderList) {
      final parts = reminder.split(': ');
      final date = parts[0];
      final reminderText = parts[1];

      if (loadedReminders[date] == null) {
        loadedReminders[date] = [];
      }
      loadedReminders[date]!.add(reminderText);
    }

    setState(() {
      _reminders = loadedReminders;
    });
  }

  // Call this method to get the cameras list.
  Future<void> navigateToAttendancePage(BuildContext context) async {
    final cameras = await availableCameras();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendancePage(cameras: cameras),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[300],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeacherProfileScreen()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                radius: screenWidth * 0.06, // Responsive avatar size
                child: Icon(Icons.person, size: screenWidth * 0.06),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(Icons.notifications, size: screenWidth * 0.06),
              onPressed: () {
                // Handle notifications
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController, // Add a ScrollController
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome and Date Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome,',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                  ),
                  Text(
                    teacherName,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01), // Responsive spacing
                  Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04, // Responsive font size
                      color: Colors.black, // Text color
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing

              // Quick Access Section
              Column(
                children: [
                  _buildQuickAccessItem(
                      context,
                      'Take Attendance',
                      'assets/takeattendance.png',
                      null,
                      screenWidth),
                      
                  _buildQuickAccessItem(
                      context,
                      'Student List',
                      'assets/studentlist.png',
                      StudentListPage(),
                      screenWidth),
                  _buildQuickAccessItem(
                      context,
                      'Reports',
                      'assets/report.png',
                      ReportsPage(),
                      screenWidth),
                ],
              ),
              SizedBox(height: screenHeight * 0.02), // Responsive spacing

              // Calendar Section
              buildCalendar(screenWidth),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: screenWidth * 0.07),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu, size: screenWidth * 0.07),
            label: 'Menu',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Scroll to top when Home is tapped
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              break;
            case 1:
              _showMenu(context, screenWidth);
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, String title, String assetPath, Widget? page, double screenWidth) {
    return GestureDetector(
      onTap: () {
        if (title == 'Take Attendance') {
          navigateToAttendancePage(context); // Use this for the attendance page
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page!),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
        child: Container(
          height: screenWidth * 0.3, // Responsive container height
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth * 0.04), // Responsive border radius
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(1),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // Responsive font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Text color
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: AspectRatio(
                  aspectRatio: 1, // Maintain aspect ratio
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain, // Prevent distortion
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCalendar(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04), // Responsive border radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TableCalendar(
          focusedDay: _selectedDay,
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2120, 12, 31),
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
            _showRemindersDialog(selectedDay);
          },
          eventLoader: (day) {
            final dateStr = DateFormat.yMd().format(day);
            return _reminders[dateStr] ?? [];
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: screenWidth * 0.05, // Responsive font size
              fontWeight: FontWeight.bold,
              color: Colors.black, // Text color
            ),
            leftChevronIcon: Icon(Icons.chevron_left, size: screenWidth * 0.06),
            rightChevronIcon: Icon(Icons.chevron_right, size: screenWidth * 0.06),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
             

 color: Colors.blueAccent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blue,
                width: screenWidth * 0.005, // Responsive border width
              ),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(
              fontSize: screenWidth * 0.04, // Responsive font size
              color: Colors.black, // Text color
            ),
            weekendTextStyle: TextStyle(
              fontSize: screenWidth * 0.04, // Responsive font size
              color: Colors.black, // Text color
            ),
          ),
        ),
      ),
    );
  }

  void _showRemindersDialog(DateTime selectedDay) {
    final dateStr = DateFormat.yMd().format(selectedDay);
    final remindersForDay = _reminders[dateStr] ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(DateFormat.yMMMMd().format(selectedDay), style: TextStyle(color: Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: remindersForDay.isEmpty
                    ? [const Text('No reminders for this day.', style: TextStyle(color: Colors.black))]
                    : remindersForDay
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final reminder = entry.value;
                          return ListTile(
                            title: Text(reminder, style: TextStyle(color: Colors.black)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Remove the reminder
                                final prefs = await SharedPreferences.getInstance();
                                final savedReminders = prefs.getStringList('reminders') ?? [];
                                final reminderToRemove = '$dateStr: $reminder';
                                
                                savedReminders.remove(reminderToRemove);
                                await prefs.setStringList('reminders', savedReminders);

                                // Reload reminders
                                await _loadReminders();
                                
                                // Update the UI
                                setState(() {
                                  remindersForDay.removeAt(index);
                                });
                              },
                            ),
                          );
                        })
                        .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMenu(BuildContext context, double screenWidth) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.add, size: screenWidth * 0.07, color: Colors.black),
                title: Text(
                  'Add Reminder',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Smaller text size
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddReminderScreen(
                        onReminderAdded: () {
                          _loadReminders();
                        },
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, size: screenWidth * 0.07, color: Colors.black),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Smaller text size
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  final ScrollController _scrollController = ScrollController();
}