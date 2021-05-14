import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vanderhoof_app/cards.dart';

import 'addHikePage.dart';
import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'package:vanderhoof_app/map.dart';

class HikeTrail extends StatefulWidget {
  HikeTrail({Key key}) : super(key: key);

  final title = "Hiking Trails";

  @override
  _HikePageState createState() => new _HikePageState();
}

class _HikePageState extends State<HikeTrail> {
  List<Hike> hikes = [];
  List<Hike> filteredHikes = [];
  bool isSearching = false;
  Future future;
  ItemScrollController _scrollController = ItemScrollController();
  Set<Marker> _markers = HashSet<Marker>();
  CollectionReference fireStore =
      FirebaseFirestore.instance.collection('trails');

  /// firebase async method to get data
  Future _getHikes() async {
    await fireStore.get().then((QuerySnapshot snap) {
      hikes = filteredHikes = [];
      snap.docs.forEach((doc) {
        Hike h = Hike(
          doc['name'],
          doc['address'],
          doc['location'],
          doc['id'],
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

  Widget _dismissibleTile(Widget child, int index) {
    final item = filteredHikes[index];
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
            deleteCard(item.name, item.id, index, this, context, filteredHikes,
                fireStore);
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
                    builder: (context) => AddHikePage(hike: item),
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
                                style: TextStyle(fontWeight: FontWeight.bold))),
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

  /// Widget build for Hikes ListView
  Widget _buildHikesList() {
    return new Scaffold(
        body: Container(
            child: ScrollablePositionedList.builder(
                itemScrollController: _scrollController,
                itemCount: filteredHikes.length,
                itemBuilder: (BuildContext context, int index) {
                  return _dismissibleTile(
                      HikeCard(filteredHikes[index], _scrollController, index),
                      index);
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
                      child: Gmap(filteredHikes, _markers),
                    ),
                    Expanded(
                        flex: 4,
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
