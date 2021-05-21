import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'business.dart';
import 'commonFunction.dart';
import 'event.dart';
import 'hike.dart';
import 'recreation.dart';
import 'resource.dart';

// ThemeData Colors
MaterialColor colorPrimary = createMaterialColor(Color(0xFF01579b));
MaterialColor colorText = createMaterialColor(Color(0xFF666666));
MaterialColor colorAccent = createMaterialColor(Color(0xFFf4a024));
MaterialColor colorBackground = createMaterialColor(Color(0xFFF3F3F3));

Divider cardDivider = Divider(height: 5, thickness: 4, color: colorAccent);
BoxShadow iconShadow = BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    blurRadius: 3,
    spreadRadius: 3,
    offset: Offset(0, 4));

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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool isLandingPage = true;
  AnimationController _controller;
  Animation<Offset> _animation;

  final List<Widget> _children = [
    BusinessState(),
    ResourceState(),
    EventState(),
    Hike(),
    Recreation(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    Timer(Duration(milliseconds: 200), () => _controller.forward());

    _animation = Tween<Offset>(
      begin: Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    ));
  }

  /// build for an action with a slide-in animation
  /// button slides in from the right to it's original position
  /// also has a slight face in
  Widget buildAnimatedSlideInAction(Widget childWidget) {
    return Builder(
      builder: (context) => Center(
        child: SlideTransition(
          position: _animation,
          transformHitTests: true,
          textDirection: TextDirection.ltr,
          child: FadeTransition(opacity: _controller, child: childWidget),
        ),
      ),
    );
  }

  /// build for a GoToPage button, will navigate to pageIndex when selected
  Widget buildGoToPageButton(Widget pageIcon, String pageName, int pageIndex) {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Align(
          alignment: Alignment.center,
          child: TextButton.icon(
              style: TextButton.styleFrom(
                  backgroundColor: colorPrimary,
                  primary: colorAccent,
                  minimumSize: Size(230, 45),
                  elevation: 3,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  )),
              icon: pageIcon,
              label: Text('$pageName',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  )),
              onPressed: () {
                setState(() {
                  isLandingPage = false;
                  _selectedIndex = pageIndex;
                });
              }),
        ));
  }

  /// build for a Landing Page, select a page to navigate out of it
  Widget buildLandingPage() {
    return Container(
      // comment out 'decoration' argument to hide background image
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage("assets/images/vanderhoof_chamber_background.jpg"),
        fit: BoxFit.cover,
      )),
      width: double.infinity,
      height: double.infinity,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: buildAnimatedSlideInAction(
                Column(
                  children: [
                    Container(
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.8)),
                      child: Image(
                          image: AssetImage(
                              'assets/images/vanderhoof_chamber_logo_large.png')),
                    ),
                    buildGoToPageButton(Icon(MdiIcons.briefcaseVariant),
                        'Business Directory', 0),
                    buildGoToPageButton(FaIcon(FontAwesomeIcons.infoCircle),
                        'Business Resources', 1),
                    buildGoToPageButton(Icon(Icons.event), 'Events', 2),
                    buildGoToPageButton(
                        Icon(MdiIcons.hiking), 'Hiking Trails', 3),
                    buildGoToPageButton(
                        Icon(Icons.directions_bike), 'Recreational', 4),
                  ],
                ),
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: isLandingPage ? buildLandingPage() : _children[_selectedIndex],
      bottomNavigationBar: isLandingPage
          ? Container(width: 0, height: 0)
          : BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(MdiIcons.briefcaseVariant),
                  label: 'Businesses',
                  backgroundColor: colorPrimary,
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.infoCircle),
                  label: 'Resources',
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
