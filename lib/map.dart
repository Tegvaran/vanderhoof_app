import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'fireStoreObjects.dart';

void scrollToIndex(ItemScrollController scrollController, int index) {
  scrollController.scrollTo(
    index: index,
    duration: Duration(seconds: 1),
    curve: Curves.easeInOut,
  );
}

Set<Marker> MarkerAdapter(List<FireStoreObject> objList) {
  Set<Marker> outList = HashSet<Marker>();
  for (int i = 0; i < objList.length; i++) {
    outList.add(
      Marker(
          markerId: MarkerId(i.toString()),
          //position: objList[i].location,
          infoWindow: InfoWindow(
            title: objList[i].name,
            snippet: objList[i].description,
          )),
    );
  }
  return outList;
}

HashSet<Marker> resetMarkers(
    markers, filteredFireStoreObjects, scrollController) {
  markers.clear();
  for (int i = 0; i < filteredFireStoreObjects.length; i++) {
    // Checks if the location of the object is null,
    // if it is not then it is added to the marker list.
    if (filteredFireStoreObjects[i].location != null) {
      markers.add(
        Marker(
            markerId: MarkerId(i.toString()),
            position: filteredFireStoreObjects[i].location,
            onTap: () {
              scrollToIndex(scrollController, i);
            },
            infoWindow: InfoWindow(
              title: filteredFireStoreObjects[i].name,
              snippet: filteredFireStoreObjects[i].description,
            )),
      );
    }
  }
  return markers;
}

void changeMarkerColor(index, markers, fireStoreObjects, scrollController) {
  //remove marker at expansion card index
  // markers.remove(markers.elementAt(index));
  print("index " + index.toString());
  if (fireStoreObjects[index].location != null) {
    print("fireObject\n" + fireStoreObjects[index].name);
    //add new marker with blue color
    markers.add(
      Marker(
          markerId: MarkerId(fireStoreObjects[index].name),
          position: fireStoreObjects[index].location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            scrollToIndex(scrollController, index);
          },
          infoWindow: InfoWindow(
            title: fireStoreObjects[index].name,
            snippet: fireStoreObjects[index].description,
          )),
    );
  }
  return markers;
}

Future<LatLng> toLatLng(String addr) async {
  var address = await Geocoder.local.findAddressesFromQuery(addr);
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  LatLng ll = LatLng(lat, lng);
  return ll;
}

class Gmap extends StatefulWidget {
  List<FireStoreObject> listOfFireStoreObjects;
  Set<Marker> _markers = HashSet<Marker>();
  final ItemScrollController scrollController;

  Gmap(this.listOfFireStoreObjects, this._markers, this.scrollController);

  @override
  State<Gmap> createState() =>
      GmapState(listOfFireStoreObjects, _markers, scrollController);
}

double zoomVal = 13;

class GmapState extends State<Gmap> {
  Set<Marker> _markers;
  MapType mapType = MapType.normal;
  List<FireStoreObject> listOfFireStoreObjects;
  Location _location = Location();
  GoogleMapController _mapController;
  ItemScrollController scrollController;
  GmapState(this.listOfFireStoreObjects, this._markers, this.scrollController);

  static final CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(54.0117956, -124.0177679), zoom: 13);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    //run marker adapter
    setState(() {
      for (int i = 0; i < listOfFireStoreObjects.length; i++) {
        // Checks if the location of the object is null,
        // if it is not then it is added to the marker list.
        if (listOfFireStoreObjects[i].location != null) {
          _markers.add(
            Marker(
                markerId: MarkerId(i.toString()),
                position: listOfFireStoreObjects[i].location,
                onTap: () {
                  // listOfFireStoreObjects[i].
                  scrollToIndex(scrollController, i);
                },
                infoWindow: InfoWindow(
                  title: listOfFireStoreObjects[i].name,
                  snippet: listOfFireStoreObjects[i].description,
                )),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      mapType: mapType,
      markers: _markers,
      onMapCreated: _onMapCreated,
      myLocationEnabled: true,
    );
  }
}
