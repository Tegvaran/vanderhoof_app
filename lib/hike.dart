import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:vanderhoof_app/cards.dart';

class Hike extends StatefulWidget {
  Hike({Key key}) : super(key: key);

  final title = "Hiking Trails";

  @override
  _HikePageState createState() => new _HikePageState();
}

class _HikePageState extends State<Hike> {
  List<HikeCard> hikes = [];
  List<HikeCard> filteredHikes = [];
  bool isSearching = false;

  Future _getHikes() async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('trails');

    await fireStore.get().then((QuerySnapshot snap) {
      snap.docs.forEach((doc) {
        HikeCard h = HikeCard(doc['name'], doc['distance'], doc['difficulty'],
            doc['time'], doc['wheelchair']);
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here
            Expanded(
                flex: 1,
                child: Text("Hiking page - first child Future map widget")),
            Expanded(flex: 11, child: _hikeTrailListBuild()),
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
              return HikeCard(
                  filteredHikes[index].name,
                  filteredHikes[index].distance,
                  filteredHikes[index].rating,
                  filteredHikes[index].time,
                  filteredHikes[index].wheelchair);
            }));
  }
}
