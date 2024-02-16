// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  //final VoidCallback onConfirm;

  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    //required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(content),
          const SizedBox(height: 16.0),
          // ElevatedButton(
          //   onPressed: onConfirm,
          //   child: Text('Confirm'),
          // ),
        ],
      ),
    );
  }
}

void showCustomDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const CustomAlertDialog(
        title: 'Custom Alert',
        content: 'This is a custom alert dialog.',
        // onConfirm: () {
        //   Navigator.pop(context);
        // },
      );
    },
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Custom Alert Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showCustomDialog(context);
            },
            child: const Text('Show Custom Dialog'),
          ),
        ),
      ),
    );
  }
}
