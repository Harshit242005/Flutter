import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Custom_Textarea_Dialog extends StatefulWidget {
  // passing tech name in the call
  final String techName;
  final String Month;
  const Custom_Textarea_Dialog({required this.techName, required this.Month});
  @override
  _Custom_Textarea_Dialog createState() => _Custom_Textarea_Dialog();
}

class _Custom_Textarea_Dialog extends State<Custom_Textarea_Dialog> {
  final TextEditingController _custom_textarea_controller =
      TextEditingController();
  // controller has been decided

  // function call for the adding of the textarea text
  //within the tech document

  Future<void> AddUpdate(String updateText) async {
    final url = Uri.parse(
        'http://localhost:3000/api/data/${widget.Month}/techUpdate/${widget.techName}/$updateText');
    try {
      final response = await http.post(url);
      print(response);
      if (response.statusCode == 200) {
        // update the UI accordindgy
      } else {
        print('Some error occured while updating the tech');
      }
    } catch (error) {
      print('some error occured $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add tech update for'),
      content: Container(
        width: 600.0, // Set your preferred width
        height: 100.0, // Set your preferred height
        child: TextField(
          controller: _custom_textarea_controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Enter your multiline text here',
            border: OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            width: 200,
            height: 50,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel')),
          ),
          const SizedBox(
            width: 25,
          ),
          Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  // call to update the text into tech

                  onPressed: () {
                    AddUpdate(_custom_textarea_controller.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add')))
        ])
      ],
    );
  }
}
