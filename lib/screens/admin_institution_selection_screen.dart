import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_room_first screen.dart'; // Updated import for Admin Dashboard

class AdminInstitutionSelectionScreen extends StatefulWidget {
  @override
  _AdminInstitutionSelectionScreenState createState() =>
      _AdminInstitutionSelectionScreenState();
}

class _AdminInstitutionSelectionScreenState
    extends State<AdminInstitutionSelectionScreen> {
  List<Map<String, dynamic>> institutions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchInstitutions();
  }

  Future<void> fetchInstitutions() async {
    try {
      final data = await ApiService().getInstitutions();
      setState(() {
        institutions = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching institutions: $e');
      setState(() {
        errorMessage = "Failed to load institutions";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text("Select Institution", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
            : ListView.builder(
          itemCount: institutions.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(institutions[index]['name']),
                onTap: () {
                  // Navigate to Room Management with Institution ID
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminDashboardScreen(
                        institutionId: institutions[index]['id'].toString(),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
