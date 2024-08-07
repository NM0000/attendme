import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'attendance_provider.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String userName = 'User'; // Default user name

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // Load the user's name from shared preferences
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());

    // Get the AttendanceProvider from the context
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
              radius: 20,
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.pushNamed(context, '/notification_screen');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome and Date Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentDate,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reminder Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reminder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Show all reminders
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const Text('Subject: Computer Design'),
                    const Text('Class: F104'),
                    const Text('Time: 1:00 - 3:00'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Access Section
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAccessItem(context, 'Calendar', 'assets/calender.png', '/calendar_screen'),
                  _buildQuickAccessItem(context, 'Events', 'assets/event.png', '/events_screen'),
                  _buildQuickAccessItem(context, 'Leave Note', 'assets/leave_notes.png', '/leave_note_screen'),
                  _buildQuickAccessItem(context, 'Attendance Record', 'assets/attendance_report.png', '/attendance_record_screen'),
                ],
              ),
              const SizedBox(height: 16),

              // Attendance History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Show all attendance history
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...attendanceProvider.attendanceData.entries.map((entry) {
                return _buildAttendanceHistoryItem(entry.key, entry.value ? 'Present' : 'Absent', 'Subject: Example');
              }).toList(),
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
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home_screen');
              break;
            case 1:
              Navigator.pushNamed(context, '/profile_screen');
              break;
            case 2:
              _showMenu(context);
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickAccessItem(BuildContext context, String title, String assetPath, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Column(
        children: [
          Image.asset(assetPath, width: 40, height: 40),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistoryItem(String date, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
          const SizedBox(height: 4),
          Text(subtitle),
        ],
      ),
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
              leading: Icon(Icons.book),
              title: Text('Recent Courses'),
              onTap: () {
                Navigator.pushNamed(context, '/recent_courses_screen');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings_screen');
              },
            ),
          ],
        );
      },
    );
  }
}
