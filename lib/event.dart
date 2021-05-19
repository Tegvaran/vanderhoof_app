import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'addEventPage.dart';
import 'cards.dart';
import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'main.dart';

bool eventFirstTime = true;
// Events populated from firebase
List<Event> events = [];

// Events after filtering search - this is whats shown in ListView
List<Event> filteredEvents = [];

class EventState extends StatefulWidget {
  EventState({Key key}) : super(key: key);

  final title = "Events";

  @override
  _EventPageState createState() => new _EventPageState();
}

class _EventPageState extends State<EventState> {
  bool isSearching = false;

  // Async Future variable that holds FireStore's data and functions
  Future future;
  // FireStore reference
  CollectionReference fireStore =
      FirebaseFirestore.instance.collection('events');

  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  /// firebase async method to get data
  Future _getEvents() async {
    if (eventFirstTime) {
      // if (true) {
      print("*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/*/");
      await fireStore.get().then((QuerySnapshot snap) {
        events = filteredEvents = [];
        snap.docs.forEach((doc) {
          Event e = Event(
            name: doc['title'],
            address: doc['address'],
            location: doc['LatLng'],
            description: doc["description"],
            datetimeEnd: doc['datetimeEnd'].toDate(),
            datetimeStart: doc['datetimeStart'].toDate(),
            id: doc['id'],
            isMultiday: doc['isMultiday'],
            imgURL: doc['imgURL'],
          );
          // print('event.dar: ${e.name}');
          events.add(e);
        });
      });
      eventFirstTime = false;
    }

    // sort all events by starting date
    events.sort((a, b) {
      var adate = a.datetimeStart;
      var bdate = b.datetimeStart;
      return adate.compareTo(bdate);
    });
    print('sorted: ' + events.toString());

    return events;
  }

  /// this method gets firebase data and populates into list of events
  @override
  void initState() {
    future = _getEvents();
    super.initState();
  }

  /// This method does the logic for search and changes filteredEvents to search results
  void _filterSearchItems(value) {
    setState(() {
      filteredEvents = events
          .where(
              (event) => event.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  /// Widget build for AppBar with Search
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
                  hintText: "Search Events",
                  hintStyle: TextStyle(color: Colors.white70)),
            ),
      actions: <Widget>[
        isSearching
            ? IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  _filterSearchItems("");
                  setState(() {
                    this.isSearching = false;
                    filteredEvents = events;
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

  /// Widget build for Events ListView
  Widget _buildEventsList() {
    //=================================================
    // Scrolling Listener + ScrollToTop Button
    //=================================================

    // listener for the current scroll position
    // if scroll position is not near the very top, set FloatingActionButton visibility to true
    _itemPositionsListener.itemPositions.addListener(() {
      int firstPositionIndex =
          _itemPositionsListener.itemPositions.value.first.index;
      setState(() {
        firstPositionIndex > 0
            ? _isScrollButtonVisible = true
            : _isScrollButtonVisible = false;
      });
    });

    Widget _buildScrollToTopButton() {
      return _isScrollButtonVisible
          ? FloatingActionButton(
              // scroll to top of the list
              child: FaIcon(FontAwesomeIcons.angleUp),
              shape: RoundedRectangleBorder(),
              foregroundColor: colorPrimary,
              mini: true,
              onPressed: () {
                _scrollController.scrollTo(
                  index: 0,
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              })
          : null;
    }

    //=================================================
    // Assistance Methods + DismissibleTile Widget
    //=================================================

    Widget _dismissibleTile(Widget child, int index) {
      final item = filteredEvents[index];
      return Dismissible(
          // direction: DismissDirection.endToStart,
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(item.name),
          // Provide a function that tells the app
          // what to do after an item has been swiped away.
          confirmDismiss: (direction) async {
            String confirm = 'Confirm Deletion';
            String bodyMsg = 'Are you sure you want to delete:';
            var function = () {
              setState(() {
                // Remove the item from the data source.
                deleteCard(item.name, item.id, index, fireStore).then((v) {
                  // remove event object visually (on the app)
                  filteredEvents.removeAt(index);
                  // Delete the Image from firebase storage (filename is ID, folder is 'events'
                  deleteFileFromID(item.id, 'events');

                  // Then show a snackbar.
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${item.name} deleted")));
                  Navigator.of(context).pop(true);
                });
              });
            };
            if (direction == DismissDirection.startToEnd) {
              confirm = 'Confirm to go to edit page';
              bodyMsg = "Would you like to edit this item?";
              function = () {
                // Navigator.of(context).pop(false);
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEventPage(event: item),
                    )).then((v) => setState(() {
                      _getEvents();
                    }));
                //
                //
              };
            }
            print(item.name);
            return await showDialog(
                context: context,
                barrierDismissible: false, // user must tap button!
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(confirm),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Text(bodyMsg),
                          Center(
                              child: Text(item.name,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Yes'),
                        onPressed: () {
                          function();
                        },
                      ),
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  );
                });
          },
          background: slideRightEditBackground(),
          secondaryBackground: slideLeftDeleteBackground(),
          child: child);
    }

    //=================================================
    // Build Widget for EventsList
    //=================================================
    return new Scaffold(
      body: Container(
          child: ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: filteredEvents.length,
        itemBuilder: (BuildContext context, int index) {
          //======================
          return _dismissibleTile(
              EventCard(filteredEvents[index], _scrollController, index),
              index);
        },
      )),
      floatingActionButton: _buildScrollToTopButton(),
    );
  }

  ///=========================
  /// Final Build Widget
  ///=========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSearchAppBar(),
      body: Container(
        padding: EdgeInsets.all(0.0),
        child: FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                print("FutureBuilder snapshot.connectionState => none");
                return showLoadingScreen();
              case ConnectionState.active:
              case ConnectionState.waiting:
                return showLoadingScreen();
              case ConnectionState.done:
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // insert widgets here wrapped in `Expanded` as a child
                    // note: play around with flex int value to adjust vertical spaces between widgets
                    Expanded(
                        flex: 1,
                        child: filteredEvents.length != 0
                            ? _buildEventsList()
                            : Container(
                                child: Center(
                                child: Text("No results found",
                                    style: titleTextStyle),
                              ))),
                  ],
                );
              default:
                return Text("Default");
            }
          },
        ),
      ),
    );
  }
}
