import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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
                            color: textColor,
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
  final ItemScrollController scrollController;
  final int scrollIndex;
  static const double TITLE_SIZE = 26;
  static const double BODY_SIZE = 20;
  static const double ICON_SIZE = 45;
  static const double SCROLL_ALIGNMENT = 0;

  final Color textColor = Colors.grey[300];
  final Color greenColor = Colors.lightGreenAccent[400];
  final Color orangeColor = colorAccent;
  final Color redColor = Colors.red[500];

  BusinessCard(this.business, this.scrollController, this.scrollIndex);

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
      await canLaunch("https://www.facebook.com/$username/")
          ? launch("https://www.facebook.com/$username/")
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

  void _launchMailURL(String email) async => await canLaunch('mailto:$email')
      ? launch('mailto:$email')
      : Fluttertoast.showToast(
          msg: "Could not open the email app for $email",
          toastLength: Toast.LENGTH_SHORT);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: colorPrimary,
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ExpansionTile(
            onExpansionChanged: (_isExpanded) {
              if (_isExpanded) {
                // check if Expanded
                // let ExpansionTile expand, then scroll Tile to top of the list
                Future.delayed(Duration(milliseconds: 250)).then((value) {
                  scrollController.scrollTo(
                    index: scrollIndex,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: SCROLL_ALIGNMENT,
                  );
                });
              }
            },
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
              (business.imgURL != "" && business.imgURL != null)
                  ? Image(
                      image: NetworkImage(business.imgURL),
                    )
                  : Container(),
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
                      (business.website != "" && business.website != null)
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.globe),
                              onPressed: () {
                                _launchWebsiteURL(business.website);
                              },
                              iconSize: ICON_SIZE,
                              color: textColor,
                            )
                          : Container(),
                      (business.phoneNumber != "" &&
                              business.phoneNumber != null)
                          ? IconButton(
                              icon: Icon(Icons.phone),
                              onPressed: () {
                                _launchPhoneURL(business.phoneNumber);
                              },
                              iconSize: ICON_SIZE,
                              color: textColor,
                            )
                          : Container(),
                      (business.email != "" && business.email != null)
                          ? IconButton(
                              icon: Icon(Icons.email),
                              // onPressed code reference: https://pub.dev/packages/open_mail_app
                              onPressed: () {
                                _launchMailURL(business.email);
                              },
                              iconSize: ICON_SIZE,
                              color: textColor,
                            )
                          : Container(),
                      (business.socialMedia["facebook"] != "" &&
                              business.socialMedia['facebook'] != null)
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.facebook),
                              onPressed: () {
                                _launchFacebookURL(
                                    business.socialMedia["facebook"]);
                              },
                              iconSize: ICON_SIZE,
                              color: textColor,
                            )
                          : Container(),
                      (business.socialMedia["instagram"] != "" &&
                              business.socialMedia['instagram'] != null)
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.instagram),
                              onPressed: () {
                                _launchInstaURL(
                                    business.socialMedia["instagram"]);
                              },
                              iconSize: ICON_SIZE,
                              color: textColor,
                            )
                          : Container(),
                      (business.socialMedia["twitter"] != "" &&
                              business.socialMedia['twitter'] != null)
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.twitter),
                              onPressed: () {
                                _launchTwitterURL(
                                    business.socialMedia["twitter"]);
                              },
                              iconSize: ICON_SIZE,
                              color: textColor,
                            )
                          : Container(),
                    ])
                  ])
            ]));
  }
}
