import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:vanderhoof_app/main.dart';
import 'package:vanderhoof_app/fireStoreObjects.dart';
import 'package:url_launcher/url_launcher.dart';

import 'hikingInformation.dart';

class HikeCard extends StatelessWidget {
  final HikeTrail hikeTrail;
  static const double TITLE_SIZE = 26;
  static const double BODY_SIZE = 20;

  final Color textColor = Colors.grey[300];
  final Color greenColor = Colors.lightGreenAccent[400];
  final Color orangeColor = colorAccent;
  final Color redColor = Colors.red[500];

  HikeCard(this.hikeTrail);

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
    return Card(
      color: colorPrimary,
      margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ExpansionTile(
        title: Text(
          hikeTrail.name,
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
                  "Distance: ${hikeTrail.distance}",
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
                        text: '${hikeTrail.rating}',
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
                  "Time: ${hikeTrail.time}",
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
                            text: '${hikeTrail.wheelchair}',
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

class BusinessCard extends StatelessWidget {
  final Business business;
  static const double TITLE_SIZE = 26;
  static const double BODY_SIZE = 20;
  static const double ICON_SIZE = 45;

  final Color textColor = Colors.grey[300];
  final Color greenColor = Colors.lightGreenAccent[400];
  final Color orangeColor = colorAccent;
  final Color redColor = Colors.red[500];

  BusinessCard(this.business);

  void _launchWebsiteURL(String website) async => await canLaunch(website)
      ? launch(website)
      : Fluttertoast.showToast(
          msg: "Could not open website $website",
          toastLength: Toast.LENGTH_SHORT);

  void _launchInstaURL(String username) async =>
      await canLaunch("instagram.com/$username/")
          ? launch("instagram.com/$username/")
          : Fluttertoast.showToast(
              msg: "Could not open profile: $username",
              toastLength: Toast.LENGTH_SHORT);

  void _launchFacebookURL(username) async =>
      await canLaunch("facebook.com/$username/")
          ? launch("facebook.com/$username/")
          : Fluttertoast.showToast(
              msg: "Could not open profile: $username",
              toastLength: Toast.LENGTH_SHORT);

  void _launchTwitterURL(username) async =>
      await canLaunch("twitter.com/$username/")
          ? launch("twitter.com/$username/")
          : Fluttertoast.showToast(
              msg: "Could not open profile: $username",
              toastLength: Toast.LENGTH_SHORT);

  void _launchPhoneURL(String phoneNumber) async =>
      await canLaunch('tel:$phoneNumber')
          ? launch('tel:$phoneNumber')
          : Fluttertoast.showToast(
              msg: "Could not set up a call for $phoneNumber",
              toastLength: Toast.LENGTH_SHORT);

  // onPressed code reference: https://pub.dev/packages/open_mail_app
  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: colorPrimary,
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ExpansionTile(
            title: Text(
              business.name,
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
                        "${business.description}",
                        style: TextStyle(
                          fontSize: BODY_SIZE,
                          color: textColor,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Row(children: <Widget>[
                      (business.website != "")
                          ? IconButton(
                              icon: Icon(Icons.arrow_circle_down_outlined),
                              onPressed: () {
                                _launchWebsiteURL(business.website);
                              },
                              iconSize: ICON_SIZE,
                            )
                          : Container(),
                      (business.phoneNumber != "")
                          ? IconButton(
                              icon: Icon(Icons.phone),
                              onPressed: () {
                                _launchPhoneURL(business.phoneNumber);
                              },
                              iconSize: ICON_SIZE,
                            )
                          : Container(),
                      (business.email != "")
                          ? IconButton(
                              icon: Icon(Icons.email),
                              // onPressed code reference: https://pub.dev/packages/open_mail_app
                              onPressed: () async {
                                // Android: Will open mail app or show native picker.
                                // iOS: Will open mail app if single mail app found.
                                var result = await OpenMailApp.openMailApp();

                                // If no mail apps found, show error
                                if (!result.didOpen && !result.canOpen) {
                                  showNoMailAppsDialog(context);

                                  // iOS: if multiple mail apps found, show dialog to select.
                                  // There is no native intent/default app system in iOS so
                                  // you have to do it yourself.
                                } else if (!result.didOpen && result.canOpen) {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return MailAppPickerDialog(
                                        mailApps: result.options,
                                      );
                                    },
                                  );
                                }
                              },
                              iconSize: ICON_SIZE,
                            )
                          : Container(),
                      (business.socialMedia["facebook"] != "")
                          ? IconButton(
                              icon: Icon(Icons.tag_faces_outlined),
                              onPressed: () {
                                _launchFacebookURL(
                                    business.socialMedia["facebook"]);
                              },
                              iconSize: ICON_SIZE,
                            )
                          : Container(),
                      (business.socialMedia["instagram"] != "")
                          ? IconButton(
                              icon: Icon(Icons.arrow_circle_down_outlined),
                              onPressed: () {
                                _launchInstaURL(
                                    business.socialMedia["instagram"]);
                              },
                              iconSize: ICON_SIZE,
                            )
                          : Container(),
                      (business.socialMedia["twitter"] != "")
                          ? IconButton(
                              icon: Icon(Icons.bike_scooter_rounded),
                              onPressed: () {
                                _launchTwitterURL(
                                    business.socialMedia["twitter"]);
                              },
                              iconSize: ICON_SIZE,
                            )
                          : Container(),
                    ])
                  ])
            ]));
  }
}
