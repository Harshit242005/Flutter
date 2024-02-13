import 'package:flutter/material.dart';

class Custom_Textarea_Dialog extends StatefulWidget {
  @override
  _Custom_Textarea_Dialog createState() => _Custom_Textarea_Dialog();
}

class _Custom_Textarea_Dialog extends State<Custom_Textarea_Dialog> {
  final TextEditingController _custom_textarea_controller =
      TextEditingController();
  // controller has been decided

  // function call for the adding of the textarea text
  //within the tech document

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add tech update'),
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
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Add')))
        ])
      ],
    );
  }
}
