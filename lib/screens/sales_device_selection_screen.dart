import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DeviceSelectionScreen extends StatefulWidget {
  final String roomName;


  const DeviceSelectionScreen({
    Key? key,
    required this.roomName,

  }) : super(key: key);

  @override
  _DeviceSelectionScreenState createState() => _DeviceSelectionScreenState();
}

class _DeviceSelectionScreenState extends State<DeviceSelectionScreen> {
  final _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Map<String, dynamic>> selectedDevices = [];
  List<dynamic> categories = [];
  List<dynamic> devices = [];
  String? selectedCategoryId;
  String? selectedDeviceId;
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoading = true);
      final categoriesList = await _apiService.salesgetCategories();
      setState(() {
        categories = categoriesList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDevices(String categoryId) async {
    try {
      setState(() => _isLoading = true);
      final devicesList = await _apiService.salesgetDevices(categoryId);
      setState(() {
        devices = devicesList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading devices: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addDevice() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedDevice = devices.firstWhere(
          (device) => device['id'] == selectedDeviceId,
      orElse: () => null,
    );

    if (selectedDevice != null) {
      setState(() => _isLoading = true);
      try {
        // Now also sending deviceId
        await _apiService.addDevicesToRoom(
          widget.roomName,
          int.parse(selectedDeviceId!), // deviceId
          [
            {
              'deviceId': int.parse(selectedDeviceId!),
              'quantity': int.parse(_quantityController.text),
              'location': _locationController.text,
            },
          ],
        );

        setState(() {
          selectedDevices.add({
            'deviceId': int.parse(selectedDeviceId!),
            'device': selectedDevice['name'],
            'price': selectedDevice['price'],
            'location': _locationController.text,
            'quantity': int.parse(_quantityController.text),
          });
          _locationController.clear();
          _quantityController.text = '1';
          selectedDeviceId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Device added to room successfully.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding device: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }



  void _removeDevice(int index) {
    setState(() {
      selectedDevices.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: Text('Select Devices - ${widget.roomName}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Devices List
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedDevices.length,
                      itemBuilder: (context, index) {
                        final device = selectedDevices[index];
                        return Card(
                          child: ListTile(
                            title: Text(device['device']),
                            subtitle: Text(
                                'Location: ${device['location']}\nQuantity: ${device['quantity']}\nPrice: ₹${device['price']} each'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeDevice(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Add Device Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Select Category',
                            border: OutlineInputBorder(),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'].toString(),
                              child: Text(category['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoryId = value;
                              selectedDeviceId = null;
                              devices = [];
                            });
                            if (value != null) {
                              _loadDevices(value);
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Device Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedDeviceId,
                          decoration: const InputDecoration(
                            labelText: 'Select Device',
                            border: OutlineInputBorder(),
                          ),
                          items: devices.map((device) {
                            return DropdownMenuItem<String>(
                              value: device['id'].toString(),
                              child: Text(device['name']),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDeviceId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a device';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Location Input
                        TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Installation Location',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter installation location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quantity Input
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Add Device Button
                        ElevatedButton(
                          onPressed: _addDevice,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF075056),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                          ),
                          child: const Text('Add Device',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
