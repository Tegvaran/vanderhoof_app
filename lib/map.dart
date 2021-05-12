import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vanderhoof_app/fireStoreObjects.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

bool isMapVisible = true;

void hideMap() {
  isMapVisible = false;
}

void showMap() {
  isMapVisible = true;
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

HashSet<Marker> resetMarkers(markers, filteredFireStoreObjects) {
  markers.clear();
  for (int i = 0; i < filteredFireStoreObjects.length; i++) {
    // Checks if the location of the object is null,
    // if it is not then it is added to the marker list.
    if (filteredFireStoreObjects[i].location != null) {
      markers.add(
        Marker(
            markerId: MarkerId(i.toString()),
            position: filteredFireStoreObjects[i].location,
            infoWindow: InfoWindow(
              title: filteredFireStoreObjects[i].name,
              snippet: filteredFireStoreObjects[i].description,
            )),
      );
    }
  }
  return markers;
}

void changeMarkerColor(index, markers, fireStoreObjects) {
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
          infoWindow: InfoWindow(
            title: fireStoreObjects[index].name,
            snippet: fireStoreObjects[index].address,
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
  Gmap(this.listOfFireStoreObjects, this._markers);

  @override
  State<Gmap> createState() => GmapState(listOfFireStoreObjects, _markers);
}

double zoomVal = 13;

class GmapState extends State<Gmap> {
  Set<Marker> _markers;
  MapType mapType = MapType.normal;
  List<FireStoreObject> listOfFireStoreObjects;
  Location _location = Location();
  GoogleMapController _mapController;
  GmapState(this.listOfFireStoreObjects, this._markers);

  static final CameraPosition _kGooglePlex =
      CameraPosition(target: LatLng(54.0117956, -124.0177679), zoom: 13);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // _location.onLocationChanged.listen((l) {
    //   _mapController.animateCamera(
    //     CameraUpdate.newCameraPosition(
    //       CameraPosition(target: LatLng(l.latitude, l.longitude)
    //       ),
    //     ),
    //   );
    // });
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
                // onTap: () {
                //   listOfFireStoreObjects[i].
                // },
                infoWindow: InfoWindow(
                  title: listOfFireStoreObjects[i].name,
                  snippet: listOfFireStoreObjects[i].address,
                )),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        width: double.infinity,
        height: isMapVisible ? 200.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        child: GoogleMap(
          initialCameraPosition: _kGooglePlex,
          mapType: mapType,
          markers: _markers,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
        ));
  }
}
