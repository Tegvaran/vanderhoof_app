import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:getwidget/getwidget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:vanderhoof_app/main.dart';

import 'commonFunction.dart';

class AddHikePage extends StatefulWidget {
  @override
  _AddHikePageSate createState() => _AddHikePageSate();
}

class _AddHikePageSate extends State<AddHikePage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  var difficultyOptions = ["Easy", "Medium", "Hard"];
  var wheelchairAccessibilityOptions = ["Accessible", "Inaccessible"];
  var pointsOfInterest = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Hike'),
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
                                    text: 'Hike/Trail information',
                                  ),
                                  SizedBox(height: 20),
                                  _getTextField(
                                      "name",
                                      "Name",
                                      "Riverside Nature Trail",
                                      Icon(MdiIcons.hiking),
                                      true),
                                  _getTextField(
                                      "address",
                                      "Address",
                                      "188 E Stewart Street, Unit 11, PO Box 126, Vanderhoof, BC,",
                                      Icon(Icons.add_location_alt_outlined),
                                      true),
                                  _getTextField(
                                      "description",
                                      "Description",
                                      "Description of hike",
                                      Icon(Icons.description_outlined),
                                      false),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FormBuilderDropdown(
                                      name: "Difficulty",
                                      hint: Text("Difficulty"),
                                      decoration: InputDecoration(
                                        labelText:
                                            "Difficluty of the hike/trail",
                                        icon:
                                            Icon(FontAwesomeIcons.exclamation),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      allowClear: true,
                                      items: difficultyOptions
                                          .map((choice) => DropdownMenuItem(
                                              value: choice,
                                              child: Text("$choice")))
                                          .toList()),
                                  SizedBox(height: 20),
                                  FormBuilderDropdown(
                                      name: "Wheelchair Accessibility",
                                      hint: Text(
                                          "Is the hike/trail wheelchair accessible?"),
                                      decoration: InputDecoration(
                                        labelText: "Wheelchair Accessibility",
                                        icon: Icon(FontAwesomeIcons.wheelchair),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(
                                            const Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      allowClear: true,
                                      items: wheelchairAccessibilityOptions
                                          .map((choice) => DropdownMenuItem(
                                              value: choice,
                                              child: Text("$choice")))
                                          .toList()),
                                  _getTextField(
                                      "distance",
                                      "Distance",
                                      "'1.35 km' or '540 m'",
                                      Icon(FontAwesomeIcons.road),
                                      false),
                                  _getTextField(
                                      "time",
                                      "Time",
                                      "'2 hr' or '45 min'",
                                      Icon(FontAwesomeIcons.clock),
                                      false),
                                  IconButton(
                                      icon: Icon(Icons.cancel),
                                      onPressed: () {
                                        return "";
                                      }),
                                  Row(
                                    children: [
                                      const Spacer(),
                                      Expanded(
                                          child: Center(
                                              child: ElevatedButton(
                                        onPressed: _onSubmitPressed,
                                        child: Text('Submit'),
                                      ))),
                                      Expanded(
                                          child: Center(
                                              child: ElevatedButton(
                                        onPressed: () {
                                          _formKey.currentState.reset();
                                          // unfocus keyboard
                                          FocusScope.of(context).unfocus();
                                        },
                                        child: Text('Reset'),
                                      ))),
                                      Expanded(
                                          child: Center(
                                              child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      )))
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _getTextField(
      String name, String labelText, String hintText, Icon icon, required) {
    TextInputType inputType = TextInputType.text;
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        name: name,
        validator: (value) {
          if (!required) {
            return null;
          } else {
            if (value == null || value.trim() == "") {
              return "This is a required field";
            } else {
              return null;
            }
          }
        },
        keyboardType: inputType,
        // onTap: () => {},
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          icon: icon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(10.0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createPointOfInterest() {}

  void _onSubmitPressed() {
    print("-------------Submit clicked------------");

    //=========================================
    //Validate fields. If successful, then addBusiness()
    //=========================================
    final validationSuccess = _formKey.currentState.validate();
    if (validationSuccess) {
      _formKey.currentState.save();
      print("submitted data:  ${_formKey.currentState.value}");
      String address = _formKey.currentState.value['address'];
      toLatLng(address).then((geopoint) {
        Map<String, dynamic> hike = {
          ..._formKey.currentState.value,
          'imgURL': null,
          'LatLng': geopoint,
        };
        addHike(hike);
        print(hike);
        //=========================================
        //Navigate back to Business Page
        //=========================================
        Navigator.pop(context);
      });
    }
  }
}
