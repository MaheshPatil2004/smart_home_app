import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save authentication token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Retrieve authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'user_role', value: role);
  }

  // Retrieve user role
  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'user_role');
  }

  // Delete token and user role (Logout)
  static Future<void> clearSession() async {
    await _storage.deleteAll();
  }
}
