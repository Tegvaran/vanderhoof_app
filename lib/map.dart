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
            snippet: objList[i].address,
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
            markerId: MarkerId(filteredFireStoreObjects[i].name),
            position: filteredFireStoreObjects[i].location,
            onTap: () {
              scrollToIndex(scrollController, i);
              // resetMarkers(
              //    markers, filteredFireStoreObjects, scrollController);
              // print("marker length before " + markers.length.toString());
              // markers.forEach((element) {
              //   if (element.markerId.toString().compareTo(filteredFireStoreObjects[i].name) == 0) {
              //     print("in the remove--------------------");
              //     markers.remove(element);
              //     print('in reset' + element.markerId.toString());
              //   }
              // });
              // print("marker length after " + markers.length.toString());
              // changeMarkerColor(i, markers, filteredFireStoreObjects, scrollController);
            },
            infoWindow: InfoWindow(
              title: filteredFireStoreObjects[i].name,
              snippet: filteredFireStoreObjects[i].address,
            )),
      );
    }
  }
  return markers;
}

void changeMarkerColor(index, markers, fireStoreObjects, scrollController) {
  //remove marker at expansion card index
  //markers.remove(markers.elementAt(index));
  print("index " + index.toString());
  if (fireStoreObjects[index].location != null) {
    print("fireObject\n" + fireStoreObjects[index].name);
    //add new marker with blue colors ---
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
            snippet: fireStoreObjects[index].address,
          )),
    );
  }
  return markers;
}

GoogleMapController mapController;
void changeCamera(LatLng pos) {
  mapController.moveCamera(CameraUpdate.newLatLng(pos));
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
    mapController = _mapController;

    //run marker adapter
    setState(() {
      for (int i = 0; i < listOfFireStoreObjects.length; i++) {
        // Checks if the location of the object is null,
        // if it is not then it is added to the marker list.
        if (listOfFireStoreObjects[i].location != null) {
          _markers.add(
            Marker(
                markerId: MarkerId(listOfFireStoreObjects[i].name),
                position: listOfFireStoreObjects[i].location,
                onTap: () {
                  scrollToIndex(scrollController, i);
                  // resetMarkers(
                  //     _markers, listOfFireStoreObjects, scrollController);
                  // HashSet<Marker> temp = _markers;
                  // temp.forEach((element) {
                  //   print("marker length before " + _markers.length.toString());
                  //   if (element.markerId.toString().compareTo(listOfFireStoreObjects[i].name) == 0) {
                  //     _markers.remove(element);
                  //     print('in reset' + element.markerId.toString());
                  //   }
                  // });
                  // print("marker length after " + _markers.length.toString());
                  // changeMarkerColor(i, _markers, listOfFireStoreObjects, scrollController);
                },
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
    return GoogleMap(
      initialCameraPosition: _kGooglePlex,
      mapType: mapType,
      markers: _markers,
      onMapCreated: _onMapCreated,
      onTap: (latLng) {
        print(latLng);
        resetMarkers(_markers, listOfFireStoreObjects, scrollController);
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
