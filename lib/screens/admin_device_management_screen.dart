import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class DeviceManagementScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const DeviceManagementScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  _DeviceManagementScreenState createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  final TextEditingController _deviceNameController = TextEditingController();
  final TextEditingController _devicePriceController = TextEditingController();
  final TextEditingController _skuController = TextEditingController();

  File? _image;
  bool isLoading = false;

  // 📌 Pick Image Function
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 📌 Save Device Function (Send Data to Backend)
  Future<void> _saveDevice() async {
    String name = _deviceNameController.text.trim();
    String price = _devicePriceController.text.trim();
    String sku = _skuController.text.trim();

    if (name.isEmpty || price.isEmpty || sku.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService().addDevice(
        categoryId: widget.categoryId,
        name: name,
        price: price,
        sku: sku,
        image: _image,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Device added successfully!")),
      );

      // Clear inputs
      _deviceNameController.clear();
      _devicePriceController.clear();
      _skuController.clear();
      setState(() {
        _image = null;
        isLoading = false;
      });

      // Go back and refresh the device list
      Navigator.pop(context, true); // ✅ Pass true to indicate a new device was added
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to add device: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: Text('Manage ${widget.categoryName} Devices', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _deviceNameController,
                decoration: const InputDecoration(labelText: 'Enter Device Name'),
              ),
              const SizedBox(height: 10),

              Center(
                child: Column(
                  children: [
                    _image == null ? const Text("No Image Selected") : Image.file(_image!, height: 100),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF075056)),
                      child: const Text('Upload Device Image', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),

              TextField(
                controller: _devicePriceController,
                decoration: const InputDecoration(labelText: 'Enter Device Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'Enter SKU Code'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _saveDevice, // ✅ Corrected the button to save device
                child: const Text('Save Device'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
