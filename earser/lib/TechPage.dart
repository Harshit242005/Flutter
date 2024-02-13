import 'package:earser/Custom_textarea_dialog.dart';
import 'package:flutter/material.dart';

class TechPage extends StatefulWidget {
  final String TechName;
  const TechPage({required this.TechName});

  @override
  _TechPage createState() => _TechPage();
}

class _TechPage extends State<TechPage> {
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
                    return Custom_Textarea_Dialog();
                  });
            },
            icon: Icon(Icons.add),
            splashColor: Colors.blue[400],
            tooltip: 'Add tech related update',
          ),
        ],
      ),
      body: const Center(
          child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
            // axis alignment's
            children: [
              // scrollable widget on the y direction to
              // see the text's
            ]),
      )),
    );
  }
}
