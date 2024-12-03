import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HMS MESS App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QRScannerScreen()),
                  );
                },
                child: Text('Scan Student'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Developed With 🩵 by Hashim Hameem',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (barcode, args) {
          if (barcode.rawValue == null) {
            _showSnackBar(context, 'Failed to scan QR Code');
          } else {
            final String data = barcode.rawValue!;
            Navigator.pop(context); // Close scanner
            _handleScannedData(context, data);
          }
        },
      ),
    );
  }

  void _handleScannedData(BuildContext context, String data) async {
    try {
      final jsonData = jsonDecode(data);
      final String rollNo = jsonData['rollno'];

      // Show scanned data to user with an OK button to confirm sending the data.
      _showScannedDataDialog(context, jsonData, rollNo);
    } catch (e) {
      _showSnackBar(context, 'Invalid QR code data');
    }
  }

  // Update: Moved sending data logic to the dialog's OK button.
  void _showScannedDataDialog(
      BuildContext context, Map<String, dynamic> jsonData, String rollNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scanned Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Name: ${jsonData['name']}'),
            Text('Roll No: ${jsonData['rollno']}'),
            Text('Email: ${jsonData['email']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _sendRollNoToServer(context, rollNo); // Send data after OK
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRollNoToServer(BuildContext context, String rollNo) async {
    final url = Uri.parse('http://52.160.41.102:3000/api/mess/dtTransaction');

    try {
      final requestBody = jsonEncode({
        'studentId': rollNo,
        'amount': '90',
        'meal': 'lunch',
      });

      print('Sending POST request to $url');
      print('Request body: $requestBody');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        _showSnackBar(context, 'Roll No sent successfully!');
      } else {
        _showSnackBar(
          context,
          'Failed to send Roll No. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error sending data to server: $e');
      _showSnackBar(context, 'Error sending data to server: $e');
    }
  }

  // Helper method to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
