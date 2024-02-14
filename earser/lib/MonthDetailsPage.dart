import 'dart:convert';

import 'package:earser/Custom_button.dart';
import 'package:earser/Custom_dialog.dart';
import 'package:earser/TechPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MonthDetailsPage extends StatefulWidget {
  final String month;

  const MonthDetailsPage({required this.month});

  @override
  _MonthDetailsPageState createState() => _MonthDetailsPageState();
}

class _MonthDetailsPageState extends State<MonthDetailsPage> {
  List<String> techNames = [];

  @override
  void initState() {
    super.initState();
    // Call fetchTechNames when the widget is first loaded
    fetchTechNames(widget.month);
  }

  // Function to fetch tech names
  Future<void> fetchTechNames(String monthName) async {
    final uri = Uri.parse('http://localhost:3000/fetchTechNames/$monthName');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print('Successfully fetched tech names');

        print(response.body);
        final TechNamesResponse techResponse =
            TechNamesResponse.fromJson(jsonDecode(response.body));
        print(techResponse.techNames);
        // class based reponse decoding
        setState(() {
          techNames = techResponse.techNames;
        });
      } else {
        print('Not been able to fetch the tech names');
      }
    } catch (error) {
      print('Faced error while fetching tech names: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.month} Details'),
        actions: [
          CustomIconButton(
            icon: Icons.add,
            text: 'Create',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog();
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'Details for ${widget.month}',
              //   style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              // ),
              // Display tech names as buttons

              Column(
                children: techNames.map((techName) {
                  return ElevatedButton(
                    onPressed: () {
                      // Handle button press for the specific tech name
                      print('Button pressed for $techName');
                      // navigate to that page
                      // Navigate to TechPage and pass techName as a parameter
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TechPage(TechName: techName, Month: widget.month),
                        ),
                      );
                    },
                    child: Text(techName),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// handling the response for the tech class
class TechNamesResponse {
  final List<String> techNames;

  TechNamesResponse({required this.techNames});

  factory TechNamesResponse.fromJson(Map<String, dynamic> json) {
    return TechNamesResponse(
      techNames: List<String>.from(json['techNames']),
    );
  }
}
