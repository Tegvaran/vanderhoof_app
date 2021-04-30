import 'package:flutter/material.dart';

// old -  stateless widget
// class Event extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(padding: EdgeInsets.all(20.0), child: Text('Events Page'));
//   }
// }

String searchWord = "";

class Event extends StatefulWidget {
  Event({Key key}) : super(key: key);

  final title = "Events";

  @override
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<Event> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Text("Events page - stateful widget"),
      ),
    );
  }
}
