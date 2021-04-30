import 'package:flutter/material.dart';

class Hike extends StatefulWidget {
  Hike({Key key}) : super(key: key);
  @override
  _HikePageState createState() => new _HikePageState();
}

class _HikePageState extends State<Hike> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Text('Hike Page - stateful widget'));
  }
}
