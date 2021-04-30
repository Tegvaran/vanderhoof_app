import 'package:flutter/material.dart';

class Recreation extends StatefulWidget {
  Recreation({Key key}) : super(key: key);
  @override
  _RecreationPageState createState() => new _RecreationPageState();
}

class _RecreationPageState extends State<Recreation> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Text('Recreation Page - stateful widget'));
  }
}
