import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract parent class for object that will be imported from firestore.
abstract class FireStoreObject {
  String name;
  String address;
  String description;
  LatLng location;
  String id;

  FireStoreObject(String name, String address, GeoPoint geoLocation,
      String description, String id) {
    this.name = name;
    this.address = address;
    this.description = description;
    this.id = id;

    // If the address is not provided and or is bad,
    // the location is set to null and is not converted to LatLng.
    if (geoLocation != null) {
      double lat = geoLocation.latitude;
      double lng = geoLocation.longitude;
      this.location = LatLng(lat, lng);
    } else {
      this.location = null;
    }
  }
}

/// Represents a business that is a member of the chamber.
class Business extends FireStoreObject {
  final String phoneNumber;
  final String email;
  final Map socialMedia;
  final String website;
  final String imgURL;
  final List category;

  Business(name, address, location, description, id, this.phoneNumber,
      this.email, this.socialMedia, this.website, this.imgURL, this.category)
      : super(name, address, location, description, id);
}

/// Represents an event.
class Event extends FireStoreObject {
  final DateTime datetimeEnd;
  final DateTime datetimeStart;
  final bool isMultiday;

  Event({
    name,
    address,
    location,
    description,
    id,
    this.datetimeEnd,
    this.datetimeStart,
    this.isMultiday,
  }) : super(name, address, location, description, id);
}

/// Represents a hike trail.
class Hike extends FireStoreObject {
  final String distance;
  final String rating;
  final String time;
  final String wheelchair;
  var pointsOfInterest;
  final String imgURL;

  Hike(name, address, location, id, this.distance, this.rating, this.time,
      this.wheelchair, description, this.pointsOfInterest, this.imgURL)
      : super(name, address, location, description, id);
}

/// Represents a recreational spot.
class Recreational extends FireStoreObject {
  final String phoneNumber;
  final String email;
  final String website;

  Recreational(name, address, location, description, id, this.phoneNumber,
      this.email, this.website)
      : super(name, address, location, description, id);
}
