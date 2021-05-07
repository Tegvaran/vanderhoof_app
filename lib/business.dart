import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vanderhoof_app/map.dart';
import 'cards.dart';
import 'fireStoreObjects.dart';
import 'addBusinessPage.dart';
import 'addEventPage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'main.dart';

class BusinessState extends StatefulWidget {
  BusinessState({Key key}) : super(key: key);

  final title = "Businesses";

  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<BusinessState> {
  // Businesses populated from firebase
  List<Business> businesses = [];

  // Businesses after filtering search - this is whats shown in ListView
  List<Business> filteredBusinesses = [];
  bool isSearching = false;

  // Async Future variable that holds FireStore's data and functions
  Future future;
  // FireStore reference
  CollectionReference fireStore =
      FirebaseFirestore.instance.collection('businesses');
  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  // GoogleMap markers
  Set<Marker> _markers = HashSet<Marker>();

  // Choice Chips for Category
  int _selectedIndex;
  List<String> _options = [
    'Accommodation',
    'Agriculture & Animal',
    'Automotive',
    'Business Services',
    'Construction',
    'Employment Services & Education',
    'Entertainment',
    'Environmental',
    'Financial Services',
    'Food & Dining',
    'Forestry Related',
    'Government Services',
    'Health Services',
    'Industry',
    'Media & Design',
    'Non-Profit Groups & Clubs',
    'Professional Services',
    'Real Estate',
    'Restaurant',
    'Retail Sales',
    'Technical',
    'Trades',
  ];

  /// firebase async method to get data
  Future _getBusinesses() async {
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
            doc['name'],
            doc['address'],
            doc['LatLng'],
            doc["description"],
            phone,
            doc['email'],
            doc['socialMedia'],
            doc['website'],
            doc['imgURL'],
            doc['category']);
        businesses.add(b);
      });
    });
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
      resetMarkers(_markers, filteredBusinesses);
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

    void _deleteBusiness(String businessName, int index) {
      {
        // Remove the item from the data source.
        setState(() {
          filteredBusinesses.removeAt(index);
        });
        // Delete from fireStore
        String docID = businessName.replaceAll('/', '|');
        fireStore
            .doc(docID)
            .delete()
            .then((value) => print("$businessName Deleted"))
            .catchError((error) => print("Failed to delete user: $error"));

        // Then show a snackbar.
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$businessName deleted")));
      }
    }

    Widget _dismissibleTile(Widget child, int index) {
      final item = filteredBusinesses[index];
      return Dismissible(
          direction: DismissDirection.endToStart,
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(item.name),
          // Provide a function that tells the app
          // what to do after an item has been swiped away.
          confirmDismiss: (direction) async {
            return await showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Deletion'),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text('Are you sure you want to delete:'),
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
                          _deleteBusiness(item.name, index);
                          Navigator.of(context).pop(true);
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
          background: Container(color: Colors.red),
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
              BusinessCard(filteredBusinesses[index], _scrollController, index),
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
          if (businessCard.category != null) {
            return businessCard.category
                .toLowerCase()
                .contains(value.toLowerCase());
          } else {
            return false;
          }
        }).toList();
        resetMarkers(_markers, filteredBusinesses);
      });
    }

    // get a ChoiceChip widget for each category
    for (int i = 0; i < _options.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        selected: _selectedIndex == i,
        label: Text(_options[i], style: TextStyle(color: Colors.black)),
        elevation: 5,
        pressElevation: 5,
        shadowColor: colorPrimary,
        selectedColor: colorAccent,
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              _selectedIndex = i;
              _filterSearchItemsByCategory(_options[i]);
            } else {
              _selectedIndex = null;
              filteredBusinesses = businesses;
              resetMarkers(_markers, filteredBusinesses);
            }
          });
        },
      );

      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 10), child: choiceChip));
    }

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
                return Text('non');
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Text('Active or waiting');
              case ConnectionState.done:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // insert widgets here wrapped in `Expanded` as a child
                    // note: play around with flex int value to adjust vertical spaces between widgets
                    Expanded(
                      flex: 4,
                      child: Map(filteredBusinesses, _markers),
                    ),
                    Expanded(flex: 1, child: _buildChips()),
                    Expanded(flex: 8, child: _buildBusinessesList()),
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
