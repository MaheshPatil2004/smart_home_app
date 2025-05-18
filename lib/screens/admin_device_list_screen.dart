import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'admin_device_management_screen.dart'; // Screen for adding a new device

class DeviceListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName; // Display name of the category

  const DeviceListScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  List<Map<String, dynamic>> devices = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  // ✅ Fetch devices from backend API
  Future<void> fetchDevices() async {
    try {
      final List<dynamic> data = await ApiService().getDevices(
          widget.categoryId);

      setState(() {
        devices = data.map((device) {
          return {
            'id': device['id'].toString(),
            'name': device['name'] ?? "Unnamed Device",
            'price': device['price']?.toString() ?? "N/A",
            'sku': device['sku'] ?? "N/A",
            'image_url': device['image_url'] ?? null,
            'category': device['DeviceCategory']?['name'] ?? "Unknown Category",
          };
        }).toList();

        isLoading = false;
      });

      if (devices.isEmpty) {
        debugPrint("⚠️ No devices found in this category.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load devices: ${e.toString()}";
        isLoading = false;
      });
    }
  }


  // ✅ Remove device via API
  Future<void> removeDevice(String deviceId) async {
    try {
      await ApiService().deleteDevice(widget.categoryId, deviceId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Device removed successfully")),
      );

      fetchDevices(); // ✅ Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to remove device: ${e.toString()}")),
      );
    }
  }


  // ✅ Show confirmation dialog before removing a device
  void showRemoveDeviceDialog() {
    if (devices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No devices available to delete!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Device"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: devices.map((device) {
                return ListTile(
                  title: Text(device['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      removeDevice(device['id']);
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: Text("${widget.categoryName} Devices",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
            child: Text(errorMessage!,
                style: const TextStyle(color: Colors.red)))
            : Column(
          children: [
            Expanded(
              child: devices.isEmpty
                  ? const Center(
                child: Text(
                  "⚠️ No devices found in this category!",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              )
                  : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8),
                    child: ListTile(
                      title: Text(
                        devices[index]['name'],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        "Category: ${devices[index]['category']} | Price: ${devices[index]['price']}",
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey),
                      ),
                      leading: devices[index]['image_url'] != null
                          ? Image.network(
                          devices[index]['image_url'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover)
                          : const Icon(Icons.devices,
                          color: Colors.blueGrey),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () =>
                            removeDevice(devices[index]['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add,
                      color: Colors.white),
                  label: const Text("Add Device",
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DeviceManagementScreen(
                              categoryId: widget.categoryId,
                              categoryName:
                              widget.categoryName,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF075056),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete,
                      color: Colors.white),
                  label: const Text("Remove Device",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFFF5B04),
                  ),
                  onPressed: showRemoveDeviceDialog,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
