import 'package:flutter/material.dart';

class GenerateReportScreen extends StatelessWidget {
  final String customerId;
  final String quotationId;
  final Map<String, List<Map<String, dynamic>>> roomDevices;
  final double totalCost;

  const GenerateReportScreen({
    Key? key,
    required this.customerId,
    required this.quotationId,
    required this.roomDevices,
    required this.totalCost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text('Quotation Report', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2A3950),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer ID: $customerId',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Quotation ID: $quotationId',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: roomDevices.length,
                itemBuilder: (context, index) {
                  String room = roomDevices.keys.elementAt(index);
                  List<Map<String, dynamic>> devices = roomDevices[room] ?? [];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text(room, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      children: [
                        ...devices.map((device) {
                          double deviceTotal = (device["price"] ?? 0) * (device["quantity"] as int);
                          return ListTile(
                            title: Text(
                              '${device["device"]} (x${device["quantity"]})',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text('Location: ${device["location"]}\nPrice: ₹${device["price"]} each'),
                            trailing: Text(
                              '₹${deviceTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            isThreeLine: true,
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
              child: Text(
                'Total Cost: ₹${totalCost.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
