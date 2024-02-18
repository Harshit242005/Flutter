import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;

  ConfirmDialog({required this.title, required this.content});

  Future<bool> show(BuildContext context) async {
    bool result = await showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text(title,
            style: const TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        content: Text(content,
            style: const TextStyle(
                fontFamily: 'ReadexPro',
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text(
              "Cancel",
              style: TextStyle(
                  fontFamily: 'ReadexPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              Navigator.pop(context, false); // Return false when canceled
            },
          ),
          BasicDialogAction(
            title: const Text(
              "Confirm",
              style: TextStyle(
                  fontFamily: 'ReadexPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
            onPressed: () {
              Navigator.pop(context, true); // Return true when confirmed
            },
          ),
        ],
      ),
    );

    return result ??
        false; // Default to false if result is null (e.g., dialog is dismissed)
  }

  @override
  Widget build(BuildContext context) {
    // You can customize the UI of the widget if needed
    return Container();
  }
}
