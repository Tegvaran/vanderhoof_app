import 'package:flutter/material.dart';

class Event extends StatefulWidget {
  Event({Key key}) : super(key: key);

  final title = "Events";

  @override
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<Event> {
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
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // insert widgets here
            Text("Events page - first child"),
            Text("another text widget - second child"),
            Text("a third text widget - third child"),
          ],
        ),
      ),
    );
  }
}
