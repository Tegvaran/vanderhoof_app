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

  // Async Future variable that hold the connected database's data and functions
  Future future;

  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  // GoogleMap markers
  Set<Marker> _markers = HashSet<Marker>();

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
    // this method gets firebase data and populates into list of businesses
    // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
    future = _getBusinesses();
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
      //resetMarkers(_markers, filteredBusinesses);
    });
  }

  Widget _businessesListBuild() {
    // listener for the current scroll position
    // if scroll position is not near the very top, set FloatingActionButton visibility to true
    _itemPositionsListener.itemPositions.addListener(() {
      int firstPositionIndex =
          _itemPositionsListener.itemPositions.value.first.index;
      setState(() {
        firstPositionIndex >
                0 //todo: when populating real businesses from firestore, replace 0 back to 5
            ? _isScrollButtonVisible = true
            : _isScrollButtonVisible = false;
      });
    });

    // build widget for businesses ListView + FloatingActionButton for jumpTo index 0
    return new Scaffold(
      body: Container(
          child: ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: filteredBusinesses.length,
        itemBuilder: (BuildContext context, int index) {
          return BusinessCard(
              filteredBusinesses[index], _scrollController, index);
        },
      )),
      floatingActionButton: _isScrollButtonVisible
          ? FloatingActionButton(
              // scroll to top of the list
              child: Icon(Icons.arrow_upward),
              mini: true,
              onPressed: () {
                _scrollController.scrollTo(
                  index: 0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              })
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer: Hamburger menu for Admin
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
                      child: GMap(filteredBusinesses, _markers),
                    ),
                    Expanded(flex: 4, child: _businessesListBuild()),
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
