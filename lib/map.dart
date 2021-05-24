import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'main.dart';

bool _isMapVisible = true;

/// Uses [scrollController] to scroll listView to the expandedTile of [index]
/// Is used in Business, Recreation and hikes pages
void scrollToIndex(ItemScrollController scrollController, int index) {
  scrollController.scrollTo(
    index: index,
    duration: Duration(seconds: 1),
    curve: Curves.easeInOut,
  );
}

/// Converts [objList] to list of Markers
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
/// Clears [markers] and repopulates it using [filteredFireStoreObjects]
/// [scrollController] is used to apply scrollToIndex and changeMarkerColor
/// to the marker's onTap
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
              changeMarkerColor(
                  i, markers, filteredFireStoreObjects, scrollController);
              _isMapVisible = true;
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

/// replicates marker in [markers] of [index] using [fireStoreObjects] as source
/// [scrollController] used to add scrollToIndex to marker's onTap
void changeMarkerColor(index, markers, fireStoreObjects, scrollController) {
  //remove marker at expansion card index
  //markers.remove(markers.elementAt(index));

  // Colour of new marker
  BitmapDescriptor selectedIconParams = BitmapDescriptor.defaultMarkerWithHue(
      HSVColor.fromColor(colorPrimary).hue);

  print("index " + index.toString());
  if (fireStoreObjects[index].location != null) {
    print("fireObject\n" + fireStoreObjects[index].name);
    //add new marker with blue colors ---
    markers.add(
      Marker(
          markerId: MarkerId(fireStoreObjects[index].name),
          position: fireStoreObjects[index].location,
          icon: selectedIconParams,
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

// Global mapController used to provide extended access
GoogleMapController mapController;

/// Used to animate and change the Google Maps camera position of [pos]
void changeCamera(LatLng pos) {
  mapController.animateCamera(CameraUpdate.newLatLng(pos));
}

/// Uses [addr] value to return LatLng value
Future<LatLng> toLatLng(String addr) async {
  var address = await Geocoder.local.findAddressesFromQuery(addr);
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  LatLng ll = LatLng(lat, lng);
  return ll;
}

/// Base Gmap StatefulWidget inherits from StatefulWidget
class Gmap extends StatefulWidget {
  List<FireStoreObject> listOfFireStoreObjects;
  Set<Marker> _markers = HashSet<Marker>();
  final ItemScrollController scrollController;

  Gmap(this.listOfFireStoreObjects, this._markers, this.scrollController);

  @override
  State<Gmap> createState() =>
      GmapState(listOfFireStoreObjects, _markers, scrollController);
}

/// Gmap active State initialized in Gmap
/// returns Widget with Google Map Node
class GmapState extends State<Gmap> {
  Set<Marker> _markers;
  MapType mapType = MapType.normal;
  List<FireStoreObject> listOfFireStoreObjects;
  LocationData currentLocation;
  GoogleMapController _mapController;
  ItemScrollController scrollController;
  GmapState(this.listOfFireStoreObjects, this._markers, this.scrollController);

  static final double zoomVal = 13;
  static final LatLng vanderhoofLatLng = LatLng(54.0117956, -124.0177679);
  static CameraPosition _initialCameraPosition =
      CameraPosition(target: vanderhoofLatLng, zoom: zoomVal);

  /// returns the current location of the users phone
  _getLocation() async {
    var location = new Location();
    try {
      currentLocation = await location.getLocation();

      print("locationLatitude: ${currentLocation.latitude}");
      print("locationLongitude: ${currentLocation.longitude}");
      setState(() {
        _initialCameraPosition = CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: zoomVal);
      }); //rebuild the widget after getting the current location of the user
    } on Exception {
      currentLocation = null;
    }
  }

  /// Uses _getLocation to grab the initial location of the users phone
  @override
  void initState() {
    _getLocation();
    super.initState();
  }

  /// Sets up the parameters for the map
  /// sets [_mapController] to be GoogleMapController and sets up
  /// initial [_markers] list of Markers
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    mapController = _mapController;
    _isMapVisible = true;

    //run marker adapter
    setState(() {
      for (int i = 0; i < listOfFireStoreObjects.length; i++) {
        // Checks if the location of the object is null,
        // if it is not then it is added to the marker list.
        if (listOfFireStoreObjects[i].location != null) {
          Marker marker = Marker(
              markerId: MarkerId(listOfFireStoreObjects[i].name),
              position: listOfFireStoreObjects[i].location,
              onTap: () {
                scrollToIndex(scrollController, i);
                changeMarkerColor(
                    i, _markers, listOfFireStoreObjects, scrollController);
                _isMapVisible = true;

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
              },
              infoWindow: InfoWindow(
                title: listOfFireStoreObjects[i].name,
                snippet: listOfFireStoreObjects[i].address,
              ));
          _markers.add(marker);
        }
      }
    });
  }

  /// Returns map visability button that appears on map.
  /// onPressed sets _isMapVisible to false
  Widget _buildMapVisibilityButton() {
    return Container(
      height: 38,
      width: 114,
      child: _isMapVisible
          ? FloatingActionButton(
              child: TextButton.icon(
                label: Text("Hide Map"),
                icon: Icon(Icons.visibility_outlined),
                style: TextButton.styleFrom(
                  primary: Color(0xFF565656),
                  backgroundColor: Color(0xFFFFFFFF),
                ),
                onPressed: () {
                  setState(() {
                    _isMapVisible = false;
                  });
                },
              ),
              backgroundColor: createMaterialColor(Color(0xFFFFFFFF)),
              mini: true,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              onPressed: () {
                setState(() {
                  _isMapVisible = false;
                });
              },
            )
          : null,
    );
  }

  /// Returns AnimatedContainer that has GoogleMap as child
  /// GoogleMap's onTap contains: resetMarkers and sets _isMapVisible to true
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: double.infinity,
      height: _isMapVisible ? 217.0 : 62.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: Scaffold(
        body: GoogleMap(
          initialCameraPosition: _initialCameraPosition,
          mapType: mapType,
          markers: _markers,
          onMapCreated: _onMapCreated,
          onTap: (value) {
            resetMarkers(_markers, listOfFireStoreObjects, scrollController);
            setState(() {
              _isMapVisible = true;
            });
          },
          zoomControlsEnabled: _isMapVisible ? true : false,
          myLocationEnabled: true,
          myLocationButtonEnabled: _isMapVisible ? true : false,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: _buildMapVisibilityButton(),
      ),
    );
  }
}
