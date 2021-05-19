import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:drop_cap_text/drop_cap_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'hikeInformation.dart';
import 'main.dart';
import 'map.dart';

const double TITLE_SIZE = 22;
const double BODY_SIZE = 16;
const double ICON_SIZE = 30;
const double ICON_SIZE_SMALL = 18;
const EdgeInsets HEADER_INSET = EdgeInsets.fromLTRB(0, 20, 0, 0);
const EdgeInsets CARD_INSET = EdgeInsets.fromLTRB(12, 6, 12, 6);
const EdgeInsets TEXT_INSET = EdgeInsets.fromLTRB(16, 16, 16, 0);
const EdgeInsets ICON_INSET = EdgeInsets.fromLTRB(12, 0, 0, 0);

TextStyle titleTextStyle = TextStyle(
    fontSize: TITLE_SIZE, color: colorPrimary, fontWeight: FontWeight.bold);
TextStyle bodyTextStyle = TextStyle(fontSize: BODY_SIZE, color: colorText);
TextStyle headerTextStyle = TextStyle(
    fontSize: BODY_SIZE, color: colorText, fontWeight: FontWeight.bold);
TextStyle header2TextStyle = TextStyle(
    fontSize: BODY_SIZE - 2, color: colorText, fontWeight: FontWeight.bold);
Divider cardDivider = Divider(height: 5, thickness: 4, color: colorAccent);
BoxShadow iconShadow = BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    blurRadius: 3,
    spreadRadius: 3,
    offset: Offset(0, 4));

/// Represents a hike card that is displayed on the hike page.
/// Takes the values for Hike which is a hike object, scrollController, scrollIndex.
class HikeCard extends StatelessWidget {
  final HikeTrail hikeTrail;
  final ItemScrollController scrollController;
  final int scrollIndex;
  Set<Marker> _markers;
  List<FireStoreObject> listOfFireStoreObjects;

  final Color greenColor = Colors.lightGreen[700];
  final Color orangeColor = colorAccent;
  final Color redColor = Colors.red[600];

  HikeCard(this.hikeTrail, this.scrollController, this.scrollIndex,
      this._markers, this.listOfFireStoreObjects);

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

  bool buildInfoPageIcon(HikeTrail hike) {
    return (hike.description != null || hike.pointsOfInterest != null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: colorBackground,
      margin: CARD_INSET,
      child: ExpansionTile(
        onExpansionChanged: (_isExpanded) {
          if (_isExpanded) {
            changeMarkerColor(scrollIndex, _markers, listOfFireStoreObjects,
                scrollController);
            if (hikeTrail.location != null) {
              changeCamera(hikeTrail.location);
            }
            // check if Expanded
            // let ExpansionTile expand, then scroll Tile to top of the list
            Future.delayed(Duration(milliseconds: 250)).then((value) {
              scrollController.scrollTo(
                index: scrollIndex,
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
              );
            });
          } else {
            resetMarkers(_markers, listOfFireStoreObjects, scrollController);
          }
        },
        title: Text(
          hikeTrail.name,
          style: titleTextStyle,
        ),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          cardDivider,
          (!isFieldEmpty(hikeTrail.address))
              ? Row(children: <Widget>[
                  IconButton(
                    icon: DecoratedIcon(Icons.location_on,
                        color: colorPrimary,
                        size: ICON_SIZE,
                        shadows: [
                          iconShadow,
                        ]),
                    tooltip: hikeTrail.address,
                    onPressed: () {
                      _launchAddressURL(hikeTrail.address);
                    },
                  ),
                  Text('${parseLongField(hikeTrail.address)}',
                      style: headerTextStyle),
                ])
              : Container(width: 0, height: 0),
          Padding(
            padding: ICON_INSET,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
                  !isFieldEmpty(hikeTrail.distance)
                      ? Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          IconButton(
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.timeline),
                            onPressed: null,
                            iconSize: ICON_SIZE_SMALL,
                          ),
                          Flexible(
                              child: RichText(
                                  text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'Distance: ', style: header2TextStyle),
                            TextSpan(
                              text: '${hikeTrail.distance}',
                              style: bodyTextStyle,
                            ),
                          ]))),
                        ])
                      : Container(width: 0, height: 0),
                  !isFieldEmpty(hikeTrail.rating)
                      ? Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          IconButton(
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.star_half),
                            onPressed: null,
                            iconSize: ICON_SIZE_SMALL,
                          ),
                          Flexible(
                              child: RichText(
                                  text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'Difficulty: ', style: header2TextStyle),
                            TextSpan(
                              text: '${hikeTrail.rating}',
                              style: TextStyle(
                                fontSize: BODY_SIZE,
                                color: getDifficultyColor(),
                              ),
                            ),
                          ]))),
                        ])
                      : Container(width: 0, height: 0),
                  !isFieldEmpty(hikeTrail.time)
                      ? Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          IconButton(
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.access_time),
                            onPressed: null,
                            iconSize: ICON_SIZE_SMALL,
                          ),
                          Flexible(
                              child: RichText(
                                  text: TextSpan(children: <TextSpan>[
                            TextSpan(text: 'Time: ', style: header2TextStyle),
                            TextSpan(
                              text: '${hikeTrail.time}',
                              style: bodyTextStyle,
                            ),
                          ]))),
                        ])
                      : Container(width: 0, height: 0),
                  !isFieldEmpty(hikeTrail.wheelchair)
                      ? Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                          IconButton(
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.accessible_outlined),
                            onPressed: null,
                            iconSize: ICON_SIZE_SMALL,
                          ),
                          Flexible(
                              child: RichText(
                                  text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'Wheelchair: ', style: header2TextStyle),
                            TextSpan(
                              text: '${hikeTrail.wheelchair}',
                              style: TextStyle(
                                fontSize: BODY_SIZE,
                                color: getAccessibilityColor(),
                              ),
                            ),
                          ]))),
                        ])
                      : Container(width: 0, height: 0),
                ]),
                buildInfoPageIcon(hikeTrail)
                    ? IconButton(
                        icon: DecoratedIcon(Icons.open_in_new_outlined,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HikeInformation(hikeTrail: hikeTrail),
                              ));
                        },
                      )
                    : Container(width: 0, height: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a Business card that is displayed on the businesses page.
/// Takes the values for Business which is a business object, scrollController, scrollIndex.
class BusinessCard extends StatelessWidget {
  final Business business;
  final ItemScrollController scrollController;
  final int scrollIndex;
  final double scrollAlignment = 0;
  Set<Marker> _markers;
  List<FireStoreObject> listOfFireStoreObjects;

  BusinessCard(this.business, this.scrollController, this.scrollIndex,
      this._markers, this.listOfFireStoreObjects);

  String categoryText() {
    String categories = "";
    for (var i = 0; i < business.category.length; i++) {
      if (i != business.category.length - 1) {
        categories = categories + "${business.category[i]}, ";
      } else
        categories = categories + business.category[i];
    }
    return categories;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
        color: colorBackground,
        margin: CARD_INSET,
        child: ExpansionTile(
            onExpansionChanged: (_isExpanded) {
              if (_isExpanded) {
                changeMarkerColor(scrollIndex, _markers, listOfFireStoreObjects,
                    scrollController);
                // moveToLatLng(business.location);
                if (business.location != null) {
                  changeCamera(business.location);
                }
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
              } else {
                resetMarkers(
                    _markers, listOfFireStoreObjects, scrollController);
              }
            },
            title: Text(business.name, style: titleTextStyle),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              cardDivider,

              //// layout option 1: description wrapped around img (top-right corner)
              Padding(
                  padding: TEXT_INSET,
                  child: DropCapText(
                      (!isFieldEmpty(business.description))
                          ? business.description
                          : "",
                      style: bodyTextStyle,
                      // dropCapPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                      dropCapPosition: DropCapPosition.end,
                      dropCap: (!isFieldEmpty(business.imgURL))
                          ? DropCap(
                              width: 120,
                              height: 120,
                              child: Image.network(business.imgURL,
                                  fit: BoxFit.contain))
                          : DropCap(width: 0, height: 0, child: null))),

              //// layout option 2: img above and description below
              // (business.imgURL != "" && business.imgURL != null)
              //     ? Container(
              //         height: 120,
              //         alignment: Alignment.center,
              //         child:
              //             Image.network(business.imgURL, fit: BoxFit.contain),
              //       )
              //     : Container(width: 0, height: 0),
              // !(isFieldEmpty(business.description))
              //     ? Padding(
              //   padding: TEXT_INSET,
              //   child: Text(
              //     "${business.description}",
              //     style: bodyTextStyle,
              //   ),
              // )
              //     : Container(width: 0, height: 0),
              Padding(
                  padding: TEXT_INSET,
                  // Checks if the category's length is empty or not
                  child: (business.category != null &&
                          business.category.length != 0
                      ? RichText(
                          text: TextSpan(children: <TextSpan>[
                          TextSpan(
                              text: 'Categories: ', style: header2TextStyle),
                          TextSpan(
                            text: categoryText(),
                            style: bodyTextStyle,
                          ),
                        ]))
                      : Container(width: 0, height: 0))),
              (!isFieldEmpty(business.address))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.location_on,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        tooltip: business.address,
                        onPressed: () {
                          _launchAddressURL(business.address);
                        },
                      ),
                      Text('${parseLongField(business.address)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(business.phoneNumber))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.phone,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchPhoneURL(business.phoneNumber);
                        },
                      ),
                      Text('${parseLongField(business.phoneNumber)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(business.email))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.email,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchMailURL(business.email);
                        },
                      ),
                      Text('${parseLongField(business.email)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(business.website))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.language,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchWebsiteURL(business.website);
                        },
                      ),
                      Text('${parseLongField(business.website)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),

              /// socialMedia layout 1: all icons in their own row, with labels
              // (!isFieldEmpty(business.socialMedia['facebook']))
              //     ? Row(children: <Widget>[
              //         IconButton(
              //           icon: DecoratedIcon(FontAwesomeIcons.facebook,
              //               color: colorPrimary,
              //               size: ICON_SIZE,
              //               shadows: [
              //                 iconShadow,
              //               ]),
              //           onPressed: () {
              //             _launchFacebookURL(business.socialMedia["facebook"]);
              //           },
              //         ),
              //         Text(
              //             '${parseLongField(business.socialMedia["facebook"])}',
              //             style: headerTextStyle),
              //       ])
              //     : Container(width: 0, height: 0),
              // (!isFieldEmpty(business.socialMedia['instagram']))
              //     ? Row(children: <Widget>[
              //         IconButton(
              //           icon: DecoratedIcon(FontAwesomeIcons.instagram,
              //               color: colorPrimary,
              //               size: ICON_SIZE,
              //               shadows: [
              //                 iconShadow,
              //               ]),
              //           onPressed: () {
              //             _launchInstaURL(business.socialMedia["instagram"]);
              //           },
              //         ),
              //         Text(
              //             '${parseLongField(business.socialMedia["instagram"])}',
              //             style: headerTextStyle),
              //       ])
              //     : Container(width: 0, height: 0),
              // (!isFieldEmpty(business.socialMedia['twitter']))
              //     ? Row(children: <Widget>[
              //         IconButton(
              //           icon: DecoratedIcon(FontAwesomeIcons.twitter,
              //               color: colorPrimary,
              //               size: ICON_SIZE,
              //               shadows: [
              //                 iconShadow,
              //               ]),
              //           onPressed: () {
              //             _launchTwitterURL(business.socialMedia["twitter"]);
              //           },
              //         ),
              //         Text('${parseLongField(business.socialMedia["twitter"])}',
              //             style: headerTextStyle),
              //       ])
              //     : Container(width: 0, height: 0),
              /// socialMedia layout 2: contained in 1 row, icon shows up when available
              // Row(mainAxisAlignment: MainAxisAlignment.start, children: <
              //     Widget>[
              //   (!isFieldEmpty(business.socialMedia['facebook']))
              //       ? Padding(
              //           padding: const EdgeInsets.only(right: 70),
              //           child: IconButton(
              //             icon: DecoratedIcon(FontAwesomeIcons.facebook,
              //                 color: colorPrimary,
              //                 size: ICON_SIZE,
              //                 shadows: [
              //                   iconShadow,
              //                 ]),
              //             onPressed: () {
              //               _launchFacebookURL(
              //                   business.socialMedia["facebook"]);
              //             },
              //           ),
              //         )
              //       : Container(width: 0, height: 0),
              //   (!isFieldEmpty(business.socialMedia['instagram']))
              //       ? Padding(
              //           padding: const EdgeInsets.only(right: 70),
              //           child: IconButton(
              //             icon: DecoratedIcon(FontAwesomeIcons.instagram,
              //                 color: colorPrimary,
              //                 size: ICON_SIZE,
              //                 shadows: [
              //                   iconShadow,
              //                 ]),
              //             onPressed: () {
              //               _launchInstaURL(business.socialMedia["instagram"]);
              //             },
              //           ),
              //         )
              //       : Container(width: 0, height: 0),
              //   (!isFieldEmpty(business.socialMedia['twitter']))
              //       ? Padding(
              //           padding: EdgeInsets.zero,
              //           child: IconButton(
              //             icon: DecoratedIcon(FontAwesomeIcons.twitter,
              //                 color: colorPrimary,
              //                 size: ICON_SIZE,
              //                 shadows: [
              //                   iconShadow,
              //                 ]),
              //             onPressed: () {
              //               _launchTwitterURL(business.socialMedia["twitter"]);
              //             },
              //           ),
              //         )
              //       : Container(width: 0, height: 0),
              // ]),

              /// socialMedia layout 3: always shows up in 1 row, icon colour is grey when empty
              (!isFieldEmpty(business.socialMedia['facebook']) ||
                      !isFieldEmpty(business.socialMedia['instagram']) ||
                      !isFieldEmpty(business.socialMedia['twitter']))
                  ? Row(mainAxisAlignment: MainAxisAlignment.start, children: <
                      Widget>[
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child:
                              (!isFieldEmpty(business.socialMedia['facebook']))
                                  ? IconButton(
                                      icon: DecoratedIcon(
                                          FontAwesomeIcons.facebook,
                                          color: colorPrimary,
                                          size: ICON_SIZE,
                                          shadows: [
                                            iconShadow,
                                          ]),
                                      onPressed: () {
                                        _launchFacebookURL(
                                            business.socialMedia["facebook"]);
                                      })
                                  : IconButton(
                                      icon: DecoratedIcon(
                                        FontAwesomeIcons.facebook,
                                        size: ICON_SIZE,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: null,
                                    )),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child:
                              (!isFieldEmpty(business.socialMedia['instagram']))
                                  ? IconButton(
                                      icon: DecoratedIcon(
                                          FontAwesomeIcons.instagram,
                                          color: colorPrimary,
                                          size: ICON_SIZE,
                                          shadows: [
                                            iconShadow,
                                          ]),
                                      onPressed: () {
                                        _launchInstaURL(
                                            business.socialMedia["instagram"]);
                                      })
                                  : IconButton(
                                      icon: DecoratedIcon(
                                        FontAwesomeIcons.instagram,
                                        size: ICON_SIZE,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: null,
                                    )),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child:
                              (!isFieldEmpty(business.socialMedia['twitter']))
                                  ? IconButton(
                                      icon: DecoratedIcon(
                                          FontAwesomeIcons.twitter,
                                          color: colorPrimary,
                                          size: ICON_SIZE,
                                          shadows: [
                                            iconShadow,
                                          ]),
                                      onPressed: () {
                                        _launchTwitterURL(
                                            business.socialMedia["twitter"]);
                                      })
                                  : IconButton(
                                      icon: DecoratedIcon(
                                        FontAwesomeIcons.twitter,
                                        size: ICON_SIZE,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: null,
                                    )),
                    ])
                  : Container(width: 0, height: 0),
            ]));
  }
}

/// Represents a recreational card that is displayed on the rec page.
/// Takes the values for Rec which is a recreational object, scrollController, scrollIndex.
class RecreationalCard extends StatelessWidget {
  final Recreational rec;
  final ItemScrollController scrollController;
  final int scrollIndex;
  final double scrollAlignment = 0;
  Set<Marker> _markers;
  List<FireStoreObject> listOfFireStoreObjects;

  RecreationalCard(this.rec, this.scrollController, this.scrollIndex,
      this._markers, this.listOfFireStoreObjects);

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
        color: colorBackground,
        margin: CARD_INSET,
        child: ExpansionTile(
            onExpansionChanged: (_isExpanded) {
              if (_isExpanded) {
                changeMarkerColor(scrollIndex, _markers, listOfFireStoreObjects,
                    scrollController);
                if (rec.location != null) {
                  changeCamera(rec.location);
                }
                // check if Expanded
                // let ExpansionTile expand, then scroll Tile to top of the view
                Future.delayed(Duration(milliseconds: 250)).then((value) {
                  scrollController.scrollTo(
                    index: scrollIndex,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                  // alignment: scrollAlignment,
                });
              } else {
                resetMarkers(
                    _markers, listOfFireStoreObjects, scrollController);
              }
            },
            title: Text(rec.name, style: titleTextStyle),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              cardDivider,
              !(isFieldEmpty(rec.description))
                  ? Padding(
                      padding: TEXT_INSET,
                      child: Text(
                        "${rec.description}",
                        style: bodyTextStyle,
                      ),
                    )
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(rec.address))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.location_on,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        tooltip: rec.address,
                        onPressed: () {
                          _launchAddressURL(rec.address);
                        },
                      ),
                      Text('${parseLongField(rec.address)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(rec.phoneNumber))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.phone,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchPhoneURL(rec.phoneNumber);
                        },
                      ),
                      Text('${parseLongField(rec.phoneNumber)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(rec.email))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.email,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchMailURL(rec.email);
                        },
                      ),
                      Text('${parseLongField(rec.email)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(rec.website))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.language,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchWebsiteURL(rec.website);
                        },
                      ),
                      Text('${parseLongField(rec.website)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
            ]));
  }
}

/// Represents a event card that is displayed on the event page.
/// Takes the values for Event which is a event object, scrollController, scrollIndex.
class EventCard extends StatelessWidget {
  final Event event;
  final ItemScrollController scrollController;
  final int scrollIndex;
  final double scrollAlignment = 0;

  EventCard(this.event, this.scrollController, this.scrollIndex);

  String formatDate(DateTime dateTime) {
    String formattedDate = DateFormat('MMM d').format(dateTime);
    return formattedDate;
  }

  String formatDateTime(DateTime dateTime) {
    String formattedDateTime = DateFormat('MMM d ').format(dateTime) +
        DateFormat('jm').format(dateTime);
    return formattedDateTime;
  }

  String formatTime(DateTime dateTime) {
    String formattedTime = DateFormat('jm').format(dateTime);
    return formattedTime;
  }

  Widget _buildDateButton(DateTime dateTime) {
    String formattedDay = DateFormat('d').format(dateTime);
    String formattedMonth = DateFormat('MMM').format(dateTime);
    String formattedWeekday = DateFormat('EEE').format(dateTime);
    return Container(
        width: 100,
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        // decoration: BoxDecoration(
        //     border: Border(right: BorderSide(width: 3.0, color: colorAccent))),
        child: TextButton(
            onPressed: null,
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Column(
                children: <Widget>[
                  Text(formattedMonth,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorText,
                      )),
                  Text(formattedDay,
                      style: TextStyle(
                          fontSize: 18,
                          color: colorPrimary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text('\t\t' + formattedWeekday,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ])));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
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
            title: Text(event.name, style: titleTextStyle),
            leading: _buildDateButton(event.datetimeStart),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              cardDivider,
              (event.imgURL != "" && event.imgURL != null)
                  ? Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Image.network(event.imgURL, fit: BoxFit.contain),
                    )
                  : Container(width: 0, height: 0),
              !(isFieldEmpty(event.description))
                  ? Padding(
                      padding: TEXT_INSET,
                      child: Text(
                        "${event.description}",
                        style: bodyTextStyle,
                      ),
                    )
                  : Container(width: 0, height: 0),
              Padding(
                  padding: EdgeInsets.zero,
                  child: Row(children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: null,
                      iconSize: ICON_SIZE,
                    ),
                    (event.isMultiday
                        ? Text(
                            '${formatDate(event.datetimeStart)} - ${formatDate(event.datetimeEnd)}',
                            style: headerTextStyle)
                        : Text(
                            '${formatDateTime(event.datetimeStart)} - ${formatTime(event.datetimeEnd)}',
                            style: headerTextStyle)),
                  ])),
              (!isFieldEmpty(event.address))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.location_on,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        tooltip: event.address,
                        onPressed: () {
                          _launchAddressURL(event.address);
                        },
                      ),
                      Text('${parseLongField(event.address)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
            ]));
  }
}

/// Represents a event card that is displayed on the event page.
/// Takes the values for Event which is a event object, scrollController, scrollIndex.
class ResourceCard extends StatelessWidget {
  final Resource resource;
  final ItemScrollController scrollController;
  final int scrollIndex;
  final double scrollAlignment = 0;

  ResourceCard(this.resource, this.scrollController, this.scrollIndex);

  // TODO - change class to StatefulWidget and precache images
  // ref: https://alex.domenici.net/archive/preload-images-in-a-stateful-widget-on-flutter
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   precacheImage(Image.network(resource.imgURL).image, context));
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 3,
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
            title: Text(resource.name, style: titleTextStyle),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              cardDivider,
              (resource.imgURL != "" && resource.imgURL != null)
                  ? Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child:
                          Image.network(resource.imgURL, fit: BoxFit.contain),
                    )
                  : Container(width: 0, height: 0),
              !(isFieldEmpty(resource.description))
                  ? Padding(
                      padding: TEXT_INSET,
                      child: Text(
                        "${resource.description}",
                        style: bodyTextStyle,
                      ),
                    )
                  : Container(width: 0, height: 0),
              (!isFieldEmpty(resource.website))
                  ? Row(children: <Widget>[
                      IconButton(
                        icon: DecoratedIcon(Icons.language,
                            color: colorPrimary,
                            size: ICON_SIZE,
                            shadows: [
                              iconShadow,
                            ]),
                        onPressed: () {
                          _launchWebsiteURL(resource.website);
                        },
                      ),
                      Text('${parseLongField(resource.website)}',
                          style: headerTextStyle),
                    ])
                  : Container(width: 0, height: 0),
            ]));
  }
}

/// Open URL in the default browser for [website]
void _launchWebsiteURL(String website) async =>
    await canLaunch('http://$website')
        ? launch('http://$website')
        : Fluttertoast.showToast(
            msg: "Could not open website http://$website",
            toastLength: Toast.LENGTH_SHORT);

/// Open URL in Instagram for [username] profile
void _launchInstaURL(String username) async {
  String url = username;
  if (!username.contains('.com/')) {
    url = "https://www.instagram.com/$username/";
  }
  await canLaunch(url)
      ? launch(url)
      : Fluttertoast.showToast(
          msg: "Could not open Instagram profile: $username",
          toastLength: Toast.LENGTH_SHORT);
}

/// Open URL in Facebook for [username] profile
void _launchFacebookURL(String username) async {
  String url = username;
  if (!username.contains('.com/')) {
    url = "https://www.facebook.com/$username/";
  }
  await canLaunch(url)
      ? launch(url)
      : Fluttertoast.showToast(
          msg: "Could not open Facebook profile: $username",
          toastLength: Toast.LENGTH_SHORT);
}

/// Open URL in Twitter for [username] profile
void _launchTwitterURL(username) async {
  String url = username;
  if (!username.contains('.com/')) {
    url = "https://www.twitter.com/$username/";
  }
  await canLaunch(url)
      ? launch(url)
      : Fluttertoast.showToast(
          msg: "Could not open Twitter profile: $username",
          toastLength: Toast.LENGTH_SHORT);
}

/// Make a phone call to [phoneNumber]
void _launchPhoneURL(String phoneNumber) async =>
    await canLaunch('tel:$phoneNumber')
        ? launch('tel:$phoneNumber')
        : Fluttertoast.showToast(
            msg: "Could not set up a call for $phoneNumber",
            toastLength: Toast.LENGTH_SHORT);

/// Create email to [email]
void _launchMailURL(String email) async => await canLaunch('mailto:$email')
    ? launch('mailto:$email')
    : Fluttertoast.showToast(
        msg: "Could not open the email app for $email",
        toastLength: Toast.LENGTH_SHORT);

/// Open URL in GoogleMaps for [address]
void _launchAddressURL(address) async =>
    await canLaunch('https://www.google.com/maps/search/?api=1&query=$address')
        ? launch('https://www.google.com/maps/search/?api=1&query=$address')
        : Fluttertoast.showToast(
            msg: "Could not open directions for $address.",
            toastLength: Toast.LENGTH_SHORT);
