import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vanderhoof_app/fireStoreObjects.dart';

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

List<Marker> resetMarkers(markers, filteredFireStoreObjects) {
  markers.clear();
  for (int i = 0; i < filteredFireStoreObjects.length; i++) {
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
  return markers;
}

class Map extends StatefulWidget {
  List<FireStoreObject> listOfFireStoreObjects;
  Set<Marker> _markers = HashSet<Marker>();
  Map(fireStoreObjects, _markers);

  @override
  State<Map> createState() => MapState(listOfFireStoreObjects, _markers);
}

class MapState extends State<Map> {
  Set<Marker> _markers;
  GoogleMapController _mapController;
  MapType mapType = MapType.normal;
  List<FireStoreObject> listOfFireStoreObjects;
  MapState(this.listOfFireStoreObjects, this._markers);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(54.0117956, -124.0177679),
    zoom: 13,
  );

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    //run marker adapter
    setState(() {
      for (int i = 0; i < listOfFireStoreObjects.length; i++) {
        _markers.add(
          Marker(
              markerId: MarkerId(i.toString()),
              position: listOfFireStoreObjects[i].location,
              infoWindow: InfoWindow(
                title: listOfFireStoreObjects[i].name,
                snippet: listOfFireStoreObjects[i].description,
              )),
        );
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
    );
  }
}
