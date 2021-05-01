import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'hikingInformation.dart';

class HikeCard extends StatelessWidget {
  final String name;
  final double distance;
  final String rating;
  final int time;
  final String wheelchair;

  static const double TITLE_SIZE = 26;
  static const double BODY_SIZE = 20;

  HikeCard(this.name, this.distance, this.rating, this.time, this.wheelchair);

  Color getDifficultyColor() {
    Color difficultyColor;
    if (this.rating == "Easy") {
      difficultyColor = Colors.green[800];
    } else if (this.rating == "Medium") {
      difficultyColor = Colors.orange[700];
    } else {
      difficultyColor = Colors.red[900];
    }
    return difficultyColor;
  }

  Color getAccessibilityColor() {
    Color accessibilityColor;
    if (this.wheelchair == "Accessible") {
      accessibilityColor = Colors.green[800];
    } else {
      accessibilityColor = Colors.red[900];
    }
    return accessibilityColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[400],
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ExpansionTile(
        title: Text(
          this.name,
          style: TextStyle(fontSize: TITLE_SIZE, color: Colors.black),
        ),
        children: <Widget>[
          Divider(
            height: 10,
            thickness: 2,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: Text(
                  "Trail Details",
                  style: TextStyle(
                    fontSize: BODY_SIZE,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: Text(
                  "Distance: ${this.distance} km",
                  style: TextStyle(
                    fontSize: BODY_SIZE,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: RichText(
                    text: TextSpan(
                        style:
                            TextStyle(fontSize: BODY_SIZE, color: Colors.black),
                        children: <TextSpan>[
                      TextSpan(text: 'Difficulty: '),
                      TextSpan(
                        text: '${this.rating}',
                        style: TextStyle(
                          fontSize: BODY_SIZE,
                          color: getDifficultyColor(),
                        ),
                      ),
                    ])),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: Text(
                  "Time: ${this.time} min",
                  style: TextStyle(
                    fontSize: BODY_SIZE,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(
                        text: TextSpan(
                            style: TextStyle(
                                fontSize: BODY_SIZE, color: Colors.black),
                            children: <TextSpan>[
                          TextSpan(text: 'Wheelchair: '),
                          TextSpan(
                            text: '${this.wheelchair}',
                            style: TextStyle(
                              fontSize: BODY_SIZE,
                              color: getAccessibilityColor(),
                            ),
                          ),
                        ])),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.article_outlined,
                            size: 50,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HikingInformation(),
                                ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
