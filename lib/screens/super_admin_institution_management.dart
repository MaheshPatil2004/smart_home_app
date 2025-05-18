import 'package:flutter/material.dart';
import '../services/api_service.dart';// Import your ApiService

class SuperAdminInstitutionManagement extends StatefulWidget {
  @override
  _SuperAdminInstitutionManagementState createState() =>
      _SuperAdminInstitutionManagementState();
}

class _SuperAdminInstitutionManagementState
    extends State<SuperAdminInstitutionManagement> {
  final ApiService apiService = ApiService();
  List<dynamic> institutions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInstitutions();
  }

  // Fetch institutions from API
  Future<void> _fetchInstitutions() async {
    try {
      final data = await apiService.getInstitutions3();
      setState(() {
        institutions = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Show add institution dialog
  void _showAddInstitutionDialog() {
    final TextEditingController _institutionController =
    TextEditingController();
    String role = "superadmin";
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Institution"),
          content: TextField(
            controller: _institutionController,
            decoration: const InputDecoration(
              labelText: "Institution Name",
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newInstitution = _institutionController.text.trim();
                if (newInstitution.isNotEmpty) {
                  try {
                    await apiService.addInstitution(newInstitution);
                    Navigator.pop(context);
                    _fetchInstitutions(); // Refresh list
                  } catch (e) {

                    print("Error adding institution: $e");
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075056),
              ),
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Confirm and delete institution
  void _confirmRemoveInstitution(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to remove ${institutions[index]['name']}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.deleteInstitution(institutions[index]['id'].toString());
                  Navigator.pop(context);
                  _fetchInstitutions(); // Refresh list
                } catch (e) {
                  print("Error deleting institution: $e");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5B04),
              ),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text("Institution Management",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Institution Button
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton(
                onPressed: _showAddInstitutionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF075056),
                ),
                child: const Text("Add Institution",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            // Show loading indicator
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: institutions.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(institutions[index]['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Color(0xFFFF5B04)),
                        onPressed: () =>
                            _confirmRemoveInstitution(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
