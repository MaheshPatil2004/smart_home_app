import 'package:flutter/material.dart';

class AdminInstallationDetailsScreen extends StatelessWidget {
  final String customerName;
  final String roomName;
  final Map<String, dynamic> device;

  AdminInstallationDetailsScreen({
    required this.customerName,
    required this.roomName,
    required this.device,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: Text("Installation Details", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Customer Name: $customerName",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text("Room: $roomName", style: TextStyle(fontSize: 16)),
            Text(
              "Device: ${device['device'] ?? 'Unknown'} (SKU: ${device['sku'] ?? 'N/A'})",
              style: TextStyle(fontSize: 16),
            ),
            Text("Price: ₹${device['price'] ?? 'N/A'}", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 16),

            Text("New Device Name: ${device['newName'] ?? 'Not Provided'}",
                style: TextStyle(fontSize: 16)),

            const SizedBox(height: 16),

            Text(
              "Installed Image:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300], // Placeholder for image
              child: Center(child: Text("No Image Available")),
            ),
          ],
        ),
      ),
    );
  }
}
