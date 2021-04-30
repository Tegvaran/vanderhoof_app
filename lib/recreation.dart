import 'package:flutter/material.dart';

class Recreation extends StatefulWidget {
  Recreation({Key key}) : super(key: key);

  final title = "Recreation Spots";

  @override
  _RecreationPageState createState() => new _RecreationPageState();
}

class _RecreationPageState extends State<Recreation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
          padding: EdgeInsets.all(20.0),
          child: Text("Recreation page - stateful widget")),
    );
  }
}
