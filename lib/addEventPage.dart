import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:vanderhoof_app/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageSate createState() => _AddEventPageSate();
}

class _AddEventPageSate extends State<AddEventPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  bool multiday = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a New Event'),
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
                                    text: 'New Event information',
                                  ),
                                  SizedBox(height: 20),
                                  _getTextField(
                                      "title",
                                      "Event Title",
                                      "name of the event",
                                      Icon(Icons.shopping_basket_outlined)),
                                  _getTextField(
                                      "description",
                                      "Description",
                                      "description of event",
                                      Icon(Icons.description_outlined)),
                                  Column(
                                    children: <Widget>[
                                      FormBuilderCheckbox(
                                        initialValue: false,
                                        name: "dateCheckbox",
                                        title:
                                            Text("Is this a Multi-day Event?"),
                                        onChanged: (bool changed) {
                                          setState(() {
                                            multiday = changed;
                                          });
                                        },
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 15),
                                        child: (multiday)
                                            ? FormBuilderDateRangePicker(
                                                decoration: InputDecoration(
                                                  labelText: "Multi-Day Event",
                                                  hintText:
                                                      "pick  start and end date",
                                                  icon: Icon(Icons
                                                      .calendar_today_sharp),
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                      const Radius.circular(
                                                          10.0),
                                                    ),
                                                  ),
                                                ),
                                                name: "dateRange",
                                                firstDate: DateTime(2020),
                                                lastDate: DateTime(2021))
                                            : Column(
                                                children: [
                                                  FormBuilderDateTimePicker(
                                                    name: "datetimeStart",
                                                    validator:
                                                        FormBuilderValidators
                                                            .required(context),
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Event Date/Time",
                                                      hintText:
                                                          "pick date and time",
                                                      icon: Icon(Icons
                                                          .calendar_today_sharp),
                                                      floatingLabelBehavior:
                                                          FloatingLabelBehavior
                                                              .always,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                          const Radius.circular(
                                                              10.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        top: 15),
                                                    child: FormBuilderTextField(
                                                      keyboardType:
                                                          TextInputType.number,
                                                      name: "duration",
                                                      // onTap: () => {},
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            "Event duration",
                                                        hintText: "in hours",
                                                        icon: Icon(Icons
                                                            .description_outlined),
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .always,
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            const Radius
                                                                .circular(10.0),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20),
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
    String name,
    String labelText,
    String hintText,
    Icon icon,
  ) {
    var formValidator = FormBuilderValidators.required(context);

    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        name: name,
        validator: formValidator,
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

    CollectionReference fireStore =
        FirebaseFirestore.instance.collection('events');
    //=========================================
    //Method to add business to FireStore
    //=========================================
    Future<void> addEvent(Map<String, dynamic> event) {
      Map<String, dynamic> eventInfo = {...event};
      String docID = eventInfo['title'];
      if (docID.contains("/")) {
        docID = docID.replaceAll('/', '|');
      }
      if (multiday) {
        eventInfo['datetimeStart'] = eventInfo['dateRange'].start;
        eventInfo['datetimeEnd'] = eventInfo['dateRange'].end;
        eventInfo.remove('dateRange');
        eventInfo['duration'] = eventInfo['datetimeEnd']
            .difference(eventInfo['datetimeStart'])
            .inDays;
      } else {
        double duration = double.parse(eventInfo['duration']);
        int hour = duration.toInt();
        int min = (duration % 1 * 60).toInt();
        eventInfo['datetimeEnd'] =
            eventInfo['datetimeStart'].add(Duration(hours: hour, minutes: min));
      }
      return fireStore
          .doc()
          .set(eventInfo)
          .then((value) => {
                print("Event Added:  $docID"),
              })
          .catchError((error) => print("Failed to add Event: $error"));
    }

    //=========================================
    //Validate fields. If successful, then addBusiness()
    //=========================================
    final validationSuccess = _formKey.currentState.validate();
    if (validationSuccess) {
      _formKey.currentState.save();
      print("submitted data:  ${_formKey.currentState.value}");
      addEvent(_formKey.currentState.value);

      //Navigate back to Previous Page
      // Navigator.pop(context);
    }
  }
}
