import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:vanderhoof_app/cards.dart';

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
  Divider cardDivider = Divider(height: 5, thickness: 4, color: colorAccent);

  static const Color textColor = Colors.black;
  final Color greenColor = Colors.green[900];
  final Color orangeColor = Colors.orange;
  final Color redColor = Colors.red[800];
  // Used in Interactive Viewer to bring the image back to its original postion.
  TransformationController c = TransformationController();

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
    print(hikeTrail);
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
            StickyHeader(
              header: Column(
                children: [
                  Container(
                    color: colorBackground,
                    child: (!isFieldEmpty(hikeTrail.imgURL))
                        ? InteractiveViewer(
                            panEnabled: false,
                            boundaryMargin: EdgeInsets.all(100),
                            minScale: 0.5,
                            maxScale: 2,
                            transformationController: c,
                            // Brings the image back to its original position.
                            // reference: https://medium.com/flutterdevs/interactive-viewer-in-flutter-69d3def22a4f
                            onInteractionEnd: (ScaleEndDetails endDetails) {
                              c.value = Matrix4.identity();
                            },
                            child: Image(
                              image: NetworkImage(hikeTrail.imgURL),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(),
                  ),
                  Container(
                      color: colorBackground,
                      child: Column(
                        children: [
                          Text(
                            hikeTrail.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: TITLE_SIZE),
                          ),
                          cardDivider,
                        ],
                      )),
                ],
              ),
              content: Column(
                children: [
                  (hikeTrail.rating != null ||
                          hikeTrail.distance != null ||
                          hikeTrail.time != null ||
                          hikeTrail.wheelchair != null)
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                              color: colorAccent, width: 5))),
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    "Trail Details",
                                    style: TextStyle(
                                      fontSize: BODY_SIZE,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                              !isFieldEmpty(hikeTrail.distance)
                                  ? Text(
                                      "Distance: ${hikeTrail.distance}",
                                      style: TextStyle(
                                        fontSize: BODY_SIZE,
                                        color: textColor,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  : Container(),
                              !isFieldEmpty(hikeTrail.rating)
                                  ? RichText(
                                      text: TextSpan(
                                          style: TextStyle(
                                              fontSize: BODY_SIZE,
                                              color: textColor),
                                          children: <TextSpan>[
                                          TextSpan(text: 'Difficulty: '),
                                          TextSpan(
                                            text: '${hikeTrail.rating}',
                                            style: TextStyle(
                                              fontSize: BODY_SIZE,
                                              color: getDifficultyColor(),
                                            ),
                                          ),
                                        ]))
                                  : Container(),
                              !isFieldEmpty(hikeTrail.time)
                                  ? Text(
                                      "Time: ${hikeTrail.time}",
                                      style: TextStyle(
                                        fontSize: BODY_SIZE,
                                        color: textColor,
                                      ),
                                      textAlign: TextAlign.left,
                                    )
                                  : Container(),
                              !isFieldEmpty(hikeTrail.wheelchair)
                                  ? RichText(
                                      text: TextSpan(
                                          style: TextStyle(
                                              fontSize: BODY_SIZE,
                                              color: textColor),
                                          children: <TextSpan>[
                                          TextSpan(text: 'Wheelchair: '),
                                          TextSpan(
                                            text: '${hikeTrail.wheelchair}',
                                            style: TextStyle(
                                              fontSize: BODY_SIZE,
                                              color: getAccessibilityColor(),
                                            ),
                                          ),
                                        ]))
                                  : Container(),
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: !isFieldEmpty(hikeTrail.description)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: colorAccent, width: 5))),
                                padding: EdgeInsets.all(5),
                                child: Text(
                                  "Trail Description",
                                  style: TextStyle(
                                    fontSize: BODY_SIZE,
                                    fontWeight: FontWeight.bold,
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
                          )
                        : Container(),
                  ),
                  (hikeTrail.pointsOfInterest != null)
                      ? Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: colorAccent, width: 5))),
                          padding: EdgeInsets.all(5),
                          child: Text(
                            "Points of Interest",
                            style: TextStyle(
                              fontSize: BODY_SIZE,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(),
                  (hikeTrail.pointsOfInterest != null)
                      ? Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CarouselSlider(
                              items: getAsList(),
                              options: CarouselOptions(
                                  scrollDirection: Axis.horizontal,
                                  enlargeCenterPage: true,
                                  enableInfiniteScroll: true,
                                  height: 300,
                                  pageSnapping: true),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ],
        )));
  }

  getAsList() {
    List<Widget> listOfPoI = [];
    for (var i = 1; i <= hikeTrail.pointsOfInterest.length; i++) {
      Container test = Container(
        decoration: BoxDecoration(
            color: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(3, 10)),
            ],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(
                    '$i) ${hikeTrail.pointsOfInterest[i - 1]['name']} \n',
                    style: TextStyle(
                      color: greenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: BODY_SIZE,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                cardDivider,
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                      '${hikeTrail.pointsOfInterest[i - 1]['description']}\n',
                      style: TextStyle(
                        fontSize: BODY_SIZE,
                      ),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      );

      listOfPoI.add(test);
    }
    return listOfPoI;
  }
}
