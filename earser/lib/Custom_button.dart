// custom_button.dart

// ignore_for_file: file_names

import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  // ignore: use_key_in_widget_constructors
  const CustomIconButton({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
        message: 'Create tech',
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(icon),
                Tooltip(
                  key: key,
                  message: 'Create tech',
                ),
                const SizedBox(width: 8.0),
                Text(
                  text,
                  style: const TextStyle(fontSize: 20, fontFamily: 'ReadexPro'),
                ),
              ],
            ),
          ),
        ));
  }
}
