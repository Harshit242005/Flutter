import 'dart:convert';

import 'package:earser/Custom_textarea_dialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TechPage extends StatefulWidget {
  final String TechName;
  final String Month;
  const TechPage({required this.TechName, required this.Month});

  @override
  _TechPage createState() => _TechPage();
}

class _TechPage extends State<TechPage> {
  List<String> techUpdates = []; // Store the fetched tech updates

  @override
  void initState() {
    super.initState();
    // Call the techUpdates function when the widget is first loaded
    techUpdate();
  }

  // function to get the list of tech related update back and build the widget back with new data
  Future<void> techUpdate() async {
    final url = Uri.parse(
        'http://localhost:3000/api/data/${widget.Month}/getTechUpdates/${widget.TechName}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // set build method to create the show tech scroll widget again
        setState(() {
          techUpdates = List<String>.from(
            jsonDecode(response.body)['techUpdates'],
          );
        });
      } else {
        print('not been able to fetch the tech updates related to the techs');
      }
    } catch (error) {
      print('got an error while fetching the updates $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.TechName}'),
        actions: [
          IconButton(
            onPressed: () {
              // add a popup dialog
              showDialog(
                  context: context,
                  builder: (context) {
                    return Custom_Textarea_Dialog(
                      techName: widget.TechName,
                      Month: widget.Month,
                    );
                  });

              // rebuild the widget when the button clicked
            },
            icon: Icon(Icons.add),
            splashColor: Colors.blue[400],
            tooltip: 'Add tech related update',
          ),
        ],
      ),
      body: Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
            // axis alignment's
            children: [
              Expanded(
                  child: ListView.builder(
                itemCount: techUpdates.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(techUpdates[index]),
                  );
                },
              ))
            ]),
      )),
    );
  }
}
