import 'dart:collection';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vanderhoof_app/fireStoreObjects.dart';
import 'package:geocoder/geocoder.dart';
import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:provider/provider.dart';

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

Future<LatLng> toLatLng(String addr) async {
  var address = await Geocoder.local.findAddressesFromQuery(addr);
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  LatLng ll = LatLng(lat, lng);
  return ll;
}

class GMap extends StatefulWidget {
  List<FireStoreObject> listOfFireStoreObjects;
  Set<Marker> _markers = HashSet<Marker>();
  GMap(this.listOfFireStoreObjects, this._markers);

  @override
  State<GMap> createState() => MapState(listOfFireStoreObjects, _markers);
}

class InfoWindowModel extends ChangeNotifier {
  bool _showInfoWindow = false;
  bool _tempHidden = false;
  FireStoreObject _fireObject;
  double _leftMargin;
  double _topMargin;

  void rebuildInfoWindow(){
    notifyListeners();
  }

  void updateObj(FireStoreObject obj) {
    _fireObject = obj;
  }

  void updateVisibility (bool visibility) {
    _showInfoWindow = visibility;
  }

  void updateInfoWindow(
      BuildContext context,
      GoogleMapController controller,
      LatLng location,
      double infoWindowWidth,
      double markerOffset
      ) async {
    ScreenCoordinate screenCoordinate = await controller.getScreenCoordinate(location);
    double devicePixelRatio = Platform.isAndroid?MediaQuery.of(context).devicePixelRatio : 1.0;
    double left = (screenCoordinate.x.toDouble()/devicePixelRatio) - (infoWindowWidth/2);
    double top = (screenCoordinate.y.toDouble()/devicePixelRatio) - markerOffset;
    if (left < 0 || top < 0) {
      _tempHidden = true;
    } else {
      _tempHidden = false;
      _leftMargin = left;
      _topMargin = top;
    }
  }

  bool get showInfoWindow => (_showInfoWindow == true && _tempHidden == false)? true : false;

  double get leftMargin => _leftMargin;

  double get topMargin => _topMargin;

  FireStoreObject get fireObject => _fireObject;
}

class MapState extends State<GMap> {
  GoogleMapController _mapController;
  Set<Marker> _markers;
  MapType mapType = MapType.normal;
  List<FireStoreObject> listOfFireStoreObjects;
  double _infoWindowWidth = 250;
  double _markerOffset = 150;
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
    final providerObject = Provider.of<InfoWindowModel>(context, listen: false);
    for (int i = 0; i < listOfFireStoreObjects.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: listOfFireStoreObjects[i].location,
          onTap: () {
            providerObject.updateInfoWindow(
              context,
              _mapController,
              listOfFireStoreObjects[i].location,
              _infoWindowWidth,
              _markerOffset,
            );
            providerObject.updateObj(listOfFireStoreObjects[i]);
            providerObject.updateVisibility(true);
            providerObject.rebuildInfoWindow();
          },
        ),
      );
    }
    return Container(
        child: Consumer<InfoWindowModel>(
          builder: (context, model, child){
            return Stack (
              children: <Widget> [
                child,
                Positioned(
                    top: 0,
                    left: 0,
                    child: Visibility (
                      visible: providerObject.showInfoWindow,
                      child: (providerObject._fireObject == null ||
                          !providerObject.showInfoWindow)
                          ? Container ()
                          : Container (
                        margin: EdgeInsets.only(
                          left: providerObject.leftMargin,
                          top: providerObject.topMargin,
                        ),
                        //Custom InfoWindow!!!!!
                        child: Column(
                          children: <Widget> [
                            Container(
                              decoration: BoxDecoration (
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0),
                                    blurRadius: 6.0,
                                  ),
                                ],
                              ),
                              height: 100,
                              width: 250,
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Image.network(
                                  //   providerObject._fireObject,
                                  //   height: 55,
                                  // ),
                                  Column(
                                    children: <Widget> [
                                      Text (
                                        providerObject._fireObject.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black45,
                                        ),
                                      ),
                                      IconTheme (
                                        data: IconThemeData(
                                          color: Colors.red,
                                        ),
                                        child: Container (
                                          child: Text(
                                            providerObject._fireObject.description,
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Triangle.isosceles(
                              edge: Edge.BOTTOM,
                              child: Container(
                                color: Color(0xffffe6cc),
                                width: 20.0,
                                height: 15.0,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                )
              ],
            );
          },
          child: Positioned(
            child: GoogleMap(
              mapType: mapType,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: _onMapCreated,
              markers: _markers,
              onTap: (position) {
                if (providerObject.showInfoWindow) {
                  providerObject.updateVisibility(false);
                  providerObject.rebuildInfoWindow();
                }
              },
              onCameraMove: (position) {
                if (providerObject._fireObject != null) {
                  providerObject.updateInfoWindow(
                    context,
                    _mapController,
                    providerObject._fireObject.location,
                    _infoWindowWidth,
                    _markerOffset,
                  );
                  providerObject.rebuildInfoWindow();
                }
              },
            ),
          ),
        )
    );
    // return GoogleMap(
    //   initialCameraPosition: _kGooglePlex,
    //   mapType: mapType,
    //   markers: _markers,
    //   onMapCreated: _onMapCreated,
    // );
  }
}
