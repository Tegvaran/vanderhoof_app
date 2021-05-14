import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'cards.dart';
import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'main.dart';
import 'map.dart';

bool hikeFirstTime = true;
List<HikeTrail> hikes = [];
List<HikeTrail> filteredHikes = [];

class Hike extends StatefulWidget {
  Hike({Key key}) : super(key: key);

  final title = "Hiking Trails";

  @override
  _HikePageState createState() => new _HikePageState();
}

class _HikePageState extends State<Hike> {
  bool isSearching = false;
  Future future;
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;
  Set<Marker> _markers = HashSet<Marker>();

  /// firebase async method to get data
  Future _getHikes() async {
    if (hikeFirstTime) {
      print("*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*");
      CollectionReference fireStore =
          FirebaseFirestore.instance.collection('trails');

      await fireStore.get().then((QuerySnapshot snap) {
        hikes = filteredHikes = [];
        snap.docs.forEach((doc) {
          HikeTrail h = HikeTrail(
            name: doc['name'],
            address: doc['address'],
            location: doc['location'],
            description: doc['description'],
            distance: doc['distance'],
            rating: doc['difficulty'],
            time: doc['time'],
            wheelchair: doc['wheelchair'],
            pointsOfInterest: doc['pointsOfInterest'],
            imgURL: doc['imgURL'],
          );
          hikes.add(h);
          filteredHikes.add(h);
        });
      });
      hikeFirstTime = false;
    }
    return hikes;
  }

  /// this method gets firebase data and populates into list of hikes
  @override
  void initState() {
    future = _getHikes();
    super.initState();
  }

  /// This method does the logic for search and changes filteredHikes to search results
  void _filterSearchItems(value) {
    setState(() {
      filteredHikes = hikes
          .where((hikeCard) =>
              hikeCard.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });

    resetMarkers(_markers, filteredHikes, _scrollController);
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
                  hintText: "Search Hiking Trails",
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
                    filteredHikes = hikes;
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

  /// Widget build for Hikes ListView
  Widget _buildHikesList() {
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
    // Build Widget for HikesList
    //=================================================
    return new Scaffold(
      body: Container(
          child: ScrollablePositionedList.builder(
              itemScrollController: _scrollController,
              itemCount: filteredHikes.length,
              itemBuilder: (BuildContext context, int index) {
                return HikeCard(filteredHikes[index], _scrollController, index,
                    _markers, filteredHikes);
              })),
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  ///=========================
  /// Final Build Widget
  ///=========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Expanded(
                      flex: 9,
                      child: Gmap(filteredHikes, _markers, _scrollController),
                    ),
                    Expanded(
                        flex: 16,
                        child: filteredHikes.length != 0
                            ? _buildHikesList()
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
