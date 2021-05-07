import 'package:flutter/material.dart';

class Recreation extends StatefulWidget {
  Recreation({Key key}) : super(key: key);

  final title = "Recreation Spots";

  @override
  _RecreationPageState createState() => new _RecreationPageState();
}

class _RecreationPageState extends State<Recreation> {
  List items = [];
  List filteredItems = [];
  bool isSearching = false;

  // this method gets firebase data and populates into list of recreation spots
  // todo: get firebase data and populate into list of items
  @override
  void initState() {
    // getItems().then((data) {
    //   setState(() {
    //     items = filteredItems = data;
    //   });
    // });
    super.initState();
  }

  // This method does the logic for search and changes filteredRecreationSpots to search results
  // todo: replace objClass so value will match with object name (eg. businessCard)
  void _filterSearchItems(value) {
    setState(() {
      filteredItems = items
          .where((objClass) =>
              objClass['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  // Widget build for AppBar with Search
  Widget _buildSearchAppBar() {
    return AppBar(
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
                    filteredItems = items;
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
    );
  }

  //=========================
  // Final Build Widget
  //=========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchAppBar(),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here wrapped in `Expanded` as a child
            // note: play around with flex int value to adjust vertical spaces between widgets
            Text("Recreation page - first child"),
            Text("another text widget - second child"),
            Text("a third text widget - third child"),
          ],
        ),
      ),
    );
  }
}
