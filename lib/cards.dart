import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vanderhoof_app/main.dart';
import 'package:vanderhoof_app/fireStoreObjects.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:drop_cap_text/drop_cap_text.dart';

import 'hikeInformation.dart';

const double TITLE_SIZE = 22;
const double BODY_SIZE = 18;
const double ICON_SIZE = 24;
const EdgeInsets CARD_INSET = EdgeInsets.fromLTRB(12, 12, 12, 0);
const EdgeInsets TEXT_INSET = EdgeInsets.fromLTRB(16, 5, 0, 0);

TextStyle titleTextStyle = TextStyle(
    fontSize: TITLE_SIZE, color: colorPrimary, fontWeight: FontWeight.bold);
TextStyle bodyTextStyle = TextStyle(fontSize: BODY_SIZE, color: colorText);
TextStyle headerTextStyle = TextStyle(
    fontSize: BODY_SIZE - 2, color: colorText, fontWeight: FontWeight.bold);
Divider cardDivider = Divider(height: 5, thickness: 4, color: colorAccent);

class HikeCard extends StatelessWidget {
  final HikeTrail hikeTrail;
  final ItemScrollController scrollController;
  final int scrollIndex;

  final Color greenColor = Colors.lightGreen[700];
  final Color orangeColor = colorAccent;
  final Color redColor = Colors.red[600];

  HikeCard(this.hikeTrail, this.scrollController, this.scrollIndex);

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
      color: colorBackground,
      margin: CARD_INSET,
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
              );
            });
          }
        },
        title: Text(
          hikeTrail.name,
          style: titleTextStyle,
        ),
        children: <Widget>[
          cardDivider,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
              //   child: Text(
              //     "Trail Details",
              //     style: TextStyle(
              //       fontSize: BODY_SIZE,
              //       fontWeight: FontWeight.bold,
              //       decoration: TextDecoration.underline,
              //       color: colorText,
              //     ),
              //     textAlign: TextAlign.left,
              //   ),
              // ),
              Padding(
                padding: TEXT_INSET,
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Distance: ', style: headerTextStyle),
                  TextSpan(
                    text: '${hikeTrail.distance}',
                    style: bodyTextStyle,
                  ),
                ])),
              ),
              Padding(
                padding: TEXT_INSET,
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Difficulty: ', style: headerTextStyle),
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
                padding: TEXT_INSET,
                child: RichText(
                    text: TextSpan(children: <TextSpan>[
                  TextSpan(text: 'Time: ', style: headerTextStyle),
                  TextSpan(
                    text: '${hikeTrail.time}',
                    style: bodyTextStyle,
                  ),
                ])),
              ),
              Padding(
                padding: TEXT_INSET,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(
                        text: TextSpan(children: <TextSpan>[
                      TextSpan(text: 'Wheelchair: ', style: headerTextStyle),
                      TextSpan(
                        text: '${hikeTrail.wheelchair}',
                        style: TextStyle(
                          fontSize: BODY_SIZE,
                          color: getAccessibilityColor(),
                        ),
                      ),
                    ])),
                    IconButton(
                      icon: Icon(
                        Icons.open_in_new_outlined,
                        size: 36,
                        color: colorPrimary,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HikeInformation(hikeTrail: hikeTrail),
                            ));
                      },
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
  final double scrollAlignment = 0;

  BusinessCard(this.business, this.scrollController, this.scrollIndex);

  bool isFieldEmpty(String toCheck) {
    return (toCheck == null || toCheck.trim() == "" || toCheck == ".");
  }

  String parseLongField(String toCheck) {
    String result = toCheck.trim();
    if (toCheck.length > 35) {
      result = toCheck.substring(0, 35) + "...";
    }
    return result;
  }

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

  void _launchAddressURL(address) async => await canLaunch(
          'https://www.google.com/maps/search/?api=1&query=$address')
      ? launch('https://www.google.com/maps/search/?api=1&query=$address')
      : Fluttertoast.showToast(
          msg: "Could not open directions for $address.",
          toastLength: Toast.LENGTH_SHORT);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: colorBackground,
        margin: CARD_INSET,
        child: ExpansionTile(
            onExpansionChanged: (_isExpanded) {
              if (_isExpanded) {
                // check if Expanded
                // let ExpansionTile expand, then scroll Tile to top of the view
                Future.delayed(Duration(milliseconds: 250)).then((value) {
                  scrollController.scrollTo(
                    index: scrollIndex,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    // alignment: scrollAlignment,
                  );
                });
              }
            },
            title: Text(business.name, style: titleTextStyle),
            children: <Widget>[
              cardDivider,
              Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: DropCapText(
                      (!isFieldEmpty(business.description))
                          ? business.description
                          : "",
                      style: bodyTextStyle,
                      dropCapPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      dropCapPosition: DropCapPosition.end,
                      dropCap: (!isFieldEmpty(business.imgURL))
                          ? DropCap(
                              width: 100,
                              height: 100,
                              child: Image.network(business.imgURL,
                                  fit: BoxFit.fitHeight))
                          : DropCap(width: 0, height: 0, child: null))),
              // (business.imgURL != "" && business.imgURL != null)
              //     ? Container(
              //         height: 100,
              //         alignment: Alignment.topLeft,
              //         child:
              //             Image.network(business.imgURL, fit: BoxFit.fitHeight),
              //       )
              //     : Container(),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // Padding(
                    //   padding: TEXT_INSET,
                    //   child: Text(
                    //     "${business.description}",
                    //     style: bodyTextStyle,
                    //     textAlign: TextAlign.left,
                    //   ),
                    // ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(business.address))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.location_on),
                                onPressed: () {
                                  _launchAddressURL(business.address);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(business.address)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(business.phoneNumber))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.phone),
                                onPressed: () {
                                  _launchPhoneURL(business.phoneNumber);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(business.phoneNumber)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(business.email))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.email),
                                onPressed: () {
                                  _launchMailURL(business.email);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(business.email)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(business.website))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.globe),
                                onPressed: () {
                                  _launchWebsiteURL(business.website);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(business.website)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Row(children: <Widget>[
                      (!isFieldEmpty(business.socialMedia['facebook']))
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.facebook),
                              onPressed: () {
                                _launchFacebookURL(
                                    business.socialMedia["facebook"]);
                              },
                              iconSize: ICON_SIZE,
                              color: colorPrimary,
                            )
                          : Container(),
                      (!isFieldEmpty(business.socialMedia['instagram']))
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.instagram),
                              onPressed: () {
                                _launchInstaURL(
                                    business.socialMedia["instagram"]);
                              },
                              iconSize: ICON_SIZE,
                              color: colorPrimary,
                            )
                          : Container(),
                      (!isFieldEmpty(business.socialMedia['twitter']))
                          ? IconButton(
                              icon: FaIcon(FontAwesomeIcons.twitter),
                              onPressed: () {
                                _launchTwitterURL(
                                    business.socialMedia["twitter"]);
                              },
                              iconSize: ICON_SIZE,
                              color: colorPrimary,
                            )
                          : Container(),
                    ])
                  ])
            ]));
  }
}

/// Represents a recreational card that is displayed on the rec page.
///
/// Takes the values for Rec which is a recreational object, scrollController, scrollIndex.
class RecreationalCard extends StatelessWidget {
  final Recreational rec;
  final ItemScrollController scrollController;
  final int scrollIndex;
  final double scrollAlignment = 0;

  RecreationalCard(this.rec, this.scrollController, this.scrollIndex);

  /// Checks if a give field from the recreational object is empty or not.
  bool isFieldEmpty(String toCheck) {
    return (toCheck == null || toCheck.trim() == "" || toCheck == ".");
  }

  String parseLongField(String toCheck) {
    String result = toCheck.trim();
    if (toCheck.length > 35) {
      result = toCheck.substring(0, 35) + "...";
    }
    return result;
  }

  void _launchWebsiteURL(String website) async => await canLaunch(website)
      ? launch(website)
      : Fluttertoast.showToast(
          msg: "Could not open website $website",
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

  void _launchAddressURL(address) async => await canLaunch(
          'https://www.google.com/maps/search/?api=1&query=$address')
      ? launch('https://www.google.com/maps/search/?api=1&query=$address')
      : Fluttertoast.showToast(
          msg: "Could not open directions for $address.",
          toastLength: Toast.LENGTH_SHORT);

  @override
  Widget build(BuildContext context) {
    return Card(
        color: colorBackground,
        margin: CARD_INSET,
        child: ExpansionTile(
            onExpansionChanged: (_isExpanded) {
              if (_isExpanded) {
                // check if Expanded
                // let ExpansionTile expand, then scroll Tile to top of the view
                Future.delayed(Duration(milliseconds: 250)).then((value) {
                  scrollController.scrollTo(
                    index: scrollIndex,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    // alignment: scrollAlignment,
                  );
                });
              }
            },
            title: Text(rec.name, style: titleTextStyle),
            children: <Widget>[
              cardDivider,
              // Padding(
              //     padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
              //     child: DropCapText(
              //         (!isFieldEmpty(rec.description))
              //             ? rec.description
              //             : "",
              //         style: bodyTextStyle,
              //         dropCapPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
              //         dropCapPosition: DropCapPosition.end,
              //         dropCap: (!isFieldEmpty(business.imgURL))
              //             ? DropCap(
              //             width: 100,
              //             height: 100,
              //             child: Image.network(business.imgURL,
              //                 fit: BoxFit.fitHeight))
              //             : DropCap(width: 0, height: 0, child: null))),
              // (business.imgURL != "" && business.imgURL != null)
              //     ? Container(
              //         height: 100,
              //         alignment: Alignment.topLeft,
              //         child:
              //             Image.network(business.imgURL, fit: BoxFit.fitHeight),
              //       )
              //     : Container(),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // Padding(
                    //   padding: TEXT_INSET,
                    //   child: Text(
                    //     "${business.description}",
                    //     style: bodyTextStyle,
                    //     textAlign: TextAlign.left,
                    //   ),
                    // ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(rec.address))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.location_on),
                                onPressed: () {
                                  _launchAddressURL(rec.address);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(rec.address)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(rec.phoneNumber))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.phone),
                                onPressed: () {
                                  _launchPhoneURL(rec.phoneNumber);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(rec.phoneNumber)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(rec.email))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.email),
                                onPressed: () {
                                  _launchMailURL(rec.email);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(rec.email)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: (!isFieldEmpty(rec.website))
                          ? Row(children: <Widget>[
                              IconButton(
                                icon: FaIcon(FontAwesomeIcons.globe),
                                onPressed: () {
                                  _launchWebsiteURL(rec.website);
                                },
                                iconSize: ICON_SIZE,
                                color: colorPrimary,
                              ),
                              Text('${parseLongField(rec.website)}',
                                  style: headerTextStyle),
                            ])
                          : Container(),
                    ),
                  ])
            ]));
  }
}
