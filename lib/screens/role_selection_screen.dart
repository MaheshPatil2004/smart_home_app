import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A3950),
        title: const Text('Select Role', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoleButton(
              role: 'Super Admin',
              color: Colors.purple, // Different color for Super Admin
              onPressed: () {
                Navigator.pushNamed(context, '/super_admin_login'); // Navigate to Super Admin Login Screen
              },
            ),
            const SizedBox(height: 16),
            RoleButton(
              role: 'Admin',
              color: const Color(0xFF075056),
              onPressed: () {
                Navigator.pushNamed(context, '/admin_login');
              },
            ),
            const SizedBox(height: 16),
            RoleButton(
              role: 'Sales Representative',
              color: const Color(0xFFFBA52E),
              onPressed: () {
                Navigator.pushNamed(context, '/sales_login');
              },
            ),
            const SizedBox(height: 16),
            RoleButton(
              role: 'Installation Engineer',
              color: const Color(0xFFFF5B04),
              onPressed: () {
                Navigator.pushNamed(context, '/engineer_login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RoleButton extends StatelessWidget {
  final String role;
  final Color color;
  final VoidCallback onPressed;

  RoleButton({required this.role, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        role,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
