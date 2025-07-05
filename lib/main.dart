import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/login_page.dart';
import 'screens/teacher_dashboard.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  // Check if it's first launch or setup is complete
  final isFirstLaunch = await StorageService.isFirstLaunch();
  final isSetupComplete = await StorageService.isSetupComplete();

  runApp(
    MyApp(
      cameras: cameras,
      isFirstLaunch: isFirstLaunch,
      isSetupComplete: isSetupComplete,
    ),
  );
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final bool isFirstLaunch;
  final bool isSetupComplete;

  const MyApp({
    super.key,
    required this.cameras,
    required this.isFirstLaunch,
    required this.isSetupComplete,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TSWREIS Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF64B5F6),
          surface: const Color(0xFFFFFFFF),
          error: const Color(0xFFE53935),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: _getHomePage(),
    );
  }

  Widget _getHomePage() {
    if (isFirstLaunch) {
      // First time - show login which leads to tutorial
      return LoginPage(cameras: cameras);
    } else if (isSetupComplete) {
      // Setup complete - go directly to dashboard
      return TeacherDashboard(cameras: cameras, isTeluguLanguage: false);
    } else {
      // Setup incomplete - go to login
      return LoginPage(cameras: cameras);
    }
  }
}
