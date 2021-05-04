import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cards.dart';
import 'fireStoreObjects.dart';

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
        FirebaseFirestore.instance.collection('businesses');

    await fireStore.get().then((QuerySnapshot snap) {
      businesses = filteredBusinesses = [];
      snap.docs.forEach((doc) {
        Business b = Business(doc['name'], doc['address'], doc['LatLng'],
            doc["description"], doc['phone'], doc['email'], doc['socialMedia'], doc['website']);
        businesses.add(b);
      });
    });
    return businesses;
  }

  @override
  void initState() {
    // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
    // this method gets firebase data and populates into list of businesses
    _getBusinesses().then((data) {
      setState(() {
        businesses = filteredBusinesses = data;
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here wrapped in `Expanded` as a child
            // note: play around with flex int value to adjust vertical spaces between widgets
            Expanded(flex: 1, child: Text("first child - future map widget")),
            Expanded(flex: 11, child: _businessesListBuild()),
          ],
        ),
      ),
    );
  }
}
