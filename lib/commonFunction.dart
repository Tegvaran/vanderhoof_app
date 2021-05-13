import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

/// uses an address String and returns a LatLng geopoint
Future<GeoPoint> toLatLng(String addr) async {
  if (addr == null || addr.startsWith('Vanderhoof')) {
    return null;
  }
  var address;
  try {
    address = await Geocoder.local.findAddressesFromQuery(addr);
  } catch (e) {
    print("could not get geopoint for address: $addr");
    return address;
  }
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  return GeoPoint(lat, lng);
}

//=========================================
//Method to add business to FireStore
//=========================================
Future<void> addBusiness(Map<String, dynamic> businessInfo) {
// Used to add businesses
  CollectionReference business =
      FirebaseFirestore.instance.collection('businesses');
  return business
      .add(businessInfo)
      .then((value) => {
            print("Business Added:  ${value.id}, ${businessInfo['name']}"),
            business.doc(value.id).update({"id": value.id})
          })
      .catchError((error) => print("Failed to add Business: $error"));
}

Future<void> deleteCard(
    String cardName, String docID, int index, CollectionReference fireStore) {
  // Delete from fireStore
  // String docID = businessName.replaceAll('/', '|');
  return fireStore
      .doc(docID)
      .delete()
      .then((value) => print("$docID Deleted"))
      .catchError((error) => print("Failed to delete user: $error"));
}

DateTime addDateTime({DateTime dateTime, String repeatType}) {
  if (repeatType == 'Daily') {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1,
        dateTime.hour, dateTime.minute);
  } else if (repeatType == 'Weekly') {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 7,
        dateTime.hour, dateTime.minute);
  } else if (repeatType == 'Monthly') {
    return DateTime(dateTime.year, dateTime.month + 1, dateTime.day,
        dateTime.hour, dateTime.minute);
  } else {
    return DateTime(dateTime.year + 1, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute);
  }
}

Future<void> addEvent(event, CollectionReference fireStore, {File imageFile}) {
  print("adding to firebase: $event");
  return fireStore
      .add(event)
      .then((value) => {
            print("Event Added: ${value.id} : ${event['title']}"),
            fireStore.doc(value.id).update({"id": value.id}),
            if (imageFile != null)
              {
                uploadFile(imageFile, value.id).then((v) =>
                    downloadURL(value.id).then((imgURL) =>
                        fireStore.doc(value.id).update({"imgURL": imgURL}))),
              }
          })
      .catchError((error) => print("Failed to add Event: $error"));
}

Future<void> uploadFile(File file, String filename) async {
  try {
    await firebase_storage.FirebaseStorage.instance
        .ref('uploads/$filename.png')
        .putFile(file);
  } on FirebaseException catch (e) {
    print("upload fail: $e");
    // e.g, e.code == 'canceled'
  }
}

Future<String> downloadURL(String filename) async {
  return await firebase_storage.FirebaseStorage.instance
      .ref('uploads/$filename.png')
      .getDownloadURL();
}

/// uses a Color with a hex code and returns a MaterialColor object
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}
