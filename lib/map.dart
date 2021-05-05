import 'dart:collection';

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
