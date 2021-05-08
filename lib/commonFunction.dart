import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';

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
