import 'package:flutter/material.dart';

class Business extends StatefulWidget {
  Business({Key key}) : super(key: key);

  final title = "Businesses";

  @override
  _BusinessPageState createState() => new _BusinessPageState();
}

class _BusinessPageState extends State<Business> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // appBar: AppBar(
      //   backgroundColor: Colors.pink,
      //   title: !isSearching
      //       ? Text('All Countries')
      //       : TextField(
      //           onChanged: (value) {
      //             _filterCountries(value);
      //           },
      //           style: TextStyle(color: Colors.white),
      //           decoration: InputDecoration(
      //               icon: Icon(
      //                 Icons.search,
      //                 color: Colors.white,
      //               ),
      //               hintText: "Search Country Here",
      //               hintStyle: TextStyle(color: Colors.white)),
      //         ),
      //   actions: <Widget>[
      //     isSearching
      //         ? IconButton(
      //             icon: Icon(Icons.cancel),
      //             onPressed: () {
      //               setState(() {
      //                 this.isSearching = false;
      //                 filteredCountries = countries;
      //               });
      //             },
      //           )
      //         : IconButton(
      //             icon: Icon(Icons.search),
      //             onPressed: () {
      //               setState(() {
      //                 this.isSearching = true;
      //               });
      //             },
      //           )
      //   ],
      // ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here
            Text("Business page - first child"),
            Text("another text widget - second child"),
            Text("a third text widget - third child"),
          ],
        ),
      ),
    );
  }
}
