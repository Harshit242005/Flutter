//import 'package:earser/Custom_alert.dart';
// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ignore: use_key_in_widget_constructors
class CustomDialog extends StatefulWidget {
  final String month;

  const CustomDialog({required this.month});

  @override
  // ignore: library_private_types_in_public_api
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  // calling up the function to send the new tech name at the backend
  Future<void> CreateTech(String tech_name) async {
    final url = Uri.parse(
        'http://localhost:3000/api/data/${widget.month}/createNewTech/$tech_name');
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
      backgroundColor: Colors.black,
      title: const Text(
        'Create new tech',
        style: TextStyle(
            fontFamily: 'ReadexPro',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white),
      ),
      content: Container(
          width: 400,
          height: 75,
          decoration: const BoxDecoration(borderRadius: BorderRadius.zero),
          child: Column(children: [
            TextField(
              style:
                  const TextStyle(fontFamily: 'ReadexPro', color: Colors.white),
              controller: _textFieldController,
              decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue,
                        width: 2), // Adjust color and width as needed
                  ),
                  hintText: 'Type name...',
                  hintStyle: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontWeight: FontWeight.w400,
                      color: Colors.white),
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
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            CreateTech(_textFieldController.text);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          child: const Text(
            'Add',
            style: TextStyle(
                fontFamily: 'ReadexPro', color: Colors.black, fontSize: 16),
          ),
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
