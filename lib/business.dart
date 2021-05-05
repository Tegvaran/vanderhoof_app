import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vanderhoof_app/main.dart';

import 'addBusinessPage.dart';
import 'package:web_scraper/web_scraper.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

// Business object
class BusinessCard {
  final String name;
  final String address;
  final String description;
  BusinessCard(this.name, this.address, this.description);
}

class Business extends StatefulWidget {
  Business({Key key}) : super(key: key);

  final title = "Businesses";

  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<Business> {
  // list of businesses populated from firebase
  List<BusinessCard> businesses = [];

  // list of businesses with search filters - this is whats shown in ListView
  List<BusinessCard> filteredBusinesses = [];
  bool isSearching = false;

  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  // firebase async get data
  Future _getBusinesses() async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('businesses');

    await fireStore.get().then((QuerySnapshot snap) {
      businesses = filteredBusinesses = [];
      snap.docs.forEach((doc) {
        BusinessCard b =
            BusinessCard(doc['name'], doc['address'], doc["description"]);
        businesses.add(b);
      });
    });
    return businesses;
  }

  // this method gets firebase data and populates into list of businesses
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  @override
  void initState() {
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

  // old build for ListView of Businesses
  Widget _businessesListBuild_old() {
    return new Container(
        child: ListView.builder(
      itemCount: filteredBusinesses.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpansionTile(
          // leading: CircleAvatar(
          //   backgroundImage:
          //       NetworkImage(snapshot.data[index].picture),
          // ),
          title: _nullText(filteredBusinesses[index].name),
          subtitle: _nullText(filteredBusinesses[index].address),
          children: <Widget>[_nullText(filteredBusinesses[index].description)],
        );
      },
    ));
  }

  // new build for ListView of Businesses
  // uses a scroll controller to scroll expandedTiles to the top of the view
  // this build also has a floating action button that scrolls to the top of the list
  Widget _businessesListBuild() {
    double scrollAlignment = 0.1;

    // listener for the current scroll position
    // if scroll position is not near the very top,
    // set FloatingActionButton visibility to true
    _itemPositionsListener.itemPositions.addListener(() {
      int firstPositionIndex =
          _itemPositionsListener.itemPositions.value.first.index;

      setState(() {
        firstPositionIndex > 5
            ? _isScrollButtonVisible = true
            : _isScrollButtonVisible = false;
      });
    });

    return new Scaffold(
      body: Container(
        child: ScrollablePositionedList.builder(
          itemScrollController: _scrollController,
          itemPositionsListener: _itemPositionsListener,
          itemCount: filteredBusinesses.length,
          itemBuilder: (BuildContext context, int index) {
            return ExpansionTile(
              // leading: CircleAvatar(
              //   backgroundImage:
              //       NetworkImage(snapshot.data[index].picture),
              // ),
              onExpansionChanged: (_isExpanded) {
                if (_isExpanded) {
                  // check if Expanded
                  // let ExpansionTile expand, then scroll Tile to top of the list
                  Future.delayed(Duration(milliseconds: 250)).then((value) {
                    _scrollController.scrollTo(
                      index: index,
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment: scrollAlignment,
                    );
                  });
                }
              },
              title: _nullText(filteredBusinesses[index].name),
              subtitle: _nullText(filteredBusinesses[index].address),
              children: <Widget>[
                _nullText(filteredBusinesses[index].description)
              ],
            );
          },
        ),
      ),
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
          : null, // hide button if already at top of the list
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here as a child widget wrapped in `Expanded` class
            // note: play around with flex int value to change how much vertical space each widget occupies
            Expanded(flex: 1, child: Text("first child - future map widget")),
            Expanded(flex: 11, child: _businessesListBuild()),
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
          };
          all.add(b);
        }

        print("-----------end");
        print(all.length);

        CollectionReference business =
            FirebaseFirestore.instance.collection('testbusiness');
        Future<void> addBusiness(Map<String, dynamic> businessInfo) {
          return business
              .add(businessInfo)
              .then((value) => {
                    print("Business Added:  ${value.id}"),
                    business.doc(value.id).update({"id": value.id})
                  })
              .catchError((error) => print("Failed to add Business: $error"));
        }

        for (int i = 0; i < all.length; i++) {
          addBusiness(Map<String, dynamic>.from(all[i]));
        }
      }
    }
  }
}
