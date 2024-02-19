import 'dart:convert';

import 'package:CodeUp/Custom_confirm_dialog.dart';
import 'package:CodeUp/Custom_textarea_dialog.dart';
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

  Future<void> deleteContainer(String date, String techName) async {
    print(
        'calling for container delete $date, month is ${widget.Month} and tech name is: $techName');

    final url = Uri.parse('http://localhost:3000/api/data/removeContainer');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'Month': widget.Month,
          'techName': techName,
          'date': date,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          techUpdate();
        });
        print('called successfully');
      } else {
        print('some error occurred');
      }
    } catch (error) {
      print('some error occurred while deleting the container: $error');
    }
  }

  // function to delete whole tech
  Future<void> deleteTech(String month, String techName) async {
    final url =
        Uri.parse('http://localhost:3000/api/data/$month/deleteTech/$techName');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print('tech has been deleted successfully');
        setState(() {
          techUpdate();
        });
      } else {
        print('tech has not been deleted successfully');
      }
    } catch (error) {
      print('some error occured while deleting the tech $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.TechName}',
          style: const TextStyle(
              fontFamily: 'ReadexPro', fontWeight: FontWeight.bold),
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

              setState(() {
                techUpdate();
              });
            },
            icon: const Icon(Icons.add),
            splashColor: Colors.blue[400],
            tooltip: 'Add tech related update',
          ),
          // adding an another button for deleting the tech as a whole from the database instead of containers
          IconButton(
            onPressed: () {
              // call for the function to delete the whole
              deleteTech(widget.Month, widget.TechName);
            },
            icon: const Icon(Icons.delete),
            splashColor: Colors.blue[400],
            tooltip: 'delete tech',
          )
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Date: $currentDate',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'ReadexPro',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 68, 190, 255),
                                ),
                                onPressed: () async {
                                  // instead of this we should be adding some confirm dialog buttons
                                  ConfirmDialog confirmDialog = ConfirmDialog(
                                    title: "Confirmation",
                                    content:
                                        "Are you sure you want to proceed?",
                                  );

                                  bool userConfirmed =
                                      await confirmDialog.show(context);
                                  if (userConfirmed) {
                                    deleteContainer(
                                        currentDate, widget.TechName);
                                  } else {
                                    print(
                                        'user has not allowed for the deletion of the container');
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                List.generate(updates.length, (updateIndex) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons
                                          .star, // You can change this to any icon you prefer
                                      color: Colors
                                          .yellow, // You can customize the color of the icon
                                    ),
                                    const SizedBox(
                                        width:
                                            8), // Adjust the spacing between the icon and text
                                    Text(
                                      updates[updateIndex],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 15,
                                        fontFamily: 'ReadexPro',
                                      ),
                                    ),
                                  ],
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
