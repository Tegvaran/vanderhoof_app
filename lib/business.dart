import 'dart:collection';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vanderhoof_app/map.dart';
import 'cards.dart';
import 'fireStoreObjects.dart';
import 'addBusinessPage.dart';
import 'package:web_scraper/web_scraper.dart';

import 'main.dart';

class BusinessState extends StatefulWidget {
  BusinessState({Key key}) : super(key: key);

  final title = "Businesses";

  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<BusinessState> {
  List<Business> businesses = [];
  List<Business> filteredBusinesses = [];
  bool isSearching = false;

  // firebase async get data
  Future _getBusinesses() async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('debug_businesses');

    await fireStore.get().then((QuerySnapshot snap) {
      businesses = filteredBusinesses = [];
      snap.docs.forEach((doc) {
        Business b = Business(
            doc['name'],
            doc['address'],
            doc['LatLng'],
            doc["description"],
            doc['phone'],
            doc['email'],
            doc['socialMedia'],
            doc['website'],
            doc['imgURL']);
        businesses.add(b);
      });
    });
    return businesses;
  }

  @override
  void initState() {
    // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
    // this method gets firebase data and populates into list of businesses
    // also loads in the map markers
    _getBusinesses().then((data) {
      setState(() {
        businesses = filteredBusinesses = data;
        resetMarkers(_markers, filteredBusinesses);
      });
    });
    super.initState();
  }

  // This method does the logic for search and changes filteredBusinesses to search results
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

  Widget _businessesListBuild() {
    return new Container(
        child: ListView.builder(
      itemCount: filteredBusinesses.length,
      itemBuilder: (BuildContext context, int index) {
        return BusinessCard(filteredBusinesses[index]);
      },
    ));
  }

  Set<Marker> _markers = HashSet<Marker>();
  GoogleMapController _mapController;
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    //run marker adapter
    setState(() {
      for (int i = 0; i < filteredBusinesses.length; i++) {
        _markers.add(
          Marker(
              markerId: MarkerId(i.toString()),
              position: filteredBusinesses[i].location,
              infoWindow: InfoWindow(
                title: filteredBusinesses[i].name,
                snippet: filteredBusinesses[i].description,
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
      // Drawer: Hamberguer menu for Admin
      drawer: Drawer(
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
            leading: Icon(Icons.ac_unit),
            title: Text("Test Scraper"),
            onTap: () => scrap(false),
          )
        ],
      )),
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
      ),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here wrapped in `Expanded` as a child
            // note: play around with flex int value to adjust vertical spaces between widgets
            Expanded(
              flex: 2,
              child: GoogleMap(
                mapType: maptype,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: _onMapCreated,
                markers: _markers,
              ),
            ),
            Expanded(flex: 4, child: _businessesListBuild()),
          ],
        ),
      ),
    );
  }

  Widget _nullText(String str) {
    if (str != null) {
      return Text(str);
    } else {
      return Text("empty");
    }
  }

  Future<void> scrap(bool activate) async {
    if (!activate) {
      print("----------scraping deactivated");
    } else {
      print("----------------scrap------------");

      final webScraper = WebScraper('https://www.vanderhoofchamber.com/');

      if (await webScraper.loadWebPage('/membership/business-directory')) {
        List<String> elements =
            webScraper.getElementTitle('#businesslist > div');

        var n = webScraper.getElementTitle('#businesslist > div > h3').iterator;
        var p = webScraper
            .getElementTitle('#businesslist > div > p.phone')
            .iterator;
        var a = webScraper
            .getElementTitle('#businesslist > div > p.address')
            .iterator;
        var d = webScraper
            .getElementTitle('#businesslist > div > div.description')
            .iterator;
        var e = webScraper
            .getElementTitle('#businesslist > div > p.email')
            .iterator;
        var w = webScraper
            .getElementTitle('#businesslist > div > p.website')
            .iterator;

        n.moveNext();
        p.moveNext();
        a.moveNext();
        d.moveNext();
        e.moveNext();
        w.moveNext();
        List<Map> all = [];

        String check(String value, var iterator) {
          try {
            if (iterator.current != null && value.contains(iterator.current)) {
              iterator.moveNext();
              return iterator.current;
            } else {
              return null;
            }
          } catch (e) {
            print("error catch---");
            print(value);
            print(iterator.current);
            print("error end");
            print(e);
          }
        }

        for (int i = 0; i < elements.length; i++) {
          Map b = {
            'name': check(elements[i], n),
            'address': check(elements[i], a),
            'phone': check(elements[i], p),
            'email': check(elements[i], e),
            'website': check(elements[i], w),
            'description': check(elements[i], d),
          } as Map;
          all.add(b);
        }

        print("-----------end");
        print(all.length);

        // TODO Dont know what is wrong here, plzz help Jack the saviour!
        //       CollectionReference business =
        //           FirebaseFirestore.instance.collection('testbusiness');
        //       Future<void> addBusiness(Map<String, dynamic> businessInfo) {
        //         return business
        //             .add(businessInfo)
        //             .then((value) => {
        //                   print("Business Added:  ${value.id}"),
        //                   business.doc(value.id).update({"id": value.id})
        //                 })
        //             .catchError((error) => print("Failed to add Business: $error"));
        //       }
        //
        //       for (int i = 0; i < all.length; i++) {
        //         addBusiness(Map<String, dynamic>.from(all[i]));
        //       }
      }
    }
  }
}
