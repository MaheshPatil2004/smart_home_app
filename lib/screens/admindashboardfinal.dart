import 'package:flutter/material.dart';
import 'admin_installation_details.dart';
import 'admin_institution_selection_screen.dart'; // Import Institution Selection Screen
import 'admin_category_selection_screen.dart';

class NewAdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Institution Selection before adding rooms
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminInstitutionSelectionScreen(),
                  ),
                );
              },
              child: const Text("Add Rooms"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ✅ Navigate to CategorySelectionScreen WITHOUT `roomId`
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategorySelectionScreen(
                      institutionId: "1", // Example Institution ID (You may update it dynamically)
                    ),
                  ),
                );
              },
              child: const Text("Add Devices"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to View Reports screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminInstallationDetailsScreen(
                      customerName: "John Doe",
                      roomName: "Living Room",
                      device: {
                        "device": "Smart Light",
                        "sku": "SL001",
                        "price": 50.0,
                        "newName": "Living Room Light",
                      },
                    ),
                  ),
                );
              },
              child: const Text("View Reports"),
            ),
          ],
        ),
      ),
    );
  }
}
