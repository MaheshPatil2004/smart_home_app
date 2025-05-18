import 'package:flutter/material.dart';
import 'sales_customer_registration_screen.dart';
import '../services/api_service.dart';

class SalesDashboard extends StatefulWidget {
  @override
  _SalesDashboardState createState() => _SalesDashboardState();
}

class _SalesDashboardState extends State<SalesDashboard> {
  final ApiService apiService = ApiService();
  List<Map<String, String>> customers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  void fetchCustomers() async {
    try {
      List<Map<String, String>> fetchedCustomers = await apiService.fetchCustomers();
      setState(() {
        customers = fetchedCustomers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to fetch customers: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sales Dashboard")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerRegistrationScreen()),
                ).then((_) => fetchCustomers());
              },
              child: Text("Register a Customer"),
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: customers.isEmpty
                ? Center(child: Text("No customers registered yet."))
                : ListView.builder(
              itemCount: customers.length,
              itemBuilder: (context, index) {
                var customer = customers[index];
                return ListTile(
                  title: Text("${customer["first_name"] ?? ""} ${customer["middle_name"] ?? ""} ${customer["last_name"] ?? ""}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${customer["email"] ?? "N/A"}"),
                      Text("Contact: ${customer["telephone"] ?? "N/A"}"),
                      Text("Address: ${customer["address_line1"] ?? "N/A"}, ${customer["address_line2"] ?? "N/A"}, ${customer["city"] ?? "N/A"}, ${customer["state_province"] ?? "N/A"}, ${customer["zip_postal_code"] ?? "N/A"}, ${customer["country"] ?? "N/A"}"),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}