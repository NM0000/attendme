import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'attendance_provider.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String userName = 'User'; // Default user name
  DateTime _selectedDay = DateTime.now();
  Map<String, List<String>> _reminders = {}; // To store reminders
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadReminders();
  }

  // Load the user's name from shared preferences
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? 'User';
    });
  }

  // Load reminders from shared preferences
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

  @override
  Widget build(BuildContext context) {
    String currentDate = DateFormat.yMMMMd().format(DateTime.now());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the AttendanceProvider from the context
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[300],
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
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome and Date Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Welcome, $userName',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    currentDate,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              // Calendar Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: TableCalendar(
                  focusedDay: _selectedDay,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2120, 12, 31),
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
                    leftChevronIcon:
                        Icon(Icons.chevron_left, color: Colors.brown[600]),
                    rightChevronIcon:
                        Icon(Icons.chevron_right, color: Colors.brown[600]),
                    titleTextStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[600],
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      border: Border.all(color: Colors.teal[300]!, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.teal[300]!,
                      shape: BoxShape.circle,
                    ),
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    outsideDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    todayTextStyle: TextStyle(
                      color: Colors.teal[300]!,
                      fontWeight: FontWeight.bold,
                    ),
                    defaultTextStyle: TextStyle(
                      color: Colors.brown[600],
                    ),
                    weekendTextStyle: TextStyle(
                      color: Colors.brown[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Quick Access Section
              const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildQuickAccessItem(
                      context, 'Events', Icons.event, const Color.fromARGB(255, 77, 182, 172), '/events_screen'),
                  _buildQuickAccessItem(
                      context, 'Leave Note', Icons.note_add, const Color.fromARGB(255, 247, 179, 77), '/leave_note_screen'),
                  _buildQuickAccessItem(
                      context, 'Attendance Report', Icons.receipt, const Color.fromARGB(255, 105, 184, 248), '/student_attendance_report_screen'),
                  _buildQuickAccessItem(
                      context, 'Settings', Icons.settings, const Color.fromARGB(255, 236, 101, 146), '/settings_screen'),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

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
                      _showAllAttendanceHistoryDialog();
                    },
                    child: const Text('See All'),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              ...attendanceProvider.attendanceData.entries.take(5).map((entry) {
                return _buildAttendanceHistoryItem(entry.key,
                    entry.value ? 'Present' : 'Absent', 'Subject: Example');
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
              // Scroll to top when Home is tapped
              _scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/student_profile_screen');
              break;
            case 2:
              _showMenu(context);
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickAccessItem(
      BuildContext context, String title, IconData icon, Color color, String routeName) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: screenWidth * 0.1,
              child: Icon(
                icon,
                size: screenWidth * 0.1,
                color: Colors.white,
              ),
            ),
            Positioned(
              bottom: screenWidth * 0.1,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHistoryItem(
      String date, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        title: Text(date, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(title),
      ),
    );
  }

  void _showRemindersDialog(DateTime selectedDay) {
    final dateStr = DateFormat.yMd().format(selectedDay);
    final remindersForDay = _reminders[dateStr] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text('Reminders for ${DateFormat.yMMMd().format(selectedDay)}'),
          content: remindersForDay.isEmpty
              ? const Text('No reminders for this day.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: remindersForDay
                      .map((reminder) => Text(reminder))
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
  }

  void _showAllAttendanceHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Attendance History'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ...Provider.of<AttendanceProvider>(context)
                    .attendanceData
                    .entries
                    .map((entry) => _buildAttendanceHistoryItem(entry.key,
                        entry.value ? 'Present' : 'Absent', 'Subject: Example'))
                    .toList(),
              ],
            ),
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
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.book, color: Colors.black),
                title: Text('Recent Courses'),
                onTap: () {
                  Navigator.pushNamed(context, '/recent_courses_screen');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.black),
                title: Text('Settings'),
                onTap: () {
                  Navigator.pushNamed(context, '/settings_screen');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
