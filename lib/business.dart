import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Business extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future _getBusinesses() async {
    List<BusinessCard> businesses = [];
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('businesses');

    await fireStore.get().then((QuerySnapshot snap) {
      snap.docs.forEach((doc) {
        BusinessCard b =
            BusinessCard(doc['name'], doc['address'], doc["description"]);
        businesses.add(b);
      });
    });

    return businesses;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(title: Text("Category")),
      body: Container(
        child: FutureBuilder(
          future: _getBusinesses(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print(snapshot.data);
            if (snapshot.data == null) {
              return Container(child: Center(child: Text("Loading...")));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    // leading: CircleAvatar(
                    //   backgroundImage:
                    //       NetworkImage(snapshot.data[index].picture),
                    // ),
                    title: Text(snapshot.data[index].name),
                    subtitle: Text(snapshot.data[index].address),
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  DetailPage(snapshot.data[index])));
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final BusinessCard b;

  DetailPage(this.b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Description"),
      ),
      body: Text(b.description),
    );
  }
}

class BusinessCard {
  final String name;
  final String address;
  final String description;

  BusinessCard(this.name, this.address, this.description);
}
