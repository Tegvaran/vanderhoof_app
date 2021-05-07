import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract parent class for object that will be imported from firestore.
abstract class FireStoreObject {
  String name;
  String address;
  String description;
  LatLng location;

  FireStoreObject(
      String name, String address, GeoPoint geoLocation, String description) {
    this.name = name;
    this.address = address;
    this.description = description;
    double lat = geoLocation.latitude;
    double lng = geoLocation.longitude;
    this.location = LatLng(lat, lng);
  }
}

/// Represents a hike trail.
class HikeTrail extends FireStoreObject {
  final String distance;
  final String rating;
  final String time;
  final String wheelchair;
  var pointsOfInterest;
  final String imgURL;

  HikeTrail(name, address, location, this.distance, this.rating, this.time,
      this.wheelchair, description, this.pointsOfInterest, this.imgURL)
      : super(name, address, location, description);
}

/// Represents a business that is a mumber of the chamber.
class Business extends FireStoreObject {
  final String phoneNumber;
  final String email;
  final Map socialMedia;
  final String website;
  final String imgURL;
  final String category;

  Business(name, address, location, description, this.phoneNumber, this.email,
      this.socialMedia, this.website, this.imgURL, this.category)
      : super(name, address, location, description);
}
