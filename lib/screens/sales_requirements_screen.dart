import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'sales_device_selection_screen.dart';
import 'sales_review_requirements_screen.dart';

class RequirementsScreen extends StatefulWidget {
  final String customerId;

  const RequirementsScreen({
    Key? key,
    required this.customerId,
  }) : super(key: key);

  @override
  _RequirementsScreenState createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  final _apiService = ApiService();
  String? selectedInstitution;
  String? selectedInstitutionId;
  List<String> selectedRooms = [];
  Map<String, List<Map<String, dynamic>>> roomDevices = {};
  bool _isLoading = false;
  List<dynamic> institutions = [];
  List<dynamic> availableRooms = [];

  @override
  void initState() {
    super.initState();
    //_loadExistingRequirements();
    fetchInstitutions();
  }

  Future<void> fetchInstitutions() async {
    try {
      setState(() => _isLoading = true);
      final data = await ApiService().salesgetInstitutions();
      setState(() {
        institutions = data.cast<Map<String, dynamic>>();

      });
    } catch (e) {
      print('Error fetching institutions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading institutions: ${e.toString()}')),);
    } finally{
      setState(()  => _isLoading = false);
    }
  }

  Future<void> _loadRooms(String institutionId) async {
    try {
      setState(() => _isLoading = true);
      final roomsList = await _apiService.salesgetRooms(institutionId);
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

  // Future<void> _loadExistingRequirements() async {
  //   try {
  //     setState(() => _isLoading = true);
  //     final requirements =
  //         await _apiService.getCustomerRequirements(widget.customerId);
  //
  //     if (requirements != null) {
  //       setState(() {
  //         selectedInstitution = requirements['institution'];
  //         selectedInstitutionId = requirements['institutionId'];
  //         selectedRooms = List<String>.from(requirements['rooms'] ?? []);
  //         roomDevices = Map<String, List<Map<String, dynamic>>>.from(
  //             requirements['roomDevices'] ?? {});
  //       });
  //       if (selectedInstitutionId != null) {
  //         await _loadRooms(selectedInstitutionId!);
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error loading requirements: ${e.toString()}')),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _saveRequirements() async {
    try {
      setState(() => _isLoading = true);

      final requirements = {
        'institution': selectedInstitution,
        'institutionId': selectedInstitutionId,
        'rooms': selectedRooms,
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

  void _selectInstitution() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Institution"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: institutions.map((institution) {
              return ListTile(
                title: Text(institution['name'].toString()),
                onTap: () {
                  Navigator.pop(context, institution);
                },
              );
            }).toList(),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        selectedInstitution = result['name'].toString();
        selectedInstitutionId = result['id'].toString();
        selectedRooms.clear();
        roomDevices.clear();
      });
      await _loadRooms(result['id'].toString());
      await _saveRequirements();
    }
  }

  void _addRoom(String room) {
    setState(() {
      if (!selectedRooms.contains(room)) {
        selectedRooms.add(room);
        roomDevices[room] = [];
      }
    });
    _saveRequirements();
  }

  void _removeRoom(String room) {
    setState(() {
      selectedRooms.remove(room);
      roomDevices.remove(room);
    });
    _saveRequirements();
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
      await _saveRequirements();
    }
  }

  void _reviewRequirements() {
    if (selectedInstitution == null || selectedRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select an institution and at least one room')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewRequirementsScreen(
          customerId: widget.customerId,
          institution: selectedInstitution!,
          roomDevices: roomDevices,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text('Requirements Collection',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Institution Selection
                  GestureDetector(
                    onTap: _selectInstitution,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedInstitution ?? 'Select Institution',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Room Selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selected Rooms',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: selectedInstitutionId == null
                            ? null
                            : () {
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
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF075056),
                        ),
                        child: const Text('Add Room',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Room List
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedRooms.length,
                      itemBuilder: (context, index) {
                        String room = selectedRooms[index];
                        List<Map<String, dynamic>> devices =
                            roomDevices[room] ?? [];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ExpansionTile(
                            title: Text(room),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeRoom(room),
                            ),
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _navigateToDeviceSelection(room),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFBA52E),
                                ),
                                child: const Text('Add Device',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              ...devices.map((device) {
                                return ListTile(
                                  title: Text(
                                    '${device["device"]} (x${device["quantity"]}) - ${device["location"]}',
                                  ),
                                  subtitle:
                                      Text("Price: ₹${device["price"]} each"),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Review Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _reviewRequirements,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5B04),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                      ),
                      child: const Text('Review Requirements',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
