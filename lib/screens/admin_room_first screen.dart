import 'package:flutter/material.dart';
import '../services/api_service.dart';
class AdminDashboardScreen extends StatefulWidget {
  final String institutionId;
  const AdminDashboardScreen({Key? key, required this.institutionId})
      : super(key: key);
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}
class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<Map<String, dynamic>> rooms = []; // ✅ Store room ID & Name
  final TextEditingController _roomController = TextEditingController();
  bool isLoading = true;
  String? errorMessage;
  @override
  void initState() {
    super.initState();
    fetchRooms();
  }
  //✅ Fetch Rooms from API
  Future<void> fetchRooms() async {
    try {
      final List<dynamic> data = await ApiService().getRooms(
          widget.institutionId);
      setState(() {
        rooms =
        List<Map<String, dynamic>>.from(data); // ✅ Store rooms as List of Maps
        isLoading = false;
      });
      if (rooms.isEmpty) {
        debugPrint("⚠️ No rooms found in this institution.");
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load rooms: ${e.toString()}";

        isLoading = false;
      });
    }
  }


// ✅ Add Room

  Future<void> addRoom() async {
    String newRoom = _roomController.text.trim();


    if (newRoom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text("Enter a valid room name!")),

      );

      return;
    }


// ✅ Check if institutionId is valid

    if (widget.institutionId.isEmpty || widget.institutionId == "null") {
      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text("Error: Institution ID is missing!")),

      );

      return;
    }


    try {
      final response = await ApiService().addRoom(
          widget.institutionId, newRoom);


      setState(() {
        rooms.add({'id': response['id'].toString(), 'name': newRoom});

        _roomController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text("Failed to add room: ${e.toString()}")),

      );
    }
  }


// ✅ Remove Room

  Future<void> removeRoom(String roomId) async {
    try {
      await ApiService().deleteRoom(widget.institutionId, roomId);

      setState(() {
        rooms.removeWhere((room) => room['id'] == roomId);
      });

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text("✅ Room removed successfully")),

      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text("❌ Failed to remove room: ${e.toString()}")),

      );
    }
  }


// ✅ Show Remove Room Dialog

  void showRemoveRoomDialog() {
    if (rooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text("⚠️ No rooms available to delete!")),

      );

      return;
    }


    showDialog(

      context: context,

      builder: (context) {
        return AlertDialog(

          title: const Text("Select Room to Remove"),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: rooms.map((room) {
                return ListTile(

                  title: Text(room['name']),

                  trailing: IconButton(

                    icon: const Icon(Icons.delete, color: Colors.red),

                    onPressed: () {
                      removeRoom(room['id'].toString());

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

        title: const Text(
            "Manage Rooms", style: TextStyle(color: Colors.white)),

        backgroundColor: const Color(0xFF2A3950),

      ),

      body: Padding(

        padding: const EdgeInsets.all(16.0),

        child: isLoading

            ? const Center(child: CircularProgressIndicator())

            : errorMessage != null

            ? Center(child: Text(
            errorMessage!, style: const TextStyle(color: Colors.red)))

            : Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            TextField(

              controller: _roomController,

              decoration: const InputDecoration(

                labelText: "Enter Room Name",

                border: OutlineInputBorder(),

                filled: true,

                fillColor: Colors.white,

              ),

            ),

            const SizedBox(height: 16),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [

                ElevatedButton(

                  onPressed: addRoom,

                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075056)),

                  child: const Text(
                      "Add Room", style: TextStyle(color: Colors.white)),

                ),

                ElevatedButton(

                  onPressed: showRemoveRoomDialog, // ✅ Now the button is added

                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5B04)),

                  child: const Text(
                      "Remove Room", style: TextStyle(color: Colors.white)),

                ),

              ],

            ),

            const SizedBox(height: 16),

            Expanded(

              child: ListView.builder(

                itemCount: rooms.length,

                itemBuilder: (context, index) {
                  return Card(

                    color: Colors.white,

                    margin: const EdgeInsets.symmetric(vertical: 8),

                    child: ListTile(

                      title: Text(rooms[index]['name']),

                      trailing: const Icon(Icons.arrow_forward),

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
