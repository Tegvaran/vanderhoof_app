import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vanderhoof_app/main.dart';

import 'addBusinessPage.dart';
import 'package:web_scraper/web_scraper.dart';

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
  List<BusinessCard> businesses = [];
  List<BusinessCard> filteredBusinesses = [];
  bool isSearching = false;

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
            onTap: () => scrap(true),
          ),
          ListTile(
            leading: Icon(Icons.ac_unit),
            title: Text("Test Scraper2"),
            onTap: () => scrap2(true),
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
            // insert widgets here wrapped in `Expanded` as a child
            // note: play around with flex int value to adjust vertical spaces between widgets
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
            FirebaseFirestore.instance.collection('testbus');

        Future<void> addBusiness(Map<String, dynamic> businessInfo, int docID) {
          return business
              .doc("$docID")
              .set(businessInfo)
              .then((value) => {
                    print("Business Added:  ${docID}"),
                  })
              .catchError((error) => print("Failed to add Business: $error"));
        }

        for (int i = 0; i < all.length - 1; i++) {
          //need to check for null name
          // if (all[i]['name'] == null) {
          //   print("null at ${i},   ${all[i]}");
          // }
          // all[i]['index'] = i;
          // print(all[i]);
          addBusiness(Map<String, dynamic>.from(all[i]), i);
        }
      }
    }
  }

  //==================
  //===================
  //===================
  Future<void> scrap2(bool activate) async {
    if (!activate) {
      print("----------scraping deactivated");
    } else {
      print("----------------scrap------------");

      //==================================
      // Assistance Methods
      //==================================

      CollectionReference business =
          FirebaseFirestore.instance.collection('businesses');
      Future<void> addBusiness(
          Map<String, dynamic> businessInfo, String docID) {
        if (docID.contains("/")) {
          docID = docID.replaceAll('/', '|');
        }
        return business
            .doc("$docID")
            .set(businessInfo)
            .then((value) => {
                  print("Business Added:  ${docID}"),
                })
            .catchError((error) => print("Failed to add Business: $error"));
      }

      String _check(List element) {
        if (element.isNotEmpty) {
          return element[0];
        } else {
          return null;
        }
      }

      String _checkElement(List element, String tag) {
        if (element.isNotEmpty) {
          return element[0]['attributes'][tag];
        } else {
          return null;
        }
      }

      String _checkPhone(List element) {
        if (element.isNotEmpty) {
          String s = element[0].replaceAll(RegExp(r'[-.() ]'), '');
          s = s.substring(0, 10) + "\n" + s.substring(10);
          return s;
        } else {
          return null;
        }
      }
      //==================================
      // End of Assistance Methods
      //==================================

      int count = 0;
      final webScraper = WebScraper('https://www.vanderhoofchamber.com/');

      if (await webScraper.loadWebPage('/membership/business-directory')) {
        var elements =
            webScraper.getElement('#businesslist > div >h3>a', ['href']);
        elements.forEach((element) async {
          String page = element['attributes']['href'].substring(33);
          if (await webScraper.loadWebPage(page)) {
            var name = webScraper.getElementTitle('h1.entry-title');
            var phone = webScraper.getElementTitle('p.phone');
            var desc = webScraper.getElementTitle('#business > p');
            var address = webScraper.getElementTitle('p.address');
            var email = webScraper.getElementTitle('p.email > a');
            var web = webScraper.getElement('p.website>a', ['href']);
            var img = webScraper.getElement('div.entry-content >img', ['src']);

            String n = _check(name);
            String p = _checkPhone(phone);
            String d = _check(desc);
            String a = _check(address);
            String e = _check(email);
            String w = _checkElement(web, 'href');
            String i = _checkElement(img, 'src');

            addBusiness({
              'name': n,
              'address': a,
              'phone': p,
              'email': e,
              'website': w,
              'description': d,
              'imgURL': i,
              'indexRef': count,
            }, n);
            count++;
          }
        });
      }
    }
  }
}
