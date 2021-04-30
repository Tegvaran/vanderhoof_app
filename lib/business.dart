import 'package:flutter/material.dart';

class Business extends StatefulWidget {
  Business({Key key}) : super(key: key);
  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<Business> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Text('Business Page - stateful widget'));
  }
}
