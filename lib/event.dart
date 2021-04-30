import 'package:flutter/material.dart';

// initial stateless widget
// class Event extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(padding: EdgeInsets.all(20.0), child: Text('Events Page'));
//   }
// }

// new
// stateful widget
class Event extends StatefulWidget {
  Event({Key key}) : super(key: key);
  @override
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<Event> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Text('Events Page - stateful widget'));
  }
}
