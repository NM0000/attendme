import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'landing_screen.dart';
import 'choose_option_screen.dart';
import 'student_login.dart';
import 'teacher_login.dart';
import 'student_register_screen.dart';
import 'teacher_register_screen.dart';

void main() {
  _setupLogging();
  runApp(const MyApp());
}

void _setupLogging() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    // This is just a simple logging setup. You can customize it as per your needs.
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AttendMe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/choose_option': (context) => const ChooseOptionScreen(),
        '/student_login': (context) => const StudentLoginScreen(),
        '/teacher_login': (context) => const TeacherLoginScreen(),
        '/student_register': (context) => const StudentRegisterScreen(),
        '/teacher_register': (context) => const TeacherRegisterScreen(),
      },
    );
  }
}
