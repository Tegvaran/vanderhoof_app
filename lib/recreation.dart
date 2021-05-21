import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'map.dart';
import 'addRecPage.dart';
import 'cards.dart';
import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'addBusinessPage.dart';
import 'addEventPage.dart';
import 'main.dart';
import 'map.dart';

bool hasReadDataFirstTime = false;

// Businesses populated from firebase
List<Recreational> recs = [];

// Businesses after filtering search - this is whats shown in ListView
List<Recreational> filteredRecs = [];

class Recreation extends StatefulWidget {
  Recreation({Key key}) : super(key: key);

  final title = "Recreational";

  @override
  _RecreationPageState createState() => new _RecreationPageState();
}

class _RecreationPageState extends State<Recreation> {
  bool isSearching = false;

  // Async Future variable that holds FireStore's data and functions
  Future future;
  // FireStore reference
  CollectionReference fireStore =
      FirebaseFirestore.instance.collection('recreation');
  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  // GoogleMap markers
  Set<Marker> _markers = HashSet<Marker>();

  /// firebase async method to get data
  Future _getRecs() async {
    if (!hasReadDataFirstTime) {
      print("*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/");
      await fireStore.get().then((QuerySnapshot snap) {
        recs = filteredRecs = [];
        snap.docs.forEach((doc) {
          String phone = _formatPhoneNumber(doc['phone']);
          String website = _formatWebsiteURL(doc['website']);
          Recreational b = Recreational(
            name: doc['name'],
            address: doc['address'],
            location: doc['LatLng'],
            description: doc["description"],
            id: doc['id'],
            phoneNumber: phone,
            email: doc['email'],
            website: website,
          );
          recs.add(b);
        });
      });
      print("_getRecs(): FINISHED READ. Stopped async method to reduce reads.");
      hasReadDataFirstTime = true;
    }

    return recs;
  }

  /// async helper method - formats phone number to "(***) ***-****"
  String _formatPhoneNumber(String phone) {
    if (phone != null && phone.trim() != "" && phone != ".") {
      phone = phone.replaceAll(RegExp("[^0-9]"), '');
      String formatted = phone;
      formatted = "(" +
          phone.substring(0, 3) +
          ") " +
          phone.substring(3, 6) +
          "-" +
          phone.substring(6);
      return formatted;
    } else {
      // phone is empty
      return null;
    }
  }

  /// async helper method - formats website to remove "http(s)://www."
  ///
  /// "http://" is required to correctly launch website URL
  String _formatWebsiteURL(String website) {
    if (website != null && website.trim() != "" && website != ".") {
      String formatted = website.trim();
      if (formatted.startsWith('http')) {
        formatted = formatted.substring(4);
      }
      if (formatted.startsWith('s://')) {
        formatted = formatted.substring(4);
      }
      if (formatted.startsWith('://')) {
        formatted = formatted.substring(3);
      }
      if (formatted.startsWith('www.')) {
        formatted = formatted.substring(4);
      }
      return formatted;
    } else {
      // website is empty
      return null;
    }
  }

  /// this method gets firebase data and populates into list of businesses
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  @override
  void initState() {
    future = _getRecs();
    super.initState();
  }

  /// This method does the logic for search and changes filteredBusinesses to search results
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  void _filterSearchItems(value) {
    setState(() {
      filteredRecs = recs
          .where((businessCard) =>
              businessCard.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
      resetMarkers(_markers, filteredRecs, _scrollController);
    });
  }

  /// Widget build for Admin Menu Hamburger Drawer
  Widget _buildAdminDrawer() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Container(
          height: 100,
          margin: EdgeInsets.all(0),
          padding: EdgeInsets.all(0),
          child: DrawerHeader(
            child: Text("Admin Menu"),
            decoration: BoxDecoration(color: colorPrimary),
          ),
        ),
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text("Add a Business"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBusinessPage(),
                ));
          },
        ),
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text("Add an Event"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventPage(),
                ));
          },
        ),
      ],
    ));
  }

  /// Widget build for AppBar with Search
  Widget _buildSearchAppBar() {
    return AppBar(
      title: !isSearching
          ? Text(widget.title)
          : TextField(
              onChanged: (value) {
                // search logic here
                _filterSearchItems(value);
              },
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  hintText: "Search Businesses",
                  hintStyle: TextStyle(color: Colors.white70)),
            ),
      actions: <Widget>[
        isSearching
            ? IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  _filterSearchItems("");
                  setState(() {
                    this.isSearching = false;
                    filteredRecs = recs;
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    this.isSearching = true;
                  });
                },
              )
      ],
    );
  }

  /// Widget build for Rec ListView
  Widget _buildRecsList() {
    //=================================================
    // Scrolling Listener
    //=================================================

    // listener for the current scroll position
    // if scroll position is not near the very top, set FloatingActionButton visibility to true
    _itemPositionsListener.itemPositions.addListener(() {
      int firstPositionIndex =
          _itemPositionsListener.itemPositions.value.first.index;
      setState(() {
        firstPositionIndex > 5
            ? _isScrollButtonVisible = true
            : _isScrollButtonVisible = false;
      });
    });

    //=================================================
    // Assistance Methods + DismissibleTile Widget
    //=================================================

    void _deleteRec(String recName, int index) {
      {
        // Remove the item from the data source.
        setState(() {
          filteredRecs.removeAt(index);
        });
        FirebaseFirestore.instance
            .collection("recreation")
            .where("name", isEqualTo: recName)
            .get()
            .then((value) {
          value.docs.forEach((element) {
            FirebaseFirestore.instance
                .collection("recreation")
                .doc(element.id)
                .delete()
                .then((value) => print("$recName Deleted"))
                .catchError((error) => print("Failed to delete user: $error"));
          });
        });
        // Then show a snackbar.
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$recName deleted")));
      }
    }

    Widget _dismissibleTile(Widget child, int index) {
      final item = filteredRecs[index];
      return Dismissible(
          // direction: DismissDirection.endToStart,
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(item.name),
          // Provide a function that tells the app
          // what to do after an item has been swiped away.
          confirmDismiss: (direction) async {
            String confirm = 'Confirm Deletion';
            String bodyMsg = 'Are you sure you want to delete:';
            var function = () {
              // _deleteBusiness(item.name, index);
              deleteCardHikeRec(index, this, context, filteredRecs, fireStore,
                  "recreation", item.name);
              Navigator.of(context).pop(true);
            };
            if (direction == DismissDirection.startToEnd) {
              confirm = 'Confirm to go to edit page';
              bodyMsg = "Would you like to edit this item?";
              function = () {
                // Navigator.of(context).pop(false);
                print(item);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddRecPage(rec: item),
                    ));
                //
                //
              };
            }
            return await showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(confirm),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(bodyMsg),
                          Center(
                              child: Text(item.name,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () {
                          function();
                        },
                      ),
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  );
                });
          },
          background: slideRightEditBackground(),
          secondaryBackground: slideLeftDeleteBackground(),
          child: child);
    }

    //=================================================
    // Build Widget for RecreationsList
    //=================================================
    return new Scaffold(
      body: Container(
          child: ScrollablePositionedList.builder(
        padding:
            const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 48),
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: filteredRecs.length,
        itemBuilder: (BuildContext context, int index) {
          //======================
          return _dismissibleTile(
              RecreationalCard(
                  recreational: filteredRecs[index],
                  scrollController: _scrollController,
                  scrollIndex: index,
                  mapMarkers: _markers,
                  listOfFireStoreObjects: filteredRecs),
              index);
        },
      )),
      floatingActionButton: buildScrollToTopButton(_isScrollButtonVisible, _scrollController),
    );
  }

  ///=========================
  /// Final Build Widget
  ///=========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer: Hamburger menu for Admin
      drawer: _buildAdminDrawer(),
      appBar: _buildSearchAppBar(),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                print("FutureBuilder snapshot.connectionState => none");
                return showLoadingScreen();
              case ConnectionState.active:
              case ConnectionState.waiting:
                return showLoadingScreen();
              case ConnectionState.done:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // insert widgets here wrapped in `Expanded` as a child
                    // note: play around with flex int value to adjust vertical spaces between widgets
                    Container(
                        child: Gmap(filteredRecs, _markers, _scrollController)),
                    Expanded(
                        flex: 16,
                        child: filteredRecs.length != 0
                            ? _buildRecsList()
                            : Container(
                                child: Center(
                                child: Text("No results found",
                                    style: titleTextStyle),
                              ))),
                  ],
                );
              default:
                return Text("Default");
            }
          },
        ),
      ),
    );
  }
}
