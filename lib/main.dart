import 'package:flutter/material.dart';
import 'package:nutridev/screens/lander.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutridev/services/scan_history_service.dart';

void main() {
  // Initialize services
  Get.put(ScanHistoryService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'nutridev',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xfff4f2f2),
          titleTextStyle: TextStyle(
            fontFamily: GoogleFonts.lexend().fontFamily,
            fontSize: 21,
            color: Colors.black,
          ),
        ),
        scaffoldBackgroundColor: const Color(0xfff4f2f2),
      ),
      home: const LanderClass(),
    );
  }
}
