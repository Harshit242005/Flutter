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
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0), // Adjust the border radius as needed
      ),
      backgroundColor: Colors.black,
      title: const Text(
        'Add tech update',
        style: TextStyle(color: Colors.white, fontFamily: 'ReadexPro'),
      ),
      content: Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 10)
        ]),
        width: 600.0, // Set your preferred width
        height: 75.0, // Set your preferred height
        child: TextField(
          style: TextStyle(fontFamily: 'ReadexPro', color: Colors.white),
          controller: _custom_textarea_controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.blue,
                  width: 2), // Adjust color and width as needed
            ),
            hintText: 'Enter tech updates',
            hintStyle: TextStyle(color: Colors.white, fontFamily: 'ReadexPro'),
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
                style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Adjust the border radius as needed
                      ),
                    ),
                    elevation: MaterialStateProperty.all(10),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 160, 243, 244))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      fontFamily: 'ReadexPro',
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                )),
          ),
          const SizedBox(
            width: 25,
          ),
          Container(
              width: 200,
              height: 50,
              child: ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              10.0), // Adjust the border radius as needed
                        ),
                      ),
                      elevation: MaterialStateProperty.all(10),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromARGB(255, 160, 243, 244))),
                  onPressed: () {
                    AddUpdate(_custom_textarea_controller.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(
                        fontFamily: 'ReadexPro',
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  )))
        ])
      ],
    );
  }
}
