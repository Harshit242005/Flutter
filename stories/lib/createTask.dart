import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateTask extends StatefulWidget {
  const CreateTask({Key? key}) : super(key: key);
  @override
  _CreateTaskState createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  // controllers for the input field
  final TextEditingController heading = TextEditingController();
  final TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create task',
          style: TextStyle(
              fontFamily: 'ReadexPro',
              fontSize: 24,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Type heading',
                  style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    width: 250,
                    height: 50,
                    child: TextField(
                      style: const TextStyle(fontFamily: 'ReadexPro'),
                      controller: heading,
                      decoration: const InputDecoration(
                          labelText: 'Type heading...',
                          hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(48, 0, 0, 0),
                            width: 0.5,
                          ))),
                    ))
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Type description',
                  style: TextStyle(
                      fontFamily: 'ReadexPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                    width: 300,
                    height: 250,
                    child: TextField(
                      style: const TextStyle(fontFamily: 'ReadexPro'),
                      controller: description,
                      maxLines: null,
                      maxLength: null,
                      decoration: const InputDecoration(
                          labelText: 'Type description...',
                          hintStyle: TextStyle(fontFamily: 'ReadexPro'),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(48, 0, 0, 0),
                            width: 0.5,
                          ))),
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
