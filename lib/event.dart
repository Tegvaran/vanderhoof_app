import 'package:flutter/material.dart';

class Event extends StatefulWidget {
  Event({Key key}) : super(key: key);

  final title = "Events";

  @override
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<Event> {
  // todo: events page

  ///=========================
  /// Final Build Widget
  ///=========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here wrapped in `Expanded` as a child
            // note: play around with flex int value to adjust vertical spaces between widgets
            Text("Events page - first child"),
            Text("another text widget - second child"),
            Text("a third text widget - third child"),
          ],
        ),
      ),
    );
  }
}
