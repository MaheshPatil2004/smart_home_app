import 'package:flutter/material.dart';
import 'super_admin_user_management.dart';
import 'super_admin_institution_management.dart';
import 'super_admin_reports.dart';

class SuperAdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE), // Background color
      appBar: AppBar(
        title: const Text("Super Admin Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950), // AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Welcome, Super Admin!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // User Management Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuperAdminUserManagement()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075056), // Button color
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), // Increased padding
              ),
              child: const Text("User Management", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20), // Increased spacing

            // Institution Management Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuperAdminInstitutionManagement()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBA52E), // Button color
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Institution Management", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 20),

            // Reports Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SuperAdminReports()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5B04), // Button color
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("View Reports", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}