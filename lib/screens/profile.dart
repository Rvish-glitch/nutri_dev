import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nutridev/screens/account_preferencespage.dart';
import 'package:nutridev/screens/settings_page.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    // Responsive dimensions
    final horizontalPadding = isMobile
        ? 12.0
        : isTablet
            ? 16.0
            : 20.0;
    final fontSize = isMobile
        ? 14.0
        : isTablet
            ? 16.0
            : 18.0;
    final titleFontSize = isMobile
        ? 20.0
        : isTablet
            ? 24.0
            : 28.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.lexend()),
        backgroundColor: const Color(0xfff4f2f2),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section
            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest User',
                    style: GoogleFonts.lexend(
                        fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Using app without account',
                    style: GoogleFonts.lexend(fontSize: fontSize),
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(thickness: 2.0),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            // Account preferences section
            ListTile(
              title: Text('My Account Preferences',
                  style: GoogleFonts.lexend(fontSize: fontSize)),
              onTap: () {
                Get.to(() => AccountPreferencesPage());
              },
            ),
            const Divider(),
            // Settings section
            ListTile(
              title: Text('Settings',
                  style: GoogleFonts.lexend(fontSize: fontSize)),
              onTap: () {
                Get.to(() => SettingsPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
