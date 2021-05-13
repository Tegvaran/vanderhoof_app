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
  final String category;
  final String id;

  Business(name, address, location, description, this.phoneNumber, this.email,
      this.socialMedia, this.website, this.imgURL, this.category, this.id)
      : super(name, address, location, description);
}

/// Represents an event.
class Event extends FireStoreObject {
  final DateTime datetimeEnd;
  final DateTime datetimeStart;
  final String id;
  final bool isMultiday;
  final String imgURL;

  Event(
      {name,
      address,
      location,
      description,
      this.datetimeEnd,
      this.datetimeStart,
      this.id,
      this.isMultiday,
      this.imgURL})
      : super(name, address, location, description);
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

/// Represents a recreational spot.
class Recreational extends FireStoreObject {
  final String phoneNumber;
  final String email;
  final String website;

  Recreational(name, address, location, description, this.phoneNumber,
      this.email, this.website)
      : super(name, address, location, description);
}

/// Represents a business resource.
class Resource extends FireStoreObject {
  final String name;
  final String description;
  final String website;
  final String id;

  Resource(this.name, this.description, this.website, this.id)
      : super('', '', null, '');
}
