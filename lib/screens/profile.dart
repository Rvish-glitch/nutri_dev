import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:nutridev/screens/account_preferencespage.dart';
import 'package:nutridev/screens/settings_page.dart';

class Profile extends StatelessWidget {
  Profile({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest User',
                    style: GoogleFonts.lexend(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Using app without account',
                    style: GoogleFonts.lexend(fontSize: 16),
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(thickness: 2.0),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
            // Account preferences section
            ListTile(
              title:
                  Text('My Account Preferences', style: GoogleFonts.lexend()),
              onTap: () {
                Get.to(() => AccountPreferencesPage());
              },
            ),
            const Divider(),
            // Settings section
            ListTile(
              title: Text('Settings', style: GoogleFonts.lexend()),
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
