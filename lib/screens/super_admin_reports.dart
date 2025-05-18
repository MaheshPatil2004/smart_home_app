import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import API service

class SuperAdminReports extends StatefulWidget {
  @override
  _SuperAdminReportsState createState() => _SuperAdminReportsState();
}

class _SuperAdminReportsState extends State<SuperAdminReports> {
  Map<String, List<Map<String, String>>> categorizedUsers = {
    "Admins": [],
    "Sales Representatives": [],
    "Installation Engineers": []
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final users = await ApiService.fetchUsers();
      setState(() {
        categorizedUsers = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text("User Reports", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading spinner
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: categorizedUsers.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  children: entry.value.map((user) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(user["Name"] ?? ""),
                        subtitle: Text(
                          "Role: ${user["Role"]}\n"
                              "Contact: ${user["Contact"]}\n"
                              "Email: ${user["Email"]}\n"
                              "Address: ${user["Address"]}", // Display address
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
