import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

// import 'package:ffb_tutorial/screens/basics/formbuilder/examples/onWillPop.dart';
import 'package:getwidget/getwidget.dart';
import 'package:vanderhoof_app/main.dart';

class AddBusinessPage extends StatefulWidget {
  @override
  _AddBusinessPageSate createState() => _AddBusinessPageSate();
}

class _AddBusinessPageSate extends State<AddBusinessPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Business'),
        backgroundColor: colorPrimary,
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FormBuilder(
                              key: _formKey,
                              child: Column(
                                children: [
                                  GFTypography(
                                    type: GFTypographyType.typo1,
                                    text: 'Business information',
                                  ),
                                  SizedBox(height: 20),
                                  _getTextField("bus_name", "Name"),
                                  _getTextField("address", "Address"),
                                  _getTextField("phone", "Phone"),
                                  _getTextField("website", "Website"),
                                  _getTextField("email", "Email"),
                                  _getTextField("description", "Description"),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: Text('Submit'),
                                  )
                                ],
                              ),
                              onChanged: () => print('changed'),
                              autovalidateMode: null,
                              onWillPop: null,
                              initialValue: null,
                              skipDisabled: null,
                              enabled: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTextField(String name, String hintText) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        name: name,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
          hintText: hintText,
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //     appBar: AppBar(
  //       title: Text("Add")
  //     )
  //       title: "Add a New Business",
  //       home: Scaffold(
  //         body: FormBuilder(key: ),
  //       ));
  // }
}
