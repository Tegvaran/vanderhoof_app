import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vanderhoof_app/main.dart';

import 'hikingInformation.dart';

class HikeCard extends StatelessWidget {
  final String name;
  final String distance;
  final String rating;
  final String time;
  final String wheelchair;

  static const double TITLE_SIZE = 26;
  static const double BODY_SIZE = 20;

  final Color textColor = Colors.grey[300];
  final Color greenColor = Colors.lightGreenAccent[400];
  final Color orangeColor = colorAccent;
  final Color redColor = Colors.red[500];

  HikeCard(this.name, this.distance, this.rating, this.time, this.wheelchair);

  Color getDifficultyColor() {
    Color difficultyColor;
    if (this.rating == "Easy") {
      difficultyColor = greenColor;
    } else if (this.rating == "Medium") {
      difficultyColor = orangeColor;
    } else {
      difficultyColor = redColor;
    }
    return difficultyColor;
  }

  Color getAccessibilityColor() {
    Color accessibilityColor;
    if (this.wheelchair == "Accessible") {
      accessibilityColor = greenColor;
    } else {
      accessibilityColor = redColor;
    }
    return accessibilityColor;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorPrimary,
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ExpansionTile(
        title: Text(
          this.name,
          style: TextStyle(fontSize: TITLE_SIZE, color: textColor),
        ),
        children: <Widget>[
          Divider(
            height: 10,
            thickness: 2,
            color: Colors.grey[500],
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
                    color: textColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: Text(
                  "Distance: ${this.distance}",
                  style: TextStyle(
                    fontSize: BODY_SIZE,
                    color: textColor,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                child: RichText(
                    text: TextSpan(
                        style: TextStyle(fontSize: BODY_SIZE, color: textColor),
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
                  "Time: ${this.time}",
                  style: TextStyle(
                    fontSize: BODY_SIZE,
                    color: textColor,
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
                                fontSize: BODY_SIZE, color: textColor),
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
