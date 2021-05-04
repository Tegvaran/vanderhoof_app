import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract parent class for object that will be imported from firestore.
abstract class FireStoreObject {
  String name;
  String address;
  LatLng location;

  FireStoreObject(String name, String address, GeoPoint geoLocation) {
    this.name = name;
    this.address = address;
    double lat = geoLocation.latitude;
    double lng = geoLocation.longitude;
    this.location = new LatLng(lat, lng);
  }
}

/// Represents a hike trail.
class HikeTrail extends FireStoreObject {
  final String distance;
  final String rating;
  final String time;
  final String wheelchair;
  final String description;

  HikeTrail(name, address, location, this.distance, this.rating, this.time,
      this.wheelchair, this.description)
      : super(name, address, location);
}

/// Represents a business that is a mumber of the chamber.
class Business extends FireStoreObject {
  final String description;
  final String phoneNumber;
  final String email;
  final Map socialMedia;
  final String website;

  Business(name, address, location, this.description, this.phoneNumber,
      this.email, this.socialMedia, this.website)
      : super(name, address, location);
}
