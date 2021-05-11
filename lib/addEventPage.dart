import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:getwidget/getwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:vanderhoof_app/main.dart';
import 'package:vanderhoof_app/commonFunction.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vanderhoof_app/fireStoreObjects.dart';

class AddEventPage extends StatefulWidget {
  final Event event;
  AddEventPage({edit = false, this.event}) {
    print(event);
  }
  @override
  _AddEventPageState createState() => _AddEventPageState(event: event);
}

class _AddEventPageState extends State<AddEventPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  bool multiday = false;
  bool recurring = false;
  Event event;
  var recurringEventOptions = ['Weekly', 'Monthly'];

  _AddEventPageState({this.event});

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
                                    text: (event == null)
                                        ? 'New Event information'
                                        : "Edit Event",
                                  ),
                                  SizedBox(height: 20),
                                  _getTextField(
                                      name: "title",
                                      labelText: "Event Title",
                                      hintText: "name of the event",
                                      initialValue:
                                          (event == null) ? null : event.name,
                                      icon:
                                          Icon(Icons.shopping_basket_outlined)),
                                  _getTextField(
                                      name: "address",
                                      labelText: "Address",
                                      hintText: "address of event",
                                      initialValue: (event == null)
                                          ? null
                                          : event.address,
                                      icon: Icon(
                                          Icons.add_location_alt_outlined)),
                                  _getTextField(
                                      name: "description",
                                      labelText: "Description",
                                      hintText: "description of event",
                                      initialValue: (event == null)
                                          ? null
                                          : event.description,
                                      icon: Icon(Icons.description_outlined)),
                                  if (event == null)
                                    Row(
                                      children: [
                                        Flexible(
                                          child: FormBuilderCheckbox(
                                            initialValue: false,
                                            name: "dateCheckbox",
                                            title: Text(
                                                "Is this a Multi-day Event?"),
                                            onChanged: (bool changed) {
                                              setState(() {
                                                multiday = changed;
                                              });
                                            },
                                          ),
                                        ),
                                        Flexible(
                                          child: FormBuilderCheckbox(
                                            initialValue: false,
                                            name: "isRecurring",
                                            title: Text(
                                                "Is this a Recurring Event?"),
                                            onChanged: (bool changed) {
                                              setState(() {
                                                recurring = changed;
                                              });
                                            },
                                          ),
                                          ///////////////////////
                                          // child: FormBuilderDropdown(
                                          //     name: "recurring",
                                          //     hint: Text("None"),
                                          //     decoration: InputDecoration(
                                          //         labelText: "Recurring?"),
                                          //     allowClear: true,
                                          //     items: recurringEventOptions
                                          //         .map((choice) =>
                                          //             DropdownMenuItem(
                                          //                 value: choice,
                                          //                 child: Text("$choice")))
                                          //         .toList()),
                                          //  ///////////////////////////////////////
                                        )
                                      ],
                                    ),
                                  // The Container below only appears if recurring
                                  // is true.
                                  Container(
                                    margin: (event != null)
                                        ? EdgeInsets.only(top: 15)
                                        : EdgeInsets.only(top: 0),
                                    child: (recurring)
                                        ? Row(
                                            children: [
                                              Flexible(
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 15),
                                                      child:
                                                          FormBuilderDropdown(
                                                              validator:
                                                                  FormBuilderValidators
                                                                      .required(
                                                                          context),
                                                              name:
                                                                  "recurringType",
                                                              hint:
                                                                  Text("None"),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    "Recurring Type?",
                                                                icon: Icon(Icons
                                                                    .timer),
                                                                floatingLabelBehavior:
                                                                    FloatingLabelBehavior
                                                                        .always,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0),
                                                                  ),
                                                                ),
                                                              ),
                                                              allowClear: true,
                                                              items: recurringEventOptions
                                                                  .map((choice) =>
                                                                      DropdownMenuItem(
                                                                          value:
                                                                              choice,
                                                                          child:
                                                                              Text("$choice")))
                                                                  .toList()))),
                                              Flexible(
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: 15),
                                                      child:
                                                          FormBuilderDropdown(
                                                              validator:
                                                                  FormBuilderValidators
                                                                      .required(
                                                                          context),
                                                              hint:
                                                                  Text("1 - 6"),
                                                              name:
                                                                  "recurringRepeats",
                                                              decoration:
                                                                  InputDecoration(
                                                                icon: Spacer(),
                                                                labelText:
                                                                    "Number of times?",
                                                                floatingLabelBehavior:
                                                                    FloatingLabelBehavior
                                                                        .always,
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                    const Radius
                                                                            .circular(
                                                                        10.0),
                                                                  ),
                                                                ),
                                                              ),
                                                              allowClear: true,
                                                              items: List
                                                                      .generate(
                                                                          5,
                                                                          (i) =>
                                                                              i +
                                                                              1)
                                                                  .map((choice) =>
                                                                      DropdownMenuItem(
                                                                          value:
                                                                              choice,
                                                                          child:
                                                                              Text("$choice")))
                                                                  .toList())))
                                            ],
                                          )
                                        : null,
                                  ),
                                  // The Container below contains the dateRange
                                  // Picker OR the DateTime Picker, depending on
                                  // the boolean: multiday.
                                  Container(
                                    child: (multiday)
                                        ? FormBuilderDateRangePicker(
                                            decoration: InputDecoration(
                                              labelText: "Multi-Day Event",
                                              hintText:
                                                  "pick  start and end date",
                                              icon: Icon(
                                                  Icons.calendar_today_sharp),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  const Radius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                            name: "dateRange",
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime(2021))
                                        : Column(
                                            children: [
                                              FormBuilderDateTimePicker(
                                                initialValue: (event == null)
                                                    ? null
                                                    : event.datetimeStart,
                                                name: "datetimeStart",
                                                validator: FormBuilderValidators
                                                    .required(context),
                                                decoration: InputDecoration(
                                                  labelText: "Event Date/Time",
                                                  hintText:
                                                      "pick date and time",
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
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                child: FormBuilderTextField(
                                                  initialValue: (event == null)
                                                      ? null
                                                      : "${event.duration}",
                                                  keyboardType:
                                                      TextInputType.number,
                                                  name: "duration",
                                                  validator:
                                                      FormBuilderValidators
                                                          .required(context),
                                                  // onTap: () => {},
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Event duration (hr)",
                                                    hintText: "in hours",
                                                    icon: Icon(Icons
                                                        .description_outlined),
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .always,
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        const Radius.circular(
                                                            10.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
      {String name,
      String labelText,
      String hintText,
      Icon icon,
      String initialValue}) {
    var formValidator = FormBuilderValidators.required(context);

    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        initialValue: initialValue,
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
    Future<void> _addEvent(Map<String, dynamic> event, GeoPoint geoPoint) {
      void _addRepeatingEvent(var event, int repeats, {bool monthly = false}) {
        for (int i = 0; i < repeats; i++) {
          if (monthly) {
            event['datetimeStart'] = DateTime(event['datetimeStart'].year,
                event['datetimeStart'].month + 1, event['datetimeStart'].day);
            event['datetimeEnd'] = DateTime(event['datetimeEnd'].year,
                event['datetimeEnd'].month + 1, event['datetimeEnd'].day);
          } else {
            print("start");
            print(event['datetimeStart']);
            event['datetimeStart'] = DateTime(event['datetimeStart'].year,
                event['datetimeStart'].month, event['datetimeStart'].day + 7);
            print(event['datetimeStart']);
            event['datetimeEnd'] = DateTime(event['datetimeEnd'].year,
                event['datetimeEnd'].month, event['datetimeEnd'].day + 7);
          }

          fireStore
              .add(event)
              .then((value) => {
                    print("Event Added: ${value.id} : ${event['title']}"),
                    fireStore.doc(value.id).update({"id": value.id})
                  })
              .catchError((error) => print("Failed to add Event: $error"));
        }
      }

      Map<String, dynamic> eventInfo = {...event};
      eventInfo['LatLng'] = geoPoint;
      if (multiday) {
        eventInfo['datetimeStart'] = eventInfo['dateRange'].start;
        eventInfo['datetimeEnd'] = eventInfo['dateRange'].end;
        eventInfo.remove('dateRange');
        eventInfo['duration'] = eventInfo['datetimeEnd']
            .difference(eventInfo['datetimeStart'])
            .inDays;
      } else {
        eventInfo['duration'] = double.parse(eventInfo['duration']);
        int hour = eventInfo['duration'].toInt();
        int min = (eventInfo['duration'] % 1 * 60).toInt();
        eventInfo['datetimeEnd'] =
            eventInfo['datetimeStart'].add(Duration(hours: hour, minutes: min));
      }
      print("here $recurring");
      eventInfo['isRecurring'] = recurring;
      if (recurring) {
        print("here ${event['recurringType']}");
        if (event['recurringType'] == "Weekly") {
          print("weekly");
          _addRepeatingEvent(eventInfo, event['recurringRepeats']);
        } else if (event['recurringType'] == "Monthly") {
          print("monthly");
          _addRepeatingEvent(eventInfo, event['recurringRepeats'],
              monthly: true);
        }
      }

      return fireStore
          .add(eventInfo)
          .then((value) => {
                print("Event Added: ${value.id} : ${eventInfo['title']}"),
                fireStore.doc(value.id).update({"id": value.id})
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
      toLatLng(_formKey.currentState.value['address'])
          .then(
              (geopoint) => {_addEvent(_formKey.currentState.value, geopoint)})
          .catchError((error) => print(
              "Failed to get GeoPoint: $error for ${_formKey.currentState.value['address']}"));

      //Navigate back to Previous Page
      // Navigator.pop(context);
    }
  }
}
