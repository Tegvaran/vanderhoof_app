import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'addHikePage.dart';
import 'addRecPage.dart';
import 'addBusinessPage.dart';
import 'addEventPage.dart';
import 'cards.dart';
import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'main.dart';
import 'map.dart';
import 'scraper.dart';
import 'package:vanderhoof_app/commonFunction.dart';
// import 'main.dart';
import 'data.dart';

bool businessFirstTime = true;
// Businesses populated from firebase
List<Business> businesses = [];

// Businesses after filtering search - this is whats shown in ListView
List<Business> filteredBusinesses = [];

class BusinessState extends StatefulWidget {
  BusinessState({Key key}) : super(key: key);

  final title = "Businesses";

  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

List<Widget> chips2;

class _BusinessPageState extends State<BusinessState> {
  bool isSearching = false;

  // Async Future variable that holds FireStore's data and functions
  Future future;
  // FireStore reference
  CollectionReference fireStore =
      FirebaseFirestore.instance.collection('teg_businesses');
  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  // GoogleMap markers
  Set<Marker> _markers = HashSet<Marker>();

  // Choice Chips for Category
  int _selectedIndex;

  /// firebase async method to get data
  Future _getBusinesses() async {
    print("tst---------tst------------------tst-------tst");
    if (businessFirstTime) {
      // if(true) {
      print("*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/");
      // helper method - parses phone string to correct format
      String _parsePhoneNumber(String phone) {
        String parsedPhone = "";
        if (phone != null && phone.trim() != "" && phone != ".") {
          parsedPhone = "(" +
              phone.substring(0, 3) +
              ") " +
              phone.substring(3, 6) +
              "-" +
              phone.substring(6);
        }
        return parsedPhone;
      }

      await fireStore.get().then((QuerySnapshot snap) {
        businesses = filteredBusinesses = [];
        snap.docs.forEach((doc) {
          String phone = _parsePhoneNumber(doc['phone']);
          Business b = Business(
              name: doc['name'],
              address: doc['address'],
              location: doc['LatLng'],
              description: doc["description"],
              phoneNumber: phone,
              email: doc['email'],
              socialMedia: doc['socialMedia'],
              website: doc['website'],
              imgURL: doc['imgURL'],
              category: doc['category'],
              id: doc['id']);
          businesses.add(b);
        });
      });
      businessFirstTime = false;
    }
    businesses.sort((a, b) => (a.name).compareTo(b.name));
    return businesses;
  }

  /// this method gets firebase data and populates into list of businesses
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  @override
  void initState() {
    future = _getBusinesses();
    super.initState();
  }

  /// This method does the logic for search and changes filteredBusinesses to search results
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  void _filterSearchItems(value) {
    setState(() {
      filteredBusinesses = businesses
          .where((businessCard) =>
              businessCard.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
      resetMarkers(_markers, filteredBusinesses, _scrollController);
    });
  }

  void scrollToIndex(int index) {
    _scrollController.scrollTo(
      index: index,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
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
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text("Add a Hike/Trail"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddHikePage(),
                ));
          },
        ),
        ListTile(
          leading: Icon(Icons.add_circle_outline),
          title: Text("Add a Rec"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRecPage(),
                ));
          },
        ),
        ListTile(
          leading: Icon(Icons.ac_unit),
          title: Text("Test Scraper"),
          onTap: () => scrap(true),
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
                    filteredBusinesses = businesses;
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

  /// Widget build for Businesses ListView
  Widget _buildBusinessesList() {
    //=================================================
    // Scrolling Listener + ScrollToTop Button
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

    Widget _buildScrollToTopButton() {
      return _isScrollButtonVisible
          ? FloatingActionButton(
              // scroll to top of the list
              child: FaIcon(FontAwesomeIcons.angleUp),
              shape: RoundedRectangleBorder(),
              foregroundColor: colorPrimary,
              mini: true,
              onPressed: () {
                _scrollController.scrollTo(
                  index: 0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              })
          : null;
    }

    //=================================================
    // Assistance Methods + DismissibleTile Widget
    //=================================================

    // void _deleteBusiness(String businessName, String docID, int index) {
    //   {
    //     // Remove the item from the data source.
    //     setState(() {
    //       filteredBusinesses.removeAt(index);
    //     });
    //     // Delete from fireStore
    //     // String docID = businessName.replaceAll('/', '|');
    //     fireStore
    //         .doc(docID)
    //         .delete()
    //         .then((value) => print("$docID Deleted"))
    //         .catchError((error) => print("Failed to delete user: $error"));
    //
    //     // Then show a snackbar.
    //     ScaffoldMessenger.of(context)
    //         .showSnackBar(SnackBar(content: Text("$businessName deleted")));
    //   }
    // }

    Widget _dismissibleTile(Widget child, int index) {
      final item = filteredBusinesses[index];
      return Dismissible(
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(item.name),
          // Provide a function that tells the app
          // what to do after an item has been swiped away.
          confirmDismiss: (direction) async {
            String confirm = 'Confirm Deletion';
            String bodyMsg = 'Are you sure you want to delete:';
            var function = () {
              deleteCard(item.name, item.id, index, fireStore).then((v) {
                // Remove the item from the data source.
                setState(() {
                  filteredBusinesses.removeAt(index);
                });
                // Then show a snackbar.
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${item.name} deleted")));

                Navigator.of(context).pop(true);
              });
            };
            if (direction == DismissDirection.startToEnd) {
              confirm = 'Confirm to go to edit page';
              bodyMsg = "Would you like to edit this item?";
              function = () {
                // Navigator.of(context).pop(false);
                Navigator.pop(context);
                Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBusinessPage(business: item),
                        ))
                    //     .then((v) => setState(() {
                    //       // _getEvents();
                    //     }
                    //     )
                    // )
                    ;
                //
                //
              };
            }
            print(item.name);
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
                          // _deleteBusiness(item.name, item.id, index);
                          // Navigator.of(context).pop(true);
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
    // Build Widget for BusinessesList
    //=================================================
    return new Scaffold(
      body: Container(
          child: ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: filteredBusinesses.length,
        itemBuilder: (BuildContext context, int index) {
          //======================
          return _dismissibleTile(
              BusinessCard(filteredBusinesses[index], _scrollController, index,
                  _markers, filteredBusinesses),
              index);
        },
      )),
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  /// Widget build for ChoiceChip for filtering businesses by category
  Widget _buildChips() {
    List<Widget> chips = [];

    void _filterSearchItemsByCategory(value) {
      setState(() {
        filteredBusinesses = businesses.where((businessCard) {
          if (businessCard.category != null &&
              businessCard.category.length != 0) {
            return (businessCard.category).contains(value);
          } else {
            return false;
          }
        }).toList();
        resetMarkers(_markers, filteredBusinesses, _scrollController);
      });
    }

    // get a ChoiceChip widget for each category
    for (int i = 0; i < categoryOptions.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,
        label: Text(categoryOptions[i], style: TextStyle(color: Colors.black)),
        elevation: 3,
        pressElevation: 5,
        shadowColor: colorPrimary,
        selectedColor: colorAccent,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
              _filterSearchItemsByCategory(categoryOptions[i]);
            } else {
              _selectedIndex = null;
              filteredBusinesses = businesses;
              resetMarkers(_markers, filteredBusinesses, _scrollController);
            }
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), child: choiceChip));
    }

    chips2 = chips;

    return ListView(
      // This next line does the trick.
      scrollDirection: Axis.horizontal,
      children: chips,
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
                    Expanded(
                      flex: 9,
                      child:
                          Gmap(filteredBusinesses, _markers, _scrollController),
                    ),
                    Expanded(flex: 2, child: _buildChips()),
                    Expanded(
                        flex: 14,
                        child: filteredBusinesses.length != 0
                            ? _buildBusinessesList()
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
