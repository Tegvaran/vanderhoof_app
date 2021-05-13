import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:getwidget/getwidget.dart';
import 'package:vanderhoof_app/main.dart';

import 'commonFunction.dart';

class AddRecPage extends StatefulWidget {
  @override
  _AddRecPageSate createState() => _AddRecPageSate();
}

class _AddRecPageSate extends State<AddRecPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  var difficultyOptions = ["Easy", "Medium", "Hard"];
  var wheelchairAccessibilityOptions = ["Accessible", "Inaccessible"];
  static var pointsOfInterest = [];

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
                                    text: 'Recreational Activity Information',
                                  ),
                                  SizedBox(height: 20),
                                  _getTextField(
                                      "name",
                                      "Name",
                                      "Name of the Recreational Activity",
                                      Icon(Icons.directions_bike),
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
                                  _getTextField("email", "Email", "Email",
                                      Icon(FontAwesomeIcons.road), false,
                                      email: true),
                                  _getTextField(
                                      "phone",
                                      "Phone Number",
                                      "Phone Number",
                                      Icon(FontAwesomeIcons.clock),
                                      false,
                                      phone: true),
                                  SizedBox(height: 20),
                                  _getTextField("website", "Website", "Website",
                                      Icon(FontAwesomeIcons.clock), false,
                                      url: true),
                                  SizedBox(
                                    height: 20,
                                  ),
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
      String name, String labelText, String hintText, Icon icon, required,
      {email = false, url = false, phone = false}) {
    var formValidator;
    TextInputType inputType = TextInputType.text;
    if (email == true) {
      inputType = TextInputType.emailAddress;
      formValidator =
          FormBuilderValidators.compose([FormBuilderValidators.email(context)]);
    } else if (url == true) {
      inputType = TextInputType.url;
      formValidator =
          FormBuilderValidators.compose([FormBuilderValidators.url(context)]);
    } else if (phone == true) {
      inputType = TextInputType.phone;
      formValidator = FormBuilderValidators.compose([
        (value) {
          value = value.replaceAll('-', '');
          if (!RegExp(r'^[0-9]+$').hasMatch(value) || value.length != 10) {
            return "This field must be a phone number";
          } else {
            return null;
          }
        }
      ]);
    }
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
        Map<String, dynamic> rec = {
          ..._formKey.currentState.value,
          'LatLng': geopoint,
        };
        addRec(rec);
        print(rec);
        //=========================================
        //Navigate back to Business Page
        //=========================================
        Navigator.pop(context);
      });
    }
  }
}
