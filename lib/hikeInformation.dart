import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'fireStoreObjects.dart';
import 'main.dart';

class HikeInformation extends StatefulWidget {
  final HikeTrail hikeTrail;

  HikeInformation({Key key, @required this.hikeTrail}) : super(key: key);

  @override
  _HikeInformationState createState() => _HikeInformationState(hikeTrail);
}

class _HikeInformationState extends State<HikeInformation> {
  HikeTrail hikeTrail;
  _HikeInformationState(this.hikeTrail);
  static const double TITLE_SIZE = 40;
  static const double BODY_SIZE = 20;

  static const Color textColor = Colors.black;
  final Color greenColor = Colors.green[900];
  final Color orangeColor = Colors.orange;
  final Color redColor = Colors.red[800];

  Color getDifficultyColor() {
    Color difficultyColor;
    if (hikeTrail.rating == "Easy") {
      difficultyColor = greenColor;
    } else if (hikeTrail.rating == "Medium") {
      difficultyColor = orangeColor;
    } else {
      difficultyColor = redColor;
    }
    return difficultyColor;
  }

  Color getAccessibilityColor() {
    Color accessibilityColor;
    if (hikeTrail.wheelchair == "Accessible") {
      accessibilityColor = greenColor;
    } else {
      accessibilityColor = redColor;
    }
    return accessibilityColor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: colorBackground,
        appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: Text(hikeTrail.name)),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              child: (hikeTrail.imgURL != "" && hikeTrail.imgURL != null)
                  ? Image(
                      image: NetworkImage(hikeTrail.imgURL),
                      height: 200,
                      width: double.infinity,
                    )
                  : Container(),
            ),
            Container(
              width: double.infinity,
              color: greenColor,
              child: Text(
                hikeTrail.name,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: TITLE_SIZE),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.all(5),
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
                  Text(
                    "Distance: ${hikeTrail.distance}",
                    style: TextStyle(
                      fontSize: BODY_SIZE,
                      color: textColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  RichText(
                      text: TextSpan(
                          style:
                              TextStyle(fontSize: BODY_SIZE, color: textColor),
                          children: <TextSpan>[
                        TextSpan(text: 'Difficulty: '),
                        TextSpan(
                          text: '${hikeTrail.rating}',
                          style: TextStyle(
                            fontSize: BODY_SIZE,
                            color: getDifficultyColor(),
                          ),
                        ),
                      ])),
                  Text(
                    "Time: ${hikeTrail.time}",
                    style: TextStyle(
                      fontSize: BODY_SIZE,
                      color: textColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  Row(
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
                              text: '${hikeTrail.wheelchair}',
                              style: TextStyle(
                                fontSize: BODY_SIZE,
                                color: getAccessibilityColor(),
                              ),
                            ),
                          ])),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      "Trail Description",
                      style: TextStyle(
                        fontSize: BODY_SIZE,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: textColor,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Text(
                    hikeTrail.description,
                    style: TextStyle(
                      fontSize: BODY_SIZE,
                      color: textColor,
                    ),
                    textAlign: TextAlign.left,
                  )
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: colorAccent,
                          borderRadius: BorderRadius.circular(15)),
                      padding: EdgeInsets.all(5),
                      child: Text(
                        "Points of Interest",
                        style: TextStyle(
                          fontSize: BODY_SIZE,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: textColor,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    for (var i = 1; i <= hikeTrail.pointsOfInterest.length; i++)
                      RichText(
                          text: TextSpan(
                              style: TextStyle(
                                  fontSize: BODY_SIZE, color: textColor),
                              children: <TextSpan>[
                            TextSpan(
                                text:
                                    '$i) ${hikeTrail.pointsOfInterest[i - 1]['name']} ',
                                style: TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: BODY_SIZE)),
                            TextSpan(
                              text:
                                  '${hikeTrail.pointsOfInterest[i - 1]['description']}\n',
                              style: TextStyle(
                                fontSize: BODY_SIZE,
                              ),
                            ),
                          ])),
                  ],
                ))
          ],
        )));
  }
}
