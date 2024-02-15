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
  // List<String> techUpdates = []; // Store the fetched tech updates

  // @override
  // void initState() {
  //   super.initState();
  //   // Call the techUpdates function when the widget is first loaded
  //   techUpdate();
  // }

  // // function to get the list of tech related update back and build the widget back with new data
  // Future<void> techUpdate() async {
  //   final url = Uri.parse(
  //       'http://localhost:3000/api/data/${widget.Month}/getTechUpdates/${widget.TechName}');
  //   try {
  //     final response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       // set build method to create the show tech scroll widget again
  //       setState(() {
  //         techUpdates = List<String>.from(
  //           jsonDecode(response.body)['techUpdates'],
  //         );
  //       });
  //     } else {
  //       print('not been able to fetch the tech updates related to the techs');
  //     }
  //   } catch (error) {
  //     print('got an error while fetching the updates $error');
  //   }
  // }

  List<List<dynamic>> techUpdates =
      []; // Store the fetched tech updates as a 2D list

  @override
  void initState() {
    super.initState();
    // Call the techUpdates function when the widget is first loaded
    techUpdate();
  }

// function to get the list of tech-related updates and build the widget back with new data
  Future<void> techUpdate() async {
    final url = Uri.parse(
        'http://localhost:3000/api/data/${widget.Month}/getTechUpdates/${widget.TechName}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Decode each JSON object within the array
        List<dynamic> decodedUpdates = jsonDecode(response.body)['techUpdates'];
        print(decodedUpdates);
        // Set build method to create the show tech scroll widget again
        setState(() {
          techUpdates = decodedUpdates.map((update) {
            return List<dynamic>.from(jsonDecode(update));
          }).toList();
        });
        print(techUpdates);
      } else {
        print('Not able to fetch the tech updates related to the techs');
      }
    } catch (error) {
      print('Got an error while fetching the updates $error');
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
              // Expanded(
              //     child: ListView.builder(
              //   itemCount: techUpdates.length,
              //   itemBuilder: (context, index) {
              //     return ListTile(
              //       // this should be placed as a date
              //       title: Text(techUpdates[index]),
              //       // this should be a list of text which are tech updates of that date
              //       subtitle: Text('subtitle text'),
              //     );
              //   },
              // ))
              Expanded(
                child: ListView.builder(
                  itemCount: techUpdates.length,
                  itemBuilder: (context, index) {
                    // Get the current subarray
                    List<dynamic> currentUpdate = techUpdates[index];

                    // Extract date and updates from the subarray
                    String currentDate = currentUpdate[0]['today_date'];
                    List<dynamic> updates = currentUpdate[0]['updates'];

                    return Container(
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: $currentDate',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: updates.length,
                            itemBuilder: (context, updateIndex) {
                              return ListTile(
                                title: Text(updates[updateIndex]),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ]),
      )),
    );
  }
}
