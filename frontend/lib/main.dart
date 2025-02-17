// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:camera/camera.dart';
import 'attendance_provider.dart';
import 'attendance_page.dart';
import 'landing_screen.dart';
import 'choose_option_screen.dart';
import 'student_login.dart';
import 'teacher_login.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';
import 'settings_screen.dart';
import 'recent_courses_screen.dart';
import 'reminder_screen.dart';
import 'student_home_screen.dart';
import 'leave_note_screen.dart';
import 'events_screen.dart';
import 'student_attendance_report_screen.dart';
import 'student_profile_screen.dart';
import 'help_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupLogging();

  // Initialize the camera list
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

void _setupLogging() {
  Logger.root.level = Level.ALL; // Set to Level.ALL for detailed logs
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        // Add other providers if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AttendMe',
        theme: ThemeData(
          primarySwatch: Colors.brown, // Adjusted to your theme color
        ),
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1200, name: DESKTOP),
            const Breakpoint(start: 1201, end: double.infinity, name: '4K'),
          ],
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingScreen(),
          '/choose_option': (context) => const ChooseOptionScreen(),
          '/student_login': (context) => const StudentLoginScreen(),
          '/teacher_login': (context) => const TeacherLoginScreen(),
          '/student_register': (context) => const StudentRegisterScreen(),
          '/teacher_register': (context) => const TeacherRegisterScreen(),
          '/settings_screen': (context) => const SettingsScreen(),
          '/recent_courses_screen': (context) => const RecentCoursesScreen(),
          '/reminder_screen': (context) => const AddReminderScreen(),
          '/student_home_screen': (context) => const StudentHomeScreen(),
          '/leave_note_screen': (context) => const LeaveNoteScreen(),
          '/events_screen': (context) => const EventsScreen(),
          '/student_attendance_report_screen': (context) =>
              const StudentAttendanceReportScreen(),
          '/student_profile_screen': (context) => const StudentProfileScreen(),
          '/help_screen': (context) => const HelpScreen(),
          '/attendance': (context) =>
              AttendancePage(cameras: cameras), // Attendance page route
        },
      ),
    );
  }
}
