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
  List<List<dynamic>> techUpdates = [];

  @override
  void initState() {
    super.initState();
    techUpdate();
  }

  Future<void> techUpdate() async {
    final url = Uri.parse(
        'http://localhost:3000/api/data/${widget.Month}/getTechUpdates/${widget.TechName}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> decodedUpdates = jsonDecode(response.body)['techUpdates'];
        print('decoded updates are: $decodedUpdates');

        setState(() {
          techUpdates = decodedUpdates.map((update) {
            // Convert each map to a list with the desired structure
            return [
              update['today_date'], // 0 index: today_date
              List<dynamic>.from(
                  update['updates']) // 1 index: updates as a list
            ];
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
        title: Text(
          '${widget.TechName}',
          style:
              TextStyle(fontFamily: 'ReadexPro', fontWeight: FontWeight.bold),
        ),
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
                    // Get the current subarray
                    List<dynamic> currentUpdate = techUpdates[index];

                    // Extract date and updates from the subarray
                    String currentDate = currentUpdate[0];
                    List<dynamic> updates = currentUpdate[1];

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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'ReadexPro'),
                          ),
                          SizedBox(height: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                List.generate(updates.length, (updateIndex) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  updates[updateIndex],
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'ReadexPro'),
                                ),
                              );
                            }),
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
