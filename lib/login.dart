import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    this.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('App Name'),
      ),
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    "Login Page",
                    style: new TextStyle(fontSize:20.0,
                        color: const Color(0xFF000000),
                        fontWeight: FontWeight.w400,
                        fontFamily: "Roboto"),
                  )
                ]

            ),

            new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "Email Address:",
                          style: new TextStyle(fontSize:13.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w300,
                              fontFamily: "Roboto"),
                        ),

                        new TextField(
                          style: new TextStyle(fontSize:12.0,
                              color: const Color(0xFF000000),
                              fontWeight: FontWeight.w200,
                              fontFamily: "Roboto"),
                              controller: emailController,
                        ),

                        new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Text(
                                      "Password:",
                                      style: new TextStyle(fontSize:13.0,
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.w300,
                                          fontFamily: "Roboto"),
                                    ),

                                    new TextField(
                                      style: new TextStyle(fontSize:12.0,
                                          color: const Color(0xFF000000),
                                          fontWeight: FontWeight.w200,
                                          fontFamily: "Roboto"),
                                          controller: passwordController,
                                    ),

                                    new Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          new RaisedButton(key:null, onPressed:buttonPressed,
                                              color: const Color(0xFFe0e0e0),
                                              child:
                                              new Text(
                                                "Login",
                                                style: new TextStyle(fontSize:13.0,
                                                    color: const Color(0xFF000000),
                                                    fontWeight: FontWeight.w200,
                                                    fontFamily: "Roboto"),
                                              )
                                          )
                                        ]

                                    )
                                  ]

                              )
                            ]

                        )
                      ]

                  )
                ]

            ),

            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),

            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
            )
          ]

      ),

    );
  }
  void buttonPressed(){
    String email = emailController.text;
    String password = passwordController.text;
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      //input is incorrect
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Error"),
            content: new Text("Issue logging in. Double check the entered email and password"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      auth.signInWithEmailAndPassword(email: email, password: password);
    }

  }

}