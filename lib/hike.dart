import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vanderhoof_app/cards.dart';

import 'fireStoreObjects.dart';
import 'package:vanderhoof_app/map.dart';

class Hike extends StatefulWidget {
  Hike({Key key}) : super(key: key);

  final title = "Hiking Trails";

  @override
  _HikePageState createState() => new _HikePageState();
}

class _HikePageState extends State<Hike> {
  List<HikeTrail> hikes = [];
  List<HikeTrail> filteredHikes = [];
  bool isSearching = false;
  Future future;
  ItemScrollController _scrollController = ItemScrollController();
  Set<Marker> _markers = HashSet<Marker>();

  /// firebase async method to get data
  Future _getHikes() async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('trails');

    await fireStore.get().then((QuerySnapshot snap) {
      hikes = filteredHikes = [];
      snap.docs.forEach((doc) {
        HikeTrail h = HikeTrail(
          doc['name'],
          doc['address'],
          doc['location'],
          doc['distance'],
          doc['difficulty'],
          doc['time'],
          doc['wheelchair'],
          doc['description'],
          doc['pointsOfInterest'],
          doc['imgURL'],
        );
        hikes.add(h);
      });
    });
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

    resetMarkers(_markers, filteredHikes);
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
    return new Scaffold(
        body: Container(
            child: ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                itemCount: filteredHikes.length,
                itemBuilder: (BuildContext context, int index) {
                  return HikeCard(
                      filteredHikes[index], _scrollController, index);
                })));
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
                      flex: 2,
                      child: Map(filteredHikes, _markers),
                    ),
                    Expanded(flex: 4, child: _buildHikesList()),
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
