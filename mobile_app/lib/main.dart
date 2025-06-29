import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app/pages/form_page.dart';

import 'package:mobile_app/pages/roadmap_page.dart';
import 'package:mobile_app/pages/course_page.dart';
import 'package:mobile_app/pages/evaluation_page.dart';
import 'package:mobile_app/pages/settings_page.dart';
import 'package:mobile_app/pages/splash_screen.dart';
import 'package:mobile_app/pages/profile_page.dart';
import 'package:mobile_app/pages/success_page.dart';

import 'package:mobile_app/pages/login_page.dart';
import 'package:mobile_app/pages/register_page.dart';

void main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evolos',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      initialRoute: '/login',
      routes: {
        '/roadmap': (context) => RoadmapPage(),
        '/evaluation': (context) =>
            const EvaluationPage(evaluationId: 1, score: 0, moduleId: -1, nextModuleId: -1),
        '/course': (context) => const CoursePage(courseId: 1),
        '/form': (context) => OnboardingForm(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => SettingsPage(),
        '/success': (context) => const SuccessPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
      },
    );
  }
}
