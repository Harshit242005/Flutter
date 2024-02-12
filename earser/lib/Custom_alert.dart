import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  //final VoidCallback onConfirm;

  const CustomAlertDialog({
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
          SizedBox(height: 16.0),
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
      return CustomAlertDialog(
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
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Custom Alert Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showCustomDialog(context);
            },
            child: Text('Show Custom Dialog'),
          ),
        ),
      ),
    );
  }
}
