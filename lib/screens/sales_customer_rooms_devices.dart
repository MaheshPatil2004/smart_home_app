import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'sales_device_selection_screen.dart';
import 'sales_generate_report.dart';

class UserRoomsDevicesScreen extends StatefulWidget {
  final String userName;
  final String customerId;
  final String institutionId;

  const UserRoomsDevicesScreen({
    Key? key,
    required this.userName,
    required this.customerId,
    required this.institutionId,
  }) : super(key: key);

  @override
  _UserRoomsDevicesScreenState createState() => _UserRoomsDevicesScreenState();
}

class _UserRoomsDevicesScreenState extends State<UserRoomsDevicesScreen> {
  final _apiService = ApiService();
  List<String> rooms = [];
  List<dynamic> availableRooms = [];
  Map<String, List<Map<String, dynamic>>> roomDevices = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadExistingDevices();
  }

  Future<void> _loadRooms() async {
    try {
      setState(() => _isLoading = true);
      final roomsList = await _apiService.getRooms(widget.institutionId);
      setState(() {
        availableRooms = roomsList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rooms: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadExistingDevices() async {
    try {
      setState(() => _isLoading = true);
      final requirements =
          await _apiService.getCustomerRequirements(widget.customerId);

      if (requirements != null) {
        setState(() {
          rooms = List<String>.from(requirements['rooms'] ?? []);
          roomDevices = Map<String, List<Map<String, dynamic>>>.from(
              requirements['roomDevices'] ?? {});
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error loading existing devices: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addRoom(String room) {
    setState(() {
      if (!rooms.contains(room)) {
        rooms.add(room);
        roomDevices[room] = [];
      }
    });
    _saveRequirements();
  }

  void _removeRoom() {
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No rooms to remove!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Room to Remove"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: rooms.map((room) {
              return ListTile(
                title: Text(room),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      rooms.remove(room);
                      roomDevices.remove(room);
                    });
                    Navigator.pop(context);
                    _saveRequirements();
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _removeDevice(String room, String deviceName) {
    setState(() {
      roomDevices[room]
          ?.removeWhere((device) => device["device"] == deviceName);
    });
    _saveRequirements();
  }

  Future<void> _saveRequirements() async {
    try {
      setState(() => _isLoading = true);

      final requirements = {
        'rooms': rooms,
        'roomDevices': roomDevices,
      };

      await _apiService.saveRequirements(widget.customerId, requirements);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requirements saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving requirements: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDeviceSelection(String roomName) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceSelectionScreen(roomName: roomName),
      ),
    );

    if (result != null && result is List<Map<String, dynamic>>) {
      setState(() {
        roomDevices[roomName] = result;
      });
      _saveRequirements();
    }
  }

  double _calculateTotalCost() {
    double total = 0.0;
    roomDevices.forEach((room, devices) {
      for (var device in devices) {
        total += (device["price"] ?? 0) * (device["quantity"] as int);
      }
    });
    return total;
  }

  void _generateReport() async {
    try {
      final quotation = await _apiService.generateQuotation(widget.customerId, {
        'roomDevices': roomDevices,
        'totalCost': _calculateTotalCost(),
      });

      Navigator.pushNamed(
        context,
        '/generate_report',
        arguments: {
          'customerId': widget.customerId,
          'quotationId': quotation['id'],
          'roomDevices': roomDevices,
          'totalCost': _calculateTotalCost(),
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating quotation: ${e.toString()}')),
      );
    }
  }

  void _showRoomSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Room"),
          content: SingleChildScrollView(
            child: Column(
              children: availableRooms.map((room) {
                return ListTile(
                  title: Text(room['name']),
                  onTap: () {
                    _addRoom(room['name']);
                    Navigator.pop(context);
                  },
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
        title: Text('${widget.userName} - Rooms',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _showRoomSelectionDialog,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF075056)),
                        child: const Text("Add Room",
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: _removeRoom,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text("Remove Room",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        String room = rooms[index];
                        List<Map<String, dynamic>> devices =
                            roomDevices[room] ?? [];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ExpansionTile(
                            title: Text(room),
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _navigateToDeviceSelection(room),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFBA52E)),
                                child: const Text("Add Device",
                                    style: TextStyle(color: Colors.white)),
                              ),
                              ...devices.map((device) {
                                return ListTile(
                                  title: Text(
                                    '${device["device"]} (x${device["quantity"]}) - ${device["location"]}',
                                  ),
                                  subtitle:
                                      Text("Price: ₹${device["price"]} each"),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () =>
                                        _removeDevice(room, device["device"]),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _generateReport,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text("Generate Report",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
