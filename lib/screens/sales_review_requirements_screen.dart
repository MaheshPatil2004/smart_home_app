import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'sales_generate_report.dart';

class ReviewRequirementsScreen extends StatefulWidget {
  final String customerId;
  final String institution;
  final Map<String, List<Map<String, dynamic>>> roomDevices;

  const ReviewRequirementsScreen({
    Key? key,
    required this.customerId,
    required this.institution,
    required this.roomDevices,
  }) : super(key: key);

  @override
  _ReviewRequirementsScreenState createState() =>
      _ReviewRequirementsScreenState();
}

class _ReviewRequirementsScreenState extends State<ReviewRequirementsScreen> {
  final _apiService = ApiService();
  bool _isLoading = false;

  double _calculateTotalCost() {
    double total = 0.0;
    widget.roomDevices.forEach((room, devices) {
      for (var device in devices) {
        total += (device["price"] ?? 0) * (device["quantity"] as int);
      }
    });
    return total;
  }

  Future<void> _generateQuotation() async {
    try {
      setState(() => _isLoading = true);

      final quotationData = {
        'institution': widget.institution,
        'roomDevices': widget.roomDevices,
        'totalCost': _calculateTotalCost(),
      };

      final quotation =
          await _apiService.generateQuotation(widget.customerId, quotationData);

      if (quotation != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GenerateReportScreen(
              customerId: widget.customerId,
              quotationId: quotation['id'],
              roomDevices: widget.roomDevices,
              totalCost: _calculateTotalCost(),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating quotation: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendQuotationEmail() async {
    try {
      setState(() => _isLoading = true);

      // First generate the quotation
      final quotationData = {
        'institution': widget.institution,
        'roomDevices': widget.roomDevices,
        'totalCost': _calculateTotalCost(),
      };

      final quotation =
          await _apiService.generateQuotation(widget.customerId, quotationData);

      if (quotation != null) {
        // Then send the email
        await _apiService.sendQuotationEmail(
            widget.customerId, quotation['id']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quotation email sent successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error sending quotation email: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3DDDE),
      appBar: AppBar(
        title: const Text('Review Requirements',
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
                  Text(
                    'Institution: ${widget.institution}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.roomDevices.length,
                      itemBuilder: (context, index) {
                        String room = widget.roomDevices.keys.elementAt(index);
                        List<Map<String, dynamic>> devices =
                            widget.roomDevices[room] ?? [];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ExpansionTile(
                            title: Text(room),
                            children: [
                              ...devices.map((device) {
                                return ListTile(
                                  title: Text(
                                    '${device["device"]} (x${device["quantity"]}) - ${device["location"]}',
                                  ),
                                  subtitle:
                                      Text("Price: ₹${device["price"]} each"),
                                  trailing: Text(
                                    "₹${(device["price"] ?? 0) * (device["quantity"] as int)}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
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
                  Text(
                    'Total Cost: ₹${_calculateTotalCost().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _generateQuotation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF075056),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: const Text('Generate Quotation',
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        onPressed: _sendQuotationEmail,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBA52E),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                        child: const Text('Send Quotation',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
