import 'package:flutter/material.dart';

class Recreation extends StatefulWidget {
  Recreation({Key key}) : super(key: key);

  final title = "Recreation Spots";

  @override
  _RecreationPageState createState() => new _RecreationPageState();
}

class _RecreationPageState extends State<Recreation> {
  List items = [];
  List filteredSearchItems = [];
  bool isSearching = false;

  @override
  void initState() {
    // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
    // todo: get firebase data and populate into list of items

    // getItems().then((data) {
    //   setState(() {
    //     items = filteredSearchItems = data;
    //   });
    // });
    super.initState();
  }

  // This method does the logic for search
  // reference: https://github.com/bitfumes/flutter-country-house/blob/master/lib/Screens/AllCountries.dart
  // todo: replace objClass so value will match with object name
  void _filterSearchItems(value) {
    setState(() {
      filteredSearchItems = items
          .where((objClass) =>
              objClass['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text(widget.title)
            : TextField(
                onChanged: (value) {
                  // search logic here
                  _filterSearchItems(value);
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    hintText: "Search Recreation Spots",
                    hintStyle: TextStyle(color: Colors.white70)),
              ),
        actions: <Widget>[
          isSearching
              ? IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      this.isSearching = false;
                      filteredSearchItems = items;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      this.isSearching = true;
                    });
                  },
                )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here - map and listview
            // changelog: - i made maps flex property a 2, and listview widget flex property a 4
            //            - seems to be better for layout, gives listview more space
            //            - see `business.dart` or `hike.dart`
            Text("Recreation page - first child"),
            Text("another text widget - second child"),
            Text("a third text widget - third child"),
          ],
        ),
      ),
    );
  }
}
