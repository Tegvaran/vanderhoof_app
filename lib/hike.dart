import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vanderhoof_app/cards.dart';

import 'fireStoreObjects.dart';
import 'map.dart';

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

  Future _getHikes() async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('trails');

    await fireStore.get().then((QuerySnapshot snap) {
      snap.docs.forEach((doc) {
        HikeTrail h = HikeTrail(
            doc['name'],
            doc['address'],
            doc['location'],
            doc['distance'],
            doc['difficulty'],
            doc['time'],
            doc['wheelchair'],
            doc['description']);
        hikes.add(h);
      });
    });
    return hikes;
  }

  @override
  void initState() {
    // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart

    _getHikes().then((data) {
      setState(() {
        hikes = filteredHikes = data;
      });
    });
    super.initState();
  }

  // This method does the logic for search
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  void _filterSearchItems(value) {
    setState(() {
      filteredHikes = hikes
          .where((hikeCard) =>
              hikeCard.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });

    resetMarkers(_markers, filteredHikes);
  }

  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    //run marker adapter
    setState(() {
      for (int i = 0; i < hikes.length; i++) {
        _markers.add(
          Marker(
              markerId: MarkerId(i.toString()),
              position: hikes[i].location,
              infoWindow: InfoWindow(
                title: hikes[i].name,
                snippet: hikes[i].description,
              )),
        );
      }
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(54.0117956, -124.0177679),
    zoom: 13,
  );
  var maptype = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      ),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here
            Expanded(
              flex: 2,
              child: GoogleMap(
                mapType: maptype,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: _onMapCreated,
                markers: _markers,
              ),
            ),
            Expanded(flex: 4, child: _hikeTrailListBuild()),
          ],
        ),
      ),
    );
  }

  Widget _hikeTrailListBuild() {
    return new Container(
        child: ListView.builder(
            itemCount: filteredHikes.length,
            itemBuilder: (BuildContext context, int index) {
              return HikeCard(filteredHikes[index]);
            }));
  }
}
