// to handle the landing page
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Landing extends StatefulWidget {
  const Landing({Key? key, required this.email, required this.image})
      : super(key: key);

  final String email;
  final String image;

  @override
  // ignore: library_private_types_in_public_api
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    Uint8List bytes = base64Decode(widget.image);
    return Scaffold(
      // user details
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: MemoryImage(bytes),
        ),
        // add a leading person image icon
        automaticallyImplyLeading: false,
        title: const Text(
          'Stories',
          style: TextStyle(fontFamily: 'ReadexPro'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add your logic when the plus button is pressed
              // For example, you can navigate to a new screen or show a dialog
            },
          ),
        ],
      ),

      // ignore: prefer_const_constructors
      body: SingleChildScrollView(
        // ignore: prefer_const_constructors
        child: Center(
            // ignore: prefer_const_constructors
            child: Column(
          // ignore: prefer_const_literals_to_create_immutables
          children: <Widget>[],
        )),
      ),
    );
  }
}
