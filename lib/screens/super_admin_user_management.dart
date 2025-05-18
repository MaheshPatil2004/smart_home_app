import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SuperAdminUserManagement extends StatefulWidget {
  @override
  _SuperAdminUserManagementState createState() =>
      _SuperAdminUserManagementState();
}

class _SuperAdminUserManagementState extends State<SuperAdminUserManagement> {
  final ApiService apiService = ApiService();
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future<void> getUsers() async {
    try {
      final data = await apiService.getUsers();
      setState(() {
        users = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  void _sendInvite(String email, String role) async {
    try {
      await apiService.sendInvitation(email, role);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invitation sent to $email")),
      );
    } catch (e) {
      print("Error sending invite: $e");
    }
  }

  void _showAddUserDialog() {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    String role = "Admin";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: role,
                onChanged: (value) {
                  if (value != null) {
                    role = value;
                  }
                },
                items: ["Admin", "Sales Representative", "Installation Engineer"]
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                decoration: const InputDecoration(labelText: "Select Role"),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Enter Name"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Enter Email"),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                String name = _nameController.text.trim();
                String email = _emailController.text.trim();
                if (name.isNotEmpty && email.isNotEmpty) {
                  try {
                    await apiService.addUser(role, name, email);
                    Navigator.pop(context);
                    getUsers();
                  } catch (e) {
                    print("Error adding user: $e");
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  // ... inside your _SuperAdminUserManagementState class ...

  void _confirmRemoveUser(String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this user?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.deleteUser(id);
                  Navigator.pop(context);
                  getUsers();
                } catch (e) {
                  print("Error deleting user: $e");
                }
              },
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
      appBar: AppBar(title: const Text("User Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddUserDialog,
              child: const Text("Add User"),
            ),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['role']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.email, color: Colors.blue),
                            onPressed: () => _sendInvite(user['email'], user['role']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmRemoveUser(user['id'].toString()),
                          ),
                        ],
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
