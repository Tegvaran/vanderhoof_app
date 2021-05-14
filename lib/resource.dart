import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'commonFunction.dart';
import 'cards.dart';
import 'fireStoreObjects.dart';
import 'main.dart';
import 'recreation.dart';

bool resourceFirstTime = true;

// Events populated from firebase
List<Resource> resources = [];

// Events after filtering search - this is whats shown in ListView
List<Resource> filteredResources = [];

class ResourceState extends StatefulWidget {
  ResourceState({Key key}) : super(key: key);

  final title = "Business Resources";

  @override
  _ResourcePageState createState() => new _ResourcePageState();
}

class _ResourcePageState extends State<ResourceState> {
  bool isSearching = false;

  // Async Future variable that holds FireStore's data and functions
  Future future;
  // FireStore reference
  CollectionReference fireStore =
      FirebaseFirestore.instance.collection('resources');

  // Controllers to check scroll position of ListView
  ItemScrollController _scrollController = ItemScrollController();
  ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();
  bool _isScrollButtonVisible = false;

  /// firebase async method to get data
  Future _getResources() async {
    if (recreationFirstTime) {
      print("*/*/*/*/*/*/*/*/**/*/*/*/*/*/*/*/*/*/*/*/*/*/**/*/*");
      await fireStore.get().then((QuerySnapshot snap) {
        resources = filteredResources = [];
        snap.docs.forEach((doc) {
          Resource resource = Resource(
              doc['name'], doc['description'], doc['website'], doc['id']);
          resources.add(resource);
        });
      });
      resourceFirstTime = false;
    }

    return resources;
  }

  /// this method gets firebase data and populates into list of events
  @override
  void initState() {
    future = _getResources();
    super.initState();
  }

  /// This method does the logic for search and changes filteredEvents to search results
  void _filterSearchItems(value) {
    setState(() {
      filteredResources = resources
          .where((resource) =>
              resource.name.toLowerCase().contains(value.toLowerCase()))
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
                  hintText: "Search Business Resources",
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
                    filteredResources = resources;
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
  Widget _buildResourcesList() {
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
      final item = filteredResources[index];
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
              // _deleteBusiness(item.name, index);
              deleteCard(item.name, item.id, index, fireStore).then((v) {
                // Remove the item from the data source.
                setState(() {
                  filteredResources.removeAt(index);
                });
                // Then show a snackbar.
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${item.name} deleted")));

                Navigator.of(context).pop(true);
              });
            };
            //// todo: AddResourcePage.dart and uncomment this edit feature
            // if (direction == DismissDirection.startToEnd) {
            //   confirm = 'Confirm to go to edit page';
            //   bodyMsg = "Would you like to edit this item?";
            //   function = () {
            //     // Navigator.of(context).pop(false);
            //     Navigator.pop(context);
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => AddResourcePage(Resource: item),
            //         ));
            //     //
            //     //
            //   };
            // }
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
    // Build Widget for ResourcesList
    //=================================================
    return new Scaffold(
      body: Container(
          child: ScrollablePositionedList.builder(
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemCount: filteredResources.length,
        itemBuilder: (BuildContext context, int index) {
          //======================
          return _dismissibleTile(
              ResourceCard(filteredResources[index], _scrollController, index),
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
                    Image(
                        image: AssetImage(
                            'assets/images/vanderhoof_chamber_logo_large.png')),
                    Expanded(flex: 1, child: _buildResourcesList()),
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
