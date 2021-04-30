import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlaceCard extends StatelessWidget {
  final String name;
  static const double TEXT_SIZE = 26;
  PlaceCard(this.name);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.grey,
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ExpansionTile(
          title: Text(this.name),
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: Text(
                "Trail Details",
                style: TextStyle(
                  fontSize: TEXT_SIZE,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ));
  }
}
