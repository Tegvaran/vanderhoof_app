import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'fireStoreObjects.dart';

class HikeInformation extends StatefulWidget {
  final HikeTrail hikeTrail;

  HikeInformation({Key key, @required this.hikeTrail}) : super(key: key);

  @override
  _HikeInformationState createState() => _HikeInformationState(hikeTrail);
}

class _HikeInformationState extends State<HikeInformation> {
  HikeTrail hikeTrail;
  _HikeInformationState(this.hikeTrail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: Text(hikeTrail.name)),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here
            Expanded(
                flex: 2, child: Text("child widget - insert picture here")),
            Expanded(flex: 2, child: Text(hikeTrail.name)),
            Expanded(flex: 2, child: Text(hikeTrail.address)),
            Expanded(flex: 2, child: Text(hikeTrail.description)),
            Expanded(flex: 2, child: Text(hikeTrail.distance)),
            Expanded(flex: 2, child: Text(hikeTrail.rating)),
            Expanded(flex: 2, child: Text(hikeTrail.time)),
            Expanded(flex: 2, child: Text(hikeTrail.wheelchair)),
          ],
        ),
      ),
    );
  }
}
