import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:getwidget/getwidget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'fireStoreObjects.dart';
import 'main.dart';

import 'commonFunction.dart';

class AddHikePage extends StatefulWidget {
  final HikeTrail hike;

  AddHikePage({edit = false, this.hike}) {}

  @override
  _AddHikePageSate createState() => _AddHikePageSate(hike: hike);
}

class _AddHikePageSate extends State<AddHikePage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  HikeTrail hike;
  var difficultyOptions = ["Easy", "Medium", "Hard"];
  var wheelchairAccessibilityOptions = ["Accessible", "Inaccessible"];
  static var pointsOfInterest = [];

  _AddHikePageSate({this.hike});

  List<Widget> _getPoI() {
    print("************************************");
    List<Widget> poiTextFieldList = [];
    for (int i = 0; i < pointsOfInterest.length; i++) {
      poiTextFieldList.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: PoIFields(i),
            ),
            SizedBox(
              height: 20,
            ),
            _addRemoveButton(i == pointsOfInterest.length - 1, i),
          ],
        ),
      ));
    }
  }

  Widget _addRemoveButton(bool add, int index) {
    return InkWell(
      onTap: () {
        if (add) {
          pointsOfInterest.insert(0, null);
        } else
          pointsOfInterest.removeAt(index);
        setState(
          () {},
        );
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: (add) ? Colors.green : Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          (add) ? Icons.add : Icons.remove,
          color: Colors.white,
        ),
      ),
    );
  }

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
                                      true,
                                      initialValue:
                                          (hike == null) ? null : hike.name),
                                  _getTextField(
                                      "address",
                                      "Address",
                                      "188 E Stewart Street, Unit 11, PO Box 126, Vanderhoof, BC,",
                                      Icon(Icons.add_location_alt_outlined),
                                      true,
                                      initialValue:
                                          (hike == null) ? null : hike.address),
                                  _getTextField(
                                      "description",
                                      "Description",
                                      "Description of hike",
                                      Icon(Icons.description_outlined),
                                      false,
                                      initialValue: (hike == null)
                                          ? null
                                          : hike.description),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  FormBuilderDropdown(
                                      name: "difficulty",
                                      hint: Text("Difficulty"),
                                      decoration: InputDecoration(
                                        labelText:
                                            "Difficulty of the hike/trail",
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
                                          .toList(),
                                      initialValue:
                                          (hike == null) ? null : hike.rating),
                                  SizedBox(height: 20),
                                  FormBuilderDropdown(
                                      name: "wheelchair",
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
                                          .toList(),
                                      initialValue: (hike == null)
                                          ? null
                                          : hike.wheelchair),
                                  _getTextField(
                                      "distance",
                                      "Distance",
                                      "'1.35 km' or '540 m'",
                                      Icon(FontAwesomeIcons.road),
                                      false,
                                      initialValue: (hike == null)
                                          ? null
                                          : hike.distance),
                                  _getTextField(
                                      "time",
                                      "Time",
                                      "'2 hr' or '45 min'",
                                      Icon(FontAwesomeIcons.clock),
                                      false,
                                      initialValue:
                                          (hike == null) ? null : hike.time),
                                  SizedBox(height: 20),
                                  Text(
                                    "Highlights",
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
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
      {String initialValue}) {
    TextInputType inputType = TextInputType.text;
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        name: name,
        initialValue: initialValue,
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
        Map<String, dynamic> newHike = {
          ..._formKey.currentState.value,
          'imgURL': null,
          'location': geopoint,
          'pointsOfInterest': null,
        };
        if (hike != null) {
          _editHike(newHike);
        } else {
          addHike(newHike);
        }
        //=========================================
        //Navigate back to Business Page
        //=========================================
        Navigator.pop(context);
      });
    }
  }

  Future<void> addHike(Map<String, dynamic> hikeInfo) {
// Used to add businesses
    CollectionReference hike = FirebaseFirestore.instance.collection('trails');
    return hike
        .add(hikeInfo)
        .then((value) => {
              hike.doc(value.id).update({"id": value.id}),
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${hikeInfo['name']} updated")))
            })
        .catchError((error) => SnackBar(
            content: Text("Failed to add ${hikeInfo['name']} Error: $error")));
  }

  Future<void> _editHike(Map<String, dynamic> newHike) async {
    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('trails');
    fireStore
        .doc(hike.id)
        .update({
          'name': newHike['name'],
          'address': newHike['address'],
          'description': newHike['description'],
          'difficulty': newHike['difficulty'],
          'distance': newHike['distance'],
          'wheelchair': newHike['wheelchair'],
          'time': newHike['time']
        })
        .then((value) => {
              fireStore.doc(newHike['id']).update({"id": newHike['id']}),
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${newHike['name']} updated")))
            })
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "Failed to update ${newHike['name']} Error: $error"))));
  }
}

class PoIFields extends StatefulWidget {
  final int index;
  PoIFields(this.index);

  @override
  _PoIFieldsState createState() => _PoIFieldsState();
}

class _PoIFieldsState extends State<PoIFields> {
  TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameController.text =
          _AddHikePageSate.pointsOfInterest[widget.index] ?? '';
    });

    return TextFormField(
      controller: _nameController,
      onChanged: (v) => _AddHikePageSate.pointsOfInterest[widget.index] = v,
      decoration:
          InputDecoration(hintText: 'Enter the name of the point of interest'),
      validator: (v) {
        if (v.trim().isEmpty) return 'Please enter something';
        return null;
      },
    );
  }
}
