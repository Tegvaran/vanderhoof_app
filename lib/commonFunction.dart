import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

// import 'cards.dart';
import 'main.dart';
// import 'map.dart';

/// uses an address String and returns a LatLng geopoint
Future<GeoPoint> toLatLng(String addr) async {
  if (addr == null || addr.startsWith('Vanderhoof')) {
    return null;
  }
  var address;
  try {
    address = await Geocoder.local.findAddressesFromQuery(addr);
  } catch (e) {
    print("could not get geopoint for address: $addr");
    return address;
  }
  var first = address.first;
  var coor = first.coordinates;
  var lat = coor.latitude;
  var lng = coor.longitude;
  return GeoPoint(lat, lng);
}

//=========================================
//Method to add business to FireStore
//=========================================
Future<void> addBusiness(Map<String, dynamic> businessInfo, {File imageFile}) {
// Used to add businesses
  CollectionReference business =
      FirebaseFirestore.instance.collection('businesses_testa');
  return business
      .add(businessInfo)
      .then((value) => {
            print("Business Added:  ${value.id}, ${businessInfo['name']}"),
            business.doc(value.id).update({"id": value.id}),
            if (imageFile != null)
              {
                uploadFile(imageFile, value.id, "businesses").then((v) =>
                    downloadURL(value.id, "businesses").then((imgURL) =>
                        business.doc(value.id).update({"imgURL": imgURL}))),
              }
          })
      .catchError((error) => print("Failed to add Business: $error"));
}

Future<void> deleteCard(
    String cardName, String docID, int index, CollectionReference fireStore) {
  // Delete from fireStore
  // String docID = businessName.replaceAll('/', '|');
  return fireStore
      .doc(docID)
      .delete()
      .then((value) => print("$docID Deleted"))
      .catchError((error) => print("Failed to delete user: $error"));
}

DateTime addDateTime({DateTime dateTime, String repeatType}) {
  if (repeatType == 'Daily') {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 1,
        dateTime.hour, dateTime.minute);
  } else if (repeatType == 'Weekly') {
    return DateTime(dateTime.year, dateTime.month, dateTime.day + 7,
        dateTime.hour, dateTime.minute);
  } else if (repeatType == 'Monthly') {
    return DateTime(dateTime.year, dateTime.month + 1, dateTime.day,
        dateTime.hour, dateTime.minute);
  } else {
    return DateTime(dateTime.year + 1, dateTime.month, dateTime.day,
        dateTime.hour, dateTime.minute);
  }
}

Future<void> addEvent(event, CollectionReference fireStore, {File imageFile}) {
  print("adding to firebase: $event");
  return fireStore
      .add(event)
      .then((value) => {
            print("Event Added: ${value.id} : ${event['title']}"),
            fireStore.doc(value.id).update({"id": value.id}),
            if (imageFile != null)
              {
                uploadFile(imageFile, value.id, "events").then((v) =>
                    downloadURL(value.id, "events").then((imgURL) =>
                        fireStore.doc(value.id).update({"imgURL": imgURL}))),
              }
          })
      .catchError((error) => print("Failed to add Event: $error"));
}

Future<void> uploadFile(File file, String filename, String folderName) async {
  try {
    await firebase_storage.FirebaseStorage.instance
        .ref('$folderName/$filename.png')
        .putFile(file);
  } on FirebaseException catch (e) {
    print("upload fail: $e");
    // e.g, e.code == 'canceled'
  }
}

Future<String> downloadURL(String filename, String folderName) async {
  return await firebase_storage.FirebaseStorage.instance
      .ref('$folderName/$filename.png')
      .getDownloadURL();
}

/// uses a Color with a hex code and returns a MaterialColor object
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

Widget showLoadingScreen() {
  return SpinKitWave(
    color: colorPrimary,
    size: 50.0,
  );
}

//=================================================
// Backgrounds for Edit/Delete
//=================================================
Widget slideRightEditBackground() {
  return Container(
    color: Colors.green,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.edit,
            color: Colors.white,
          ),
          Text(
            " Edit",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    ),
  );
}

Widget slideLeftDeleteBackground() {
  return Container(
    color: Colors.red,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            " Delete",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.right,
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}

//***************************Same as below************************************
// Widget buildBody(isFirstTime, future, filteredItem, markers, buildList,
//     {buildChips}) {
//   return Container(
//     padding: EdgeInsets.all(0.0),
//     child: isFirstTime
//         ? FutureBuilder(
//             future: future,
//             builder: (context, snapshot) {
//               switch (snapshot.connectionState) {
//                 case ConnectionState.none:
//                   return Text('non');
//                 case ConnectionState.active:
//                 case ConnectionState.waiting:
//                   return showLoadingScreen();
//                 case ConnectionState.done:
//                   {
//                     print(buildChips);
//                     return _buildBody(filteredItem, markers, buildList,
//                         buildChips: buildChips);
//                   }
//                 default:
//                   return Text("Default");
//               }
//             },
//           )
//         : _buildBody(filteredItem, markers, buildList, buildChips: buildChips),
//   );
// }

// ************Saving for later can be deleted if we don't end up doing this.
// Widget _buildBody(filteredItem, markers, buildList, {buildChips}) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // insert widgets here wrapped in `Expanded` as a child
//       // note: play around with flex int value to adjust vertical spaces between widgets
//       Expanded(
//         flex: 9,
//         child: Gmap(filteredItem, markers),
//       ),
//       (buildChips != null && buildChips != "")
//           ? Expanded(flex: 2, child: buildChips())
//           : Container(),
//       Expanded(
//         flex: 14,
//         child: filteredItem.length != 0
//             ? buildList()
//             : Container(
//                 child: Center(
//                   child: Text("No results found", style: titleTextStyle),
//                 ),
//               ),
//       ),
//     ],
//   );
// }
