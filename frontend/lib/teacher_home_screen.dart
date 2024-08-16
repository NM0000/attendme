import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'reminder_screen.dart';
import 'live_face_recognition_page.dart';
//import 'take_attendance_screen.dart';
import 'student_list_screen.dart';
import 'teacher_reports_screen.dart';
import 'settings_screen.dart'; 

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

    print('Loaded reminders: $reminderList'); // Debug: Check loaded reminders

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

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[400],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, size: 30),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome and Date Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome,',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    teacherName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              Column(
                children: [
                  _buildQuickAccessItem(context, 'Take Attendance', 'assets/takeattendance.png', LiveFaceRecognitionPage()),
                  _buildQuickAccessItem(context, 'Student List', 'assets/studentlist.png', StudentListPage()),
                  _buildQuickAccessItem(context, 'Reports', 'assets/report.png', ReportsPage()),
                ],
              ),
              const SizedBox(height: 16),

              // Calendar Section
              buildCalendar(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
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
              _showMenu(context);
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, String title, String assetPath, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
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
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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

  Widget buildCalendar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
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
              title: Text(DateFormat.yMMMMd().format(selectedDay)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: remindersForDay.isEmpty
                    ? [const Text('No reminders for this day.')]
                    : remindersForDay
                        .asMap()
                        .entries
                        .map((entry) {
                          final index = entry.key;
                          final reminder = entry.value;
                          return ListTile(
                            title: Text(reminder),
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
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Reminder'),
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
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()), // Navigate to SettingsScreen
                );
              },
            ),
          ],
        );
      },
    );
  }

  final ScrollController _scrollController = ScrollController(); 
}
