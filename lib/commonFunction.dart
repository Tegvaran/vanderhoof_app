import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';

Future<GeoPoint> toLatLng(String addr) async {
  var address = await Geocoder.local.findAddressesFromQuery(addr);
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  return GeoPoint(lat, lng);
}
