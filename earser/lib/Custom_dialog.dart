//import 'package:earser/Custom_alert.dart';
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: use_key_in_widget_constructors
class CustomDialog extends StatefulWidget {
  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  // calling up the function to send the new tech name at the backend
  Future<void> CreateTech(String tech_name) async {
    final url =
        Uri.parse('http://localhost:3000/api/data/createNewTech/$tech_name');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('New tech created successfully');
      } else {
        print('Failed to create the new tech');
      }
    } catch (error) {
      print('Error creating new tech $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: Container(
          width: 400,
          height: 75,
          decoration: const BoxDecoration(borderRadius: BorderRadius.zero),
          child: Column(children: [
            TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(
                  hintText: 'Enter your text here',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1))),
            ),
          ])),
      actions: [
        TextButton(
          onPressed: () {
            // Close the dialog when cancel is pressed
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            CreateTech(_textFieldController.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }
}
