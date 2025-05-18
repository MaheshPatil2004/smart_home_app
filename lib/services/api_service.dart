import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ Import Secure Storage
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.80.83:3001/api';
  static const String _tokenKey = 'auth_token';

  // Singleton Instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal();

  // ✅ Get Stored Token
  Future<String?> get authToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // ✅ Save Token


  // ✅ Clear Token (For Logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ✅ Get Headers with Authentication
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (requiresAuth) {
      final token = await authToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }else {
        // Handle the case where the token is null.
        print("Warning: Authentication token is null.");
        // You might want to throw an exception here, or return the headers without authorization, or handle it in another way that fits your application's logic.
        // Example of throwing an exception:
        // throw Exception("Authentication token is missing.");
      }
    }
    return headers;
  }

  // 🔹 ✅ **AUTHENTICATION APIs** 🔹

  /// ✅ Login User
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  /// ✅ Login API
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('token')) {
          await saveToken(data['token']); // ✅ Save token after login
        }
        return data;
      } else {
        throw Exception(data['message'] ?? "Login failed");
      }
    } catch (e) {
      throw Exception("Error logging in: ${e.toString()}");
    }
  }
  Future<void> logout() async {
    await clearToken();
  }

  /// ✅ Forgot Password API
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? "Failed to send reset link");
      }
    } catch (e) {
      throw Exception("Error sending reset link: ${e.toString()}");
    }
  }

  /// ✅ Register API
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return data;
      } else {
        throw Exception(data['message'] ?? "Registration failed");
      }
    } catch (e) {
      throw Exception("Error registering: ${e.toString()}");
    }
  }

  /// ✅ Save Token after Login
  Future<void> saveToken(String token) async {
    await _storage.write(key: "auth_token", value: token);
  }

  /// ✅ Retrieve Token for API authentication
  Future<String?> getToken() async {
    return await _storage.read(key: "auth_token");
  }

  /// ✅ Delete Token on Logout
  Future<void> deleteToken() async {
    await _storage.delete(key: "auth_token");
  }


  /// ✅ Logout User
  // 🔹 ✅ **INSTITUTION APIs** 🔹

  /// ✅ Fetch List of Institutions
  Future<List<dynamic>> getInstitutions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/institutions'),
        headers: await _getHeaders(),
      );

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // ✅ Extract the 'data' field
        if (responseData.containsKey('data') && responseData['data'] is List) {
          print("✅ Extracted Institutions: ${responseData['data']}");
          return responseData['data'];
        } else {
          throw Exception(
              "⚠️ Unexpected response format: Missing 'data' field");
        }
      } else {
        throw Exception(
            "❌ API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception: ${e.toString()}");
      throw Exception('Error fetching institutions: ${e.toString()}');
    }
  }

  Future<List<dynamic>> getInstitutions3() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/superadmin/institutions'),
        headers: await _getHeaders(),
      );

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // ✅ Extract the 'data' field
        if (responseData.containsKey('data') && responseData['data'] is List) {
          print("✅ Extracted Institutions: ${responseData['data']}");
          return responseData['data'];
        } else {
          throw Exception(
              "⚠️ Unexpected response format: Missing 'data' field");
        }
      } else {
        throw Exception(
            "❌ API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception: ${e.toString()}");
      throw Exception('Error fetching institutions: ${e.toString()}');
    }
  }
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/superadmin/users'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData['data'] ?? [];
      } else {
        throw Exception("API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }

  Future<void> addUser(String role, String name, String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/superadmin/users'),
        headers: await _getHeaders(),
        body: jsonEncode({"role": role, "name": name, "email": email}),
      );

      if (response.statusCode != 201) {
        throw Exception("Failed to add user: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error adding user: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/superadmin/users/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete user: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  Future<void> sendInvitation(String email, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl/superadmin/invite"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "role": role}),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to send invitation");
    }
  }

  Future<void> addInstitution(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/superadmin/institutions'),
        headers: await _getHeaders(),
        body: jsonEncode({"name": name}),
      );

      if (response.statusCode == 403) {
        throw Exception("Admin access required");
      } else if (response.statusCode != 201) {
        throw Exception("Failed to add institution: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error adding institution: $e');
    }
  }

  // Delete Institution
  Future<void> deleteInstitution(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/superadmin/institutions/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete institution: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error deleting institution: $e');
    }
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, List<Map<String, String>>>> fetchUsers() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }

      final response = await http.get(
        Uri.parse("$baseUrl/superadmin/users"),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch users: ${response.body}");
      }

      Map<String, dynamic> responseData = jsonDecode(response.body);
      List<dynamic>? data = responseData['data']; // Corrected line

      if (data == null) {
        print("Warning: 'users' key is null or missing in the response.");
        return {
          "Admins": [],
          "Sales Representatives": [],
          "Installation Engineers": []
        };
      }

      Map<String, List<Map<String, String>>> categorizedUsers = {
        "Admins": [],
        "Sales Representatives": [],
        "Installation Engineers": []
      };

      for (var user in data) {
        String role = user["role"];
        Map<String, String> userDetails = {
          "Name": user["name"],
          "Role": user["role"],
          "Contact": user["contact"] ?? "N/A",
          "Email": user["email"],
          "Address": user["address"] ?? "N/A"
        };

        if (role == "Admin") {
          categorizedUsers["Admins"]!.add(userDetails);
        } else if (role == "Sales Representative") {
          categorizedUsers["Sales Representatives"]!.add(userDetails);
        } else if (role == "engineer") {
          categorizedUsers["Installation Engineers"]!.add(userDetails);
        }
      }

      return categorizedUsers;
    } catch (e) {
      throw Exception("Error fetching users: $e");
    }
  }


  // 🔹 ✅ **ROOM APIs** 🔹

  /// ✅ Fetch Rooms in an Institution
  Future<List<dynamic>> getRooms(String institutionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/institutions/$institutionId/rooms'),
        headers: await _getHeaders(),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          print("✅ Rooms List: ${data['data']}");
          return data['data']; // ✅ Extract rooms correctly
        } else {
          print("❌ Unexpected response format");
          throw Exception("Unexpected response format from server.");
        }
      } else {
        print("❌ API Error: ${response.body}");
        throw Exception("Failed to fetch rooms: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: ${e.toString()}");
      throw Exception("Error fetching rooms: ${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> addRoom(
      String institutionId, String roomName) async {
    try {
      // ✅ Debugging Logs
      print(
          "🔍 Sending Request - Institution ID: $institutionId, Room Name: $roomName");

      final response = await http.post(
        Uri.parse('$baseUrl/admin/institutions/$institutionId/rooms'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'roomName':
              roomName, // 🔹 Fixed key (Backend expects 'roomName', not 'name')
          'institutionId':
              institutionId, // 🔹 Ensuring institution ID is passed
        }),
      );

      final data = jsonDecode(response.body);

      // ✅ Debugging Logs
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return data; // ✅ Success: API should return new room data
      } else {
        throw Exception("Failed to add room: ${data['message']}");
      }
    } catch (e) {
      print("❌ Error adding room: ${e.toString()}");
      throw Exception('Error adding room: ${e.toString()}');
    }
  }

  /// ✅ Delete Room
  Future<void> deleteRoom(String institutionId, String roomId) async {

    try {

      final response = await http.delete(

        Uri.parse('$baseUrl/admin/institutions/$institutionId/rooms/$roomId'),

        headers: await _getHeaders(),

      );



      _handleResponse(response);

    } catch (e) {

      throw Exception('Error removing room: ${e.toString()}');

    }

  }

  // 🔹 ✅ **CATEGORY APIs** 🔹

  /// ✅ Fetch Device Categories
  /// ✅ Fetch Device Categories (Global)
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/admin/device-categories'), // ✅ Fetch institution-wise
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body); // ✅ Decode response body
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']; // ✅ Return category list
      } else {
        throw Exception("Failed to fetch categories: ${data['message']}");
      }
    } catch (e) {
      throw Exception('Error fetching categories: ${e.toString()}');
    }
  }

  /// ✅ Add Category (Global)
  Future<Map<String, dynamic>> addCategory(String categoryName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/device-categories'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': categoryName}),
      );

      final data = jsonDecode(response.body); // ✅ Decode response
      if (response.statusCode == 201) {
        return data['data']; // ✅ Return created category with ID
      } else {
        throw Exception("Failed to add category: ${data['message']}");
      }
    } catch (e) {
      throw Exception('Error adding category: ${e.toString()}');
    }
  }

  /// ✅ Delete Category (Global)
  Future<void> deleteCategory(String categoryId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/device-categories/$categoryId'),
        headers: await _getHeaders(),
      );

      // ✅ If API returns 204 (No Content), it means deletion was successful
      if (response.statusCode == 204) {
        return; // ✅ Successfully deleted
      }

      // ✅ Otherwise, check for errors in response
      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception("Failed to remove category: ${data['message']}");
      }
    } catch (e) {
      throw Exception('Error removing category: ${e.toString()}');
    }
  }

  // 🔹 ✅ **DEVICE APIs** 🔹

  /// ✅ Fetch Devices in a Category
  /// ✅ Fetch Devices in a Category (Now only requires categoryId)
  /// ✅ Fetch Devices in a Category (Now only requires categoryId)
  Future<List<dynamic>> getDevices(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/device-categories/$categoryId/devices'),
        headers: await _getHeaders(),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          // ✅ FIXED: Now checking "data"
          print("✅ Devices List: ${data['data']}");
          return data['data']; // ✅ Extract devices from "data" key
        } else {
          print("❌ Unexpected response format");
          throw Exception("Unexpected response format from server.");
        }
      } else {
        print("❌ API Error: ${response.body}");
        throw Exception("Failed to fetch devices: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: ${e.toString()}");
      throw Exception("Error fetching devices: ${e.toString()}");
    }
  }

  /// ✅ Remove Device (Now only requires categoryId & deviceId)
  Future<void> deleteDevice(String categoryId, String deviceId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/admin/device-categories/$categoryId/devices/$deviceId'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Error removing device: ${e.toString()}');
    }
  }

  /// ✅ Add Device (Supports Image & File Upload)
  Future<Map<String, dynamic>> addDevice({
    required String categoryId,
    required String name,
    required String price,
    required String sku,
    File? image,
  }) async {
    try {
      // ✅ Debugging Logs
      print("🔍 Sending Request - Category ID: $categoryId, Name: $name, Price: $price, SKU: $sku");

      final uri = Uri.parse('$baseUrl/admin/device-categories/$categoryId/devices');

      // ✅ Prepare the request body
      Map<String, dynamic> requestBody = {
        'name': name,
        'price': price,
        'sku': sku,
      };

      // ✅ Send the request with JSON body
      final response = await http.post(
        uri,
        headers: await _getHeaders(), // Ensure this includes 'Content-Type: application/json'
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      // ✅ Debugging Logs
      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        // ✅ Handle image upload separately if needed
        if (image != null) {
          //  Important: Image upload logic
          //  You might need to:
          //    1. Upload the image to a different endpoint.
          //    2. Get a URL or ID from the upload.
          //    3. Update the device data with the image URL/ID.
          //
          //  If your API expects the image in the same request, you'll need MultipartRequest
          //  Example (Placeholder - Adapt to your API):
           //final imageUploadResult = await _uploadImage(image);
          // data['image_url'] = imageUploadResult; // Or however your API returns it
        }

        return data; // ✅ Return the device data (like addRoom)
      } else {
        throw Exception("Failed to add device: ${data['message']}"); // ✅ Consistent error handling
      }
    } catch (e) {
      print("❌ Error adding device: ${e.toString()}");
      throw Exception('Error adding device: ${e.toString()}');
    }
  }



  // 🔹 ✅ **HELPER METHODS** 🔹

  /// ✅ Handle API Response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('API Error: ${response.statusCode} - ${response.body}');
    }
  }

  // 🔹 ✅ **SALES REPRESENTATIVE APIs** 🔹

  /// ✅ Create Customer Registration
  ///
  static Future<bool> registerCustomer(Map<String, String> customerData) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/sales/customers/register"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(customerData),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        return true; // Successfully registered
      } else {
        throw Exception("Failed to register customer: ${response.body}");
      }
    } catch (e) {
      print("Error registering customer: $e");
      return false; // Return false if registration fails
    }
  }

  /// ✅ Fetch All Customers
  Future<List<Map<String, String>>> fetchCustomers() async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }
      final response = await http.get(
        Uri.parse("$baseUrl/sales/customers"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        } // Ensure headers are correctly fetched
      );

      if (response.statusCode != 200) {
        print("Fetch customers failed, status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception("Failed to fetch customers: ${response.body}");
      }

      final dynamic decodedResponse = jsonDecode(response.body);

      if (decodedResponse is List) {
        // API returned a list of customers
        List<dynamic> data = decodedResponse;
        return data.map((customer) {
          Map<String, String> stringMap = {};
          customer.forEach((key, value) {
            stringMap[key] = value?.toString() ?? "N/A";
          });
          return stringMap;
        }).toList();
      } else if (decodedResponse is Map && decodedResponse.containsKey("customers")) {
        // API returned a map containing a "customers" list
        List<dynamic> data = decodedResponse["customers"];
        return data.map((customer) {
          Map<String, String> stringMap = {};
          customer.forEach((key, value) {
            stringMap[key] = value?.toString() ?? "N/A";
          });
          return stringMap;
        }).toList();
      } else if (decodedResponse is Map && decodedResponse.containsKey("error")){
        //API returned an error object.
        throw Exception ("API Error: ${decodedResponse["error"]}");
      } else {
        // Unexpected response format
        throw Exception("Unexpected API response format");
      }
    } catch (e) {
      print("Error fetching customers: $e");
      throw Exception("Error fetching customers: $e");
    }
  }
  Future<Map<String, dynamic>?> createCustomer(Map<String, dynamic> customerData) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }

      final response = await http.post(
        Uri.parse("$baseUrl/sales/customers/register"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(customerData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register customer: ${response.body}');
      }
    } catch (error) {
      throw Exception('Error creating customer: $error');
    }
  }

  Future<List<dynamic>> salesgetInstitutions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/institutions'),
        headers: await _getHeaders(),
      );

      print("🔹 Response Code: ${response.statusCode}");
      print("🔹 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // ✅ Extract the 'data' field
        if (responseData.containsKey('data') && responseData['data'] is List) {
          print("✅ Extracted Institutions: ${responseData['data']}");
          return responseData['data'];
        } else {
          throw Exception(
              "⚠️ Unexpected response format: Missing 'data' field");
        }
      } else {
        throw Exception(
            "❌ API Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("🔥 Exception: ${e.toString()}");
      throw Exception('Error fetching institutions: ${e.toString()}');
    }
  }

  Future<List<dynamic>> salesgetRooms(String institutionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/institutions/$institutionId/rooms'),
        headers: await _getHeaders(),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          print("✅ Rooms List: ${data['data']}");
          return data['data']; // ✅ Extract rooms correctly
        } else {
          print("❌ Unexpected response format");
          throw Exception("Unexpected response format from server.");
        }
      } else {
        print("❌ API Error: ${response.body}");
        throw Exception("Failed to fetch rooms: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: ${e.toString()}");
      throw Exception("Error fetching rooms: ${e.toString()}");
    }
  }

  Future<List<dynamic>> salesgetCategories() async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/sales/device-categories'), // ✅ Fetch institution-wise
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body); // ✅ Decode response body
      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']; // ✅ Return category list
      } else {
        throw Exception("Failed to fetch categories: ${data['message']}");
      }
    } catch (e) {
      throw Exception('Error fetching categories: ${e.toString()}');
    }
  }

  Future<List<dynamic>> salesgetDevices(String categoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/device-categories/$categoryId/devices'),
        headers: await _getHeaders(),
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('data')) {
          // ✅ FIXED: Now checking "data"
          print("✅ Devices List: ${data['data']}");
          return data['data']; // ✅ Extract devices from "data" key
        } else {
          print("❌ Unexpected response format");
          throw Exception("Unexpected response format from server.");
        }
      } else {
        print("❌ API Error: ${response.body}");
        throw Exception("Failed to fetch devices: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ API Exception: ${e.toString()}");
      throw Exception("Error fetching devices: ${e.toString()}");
    }
  }
  Future<void> addDevicesToRoom(
      String roomName,
      int deviceId,
      List<Map<String, dynamic>> devices,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sales/rooms/$roomName/devices/$deviceId'), // <-- deviceId in URL now
        headers: await _getHeaders(),
        body: jsonEncode({
          'devices': devices,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to add devices: ${response.statusCode}, ${response.body}');
      }
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != true) {
        throw Exception('Failed to add devices: ${responseData['message']}');
      }
    } catch (e) {
      throw Exception('Error adding devices to room: ${e.toString()}');
    }
  }





  /// ✅ Save Customer Requirements
  Future<Map<String, dynamic>> saveRequirements(
      String customerId, Map<String, dynamic> requirements) async {
    try {

      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }
      final response = await http.post(
        Uri.parse('$baseUrl/sales/customers/registercustomer/assign-Institution'),
        headers: await _getHeaders(),
        body: jsonEncode(requirements),
      );

      if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception("Failed to save requirements: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error saving requirements: ${e.toString()}');
    }
  }

  /// ✅ Generate Quotation
  Future<Map<String, dynamic>> generateQuotation(
      String customerId, Map<String, dynamic> quotationData) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }
      final response = await http.post(
        Uri.parse('$baseUrl/sales/customers/$customerId/quotations'),
        headers: await _getHeaders(),
        body: jsonEncode(quotationData),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception("Failed to generate quotation: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error generating quotation: ${e.toString()}');
    }
  }

  /// ✅ Send Quotation Email
  Future<void> sendQuotationEmail(String customerId, String quotationId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }
      final response = await http.post(
        Uri.parse(
            '$baseUrl/sales/customers/$customerId/quotations/$quotationId/send'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to send quotation email: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error sending quotation email: ${e.toString()}');
    }
  }

  /// ✅ Get Customer Requirements
  Future<Map<String, dynamic>> getCustomerRequirements(
      String customerId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }
      final response = await http.get(
        Uri.parse('$baseUrl/sales/customers/$customerId/requirements'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
      } else {
        throw Exception("Failed to get requirements: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error getting requirements: ${e.toString()}');
    }
  }

  /// ✅ Get Customer Quotations
  Future<List<dynamic>> getCustomerQuotations(String customerId) async {
    try {
      final authToken = await _getToken();
      if (authToken == null) {
        throw Exception("No authentication token found.");
      }
      final response = await http.get(
        Uri.parse('$baseUrl/sales/customers/$customerId/quotations'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'];
    } else {
        throw Exception("Failed to get quotations: ${response.body}");
      }
    } catch (e) {
      throw Exception('Error getting quotations: ${e.toString()}');
    }
  }
}

