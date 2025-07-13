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
      title: 'NutriDev',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2C3E50),
          brightness: Brightness.light,
          primary: const Color(0xFF2C3E50),
          secondary: const Color(0xFF34495E),
          tertiary: const Color(0xFFE74C3C),
          background: const Color(0xFFF8F9FA),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onBackground: const Color(0xFF2C3E50),
          onSurface: const Color(0xFF2C3E50),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.withOpacity(0.95),
          foregroundColor: const Color(0xFF2C3E50),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: GoogleFonts.inter().fontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2C3E50),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF2C3E50),
          ),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        cardTheme: CardThemeData(
          color: Colors.white.withOpacity(0.9),
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.black.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2C3E50).withOpacity(0.9),
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color(0xFFE74C3C).withOpacity(0.9),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: const Color(0xFF2C3E50),
            fontFamily: GoogleFonts.inter().fontFamily,
            fontWeight: FontWeight.w700,
          ),
          headlineMedium: TextStyle(
            color: const Color(0xFF2C3E50),
            fontFamily: GoogleFonts.inter().fontFamily,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            color: const Color(0xFF2C3E50),
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
          bodyMedium: TextStyle(
            color: const Color(0xFF2C3E50),
            fontFamily: GoogleFonts.inter().fontFamily,
          ),
        ),
      ),
      home: const LanderClass(),
    );
  }
}
