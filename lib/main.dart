import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'business.dart';
import 'recreation.dart';
import 'event.dart';
import 'hike.dart';
import 'commonFunction.dart';
import 'package:firebase_core/firebase_core.dart';

// ThemeData Colors
MaterialColor colorPrimary = createMaterialColor(Color(0xFF01579b));
MaterialColor colorText = createMaterialColor(Color(0xFF666666));
MaterialColor colorAccent = createMaterialColor(Color(0xFFf4a024));
MaterialColor colorBackground = createMaterialColor(Color(0xFFF3F3F3));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Vanderhoof App Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: colorPrimary,
          primaryColor: colorPrimary,
          accentColor: colorAccent,
          // canvasColor: colorBackground,
        ),
        home: FutureBuilder(
            future: _initialization,
            builder: (context, snapshot) {
              // Check for errors
              if (snapshot.hasError) {
                return Text("Something went wrong: ${snapshot.hasError}");
                // Once complete, show your application
              } else if (snapshot.connectionState == ConnectionState.done) {
                return MyHomePage(title: 'Landing Page');
              } else {
                // Otherwise, show something whilst waiting for initialization to complete
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final List<Widget> _children = [
    BusinessState(),
    Event(),
    Hike(),
    Recreation(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: _children[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // icon: Icon(Icons.business), // option 1: building
            icon: Icon(MdiIcons.briefcaseVariant), // option 2: briefcase
            label: 'Businesses',
            backgroundColor: colorPrimary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
            backgroundColor: colorPrimary,
          ),
          BottomNavigationBarItem(
            icon: Icon(MdiIcons.hiking), // hiking
            label: 'Hiking',
            backgroundColor: colorPrimary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bike),
            label: 'Recreational',
            backgroundColor: colorPrimary,
          )
        ],
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: colorAccent,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}
