import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:getwidget/getwidget.dart';

import 'commonFunction.dart';
import 'fireStoreObjects.dart';
import 'main.dart';

class AddEventPage extends StatefulWidget {
  final Event event;
  AddEventPage({edit = false, this.event});
  @override
  _AddEventPageState createState() => _AddEventPageState(event: event);
}

class _AddEventPageState extends State<AddEventPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  bool multiday = false;
  bool recurring = false;
  Event event;
  var recurringEventOptions = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  _AddEventPageState({this.event}) {
    if (event != null) {
      multiday = event.isMultiday;
    }
  }

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
                                          child: FormBuilderSwitch(
                                            initialValue: false,
                                            name: "isMultiday",
                                            title: Text("Multi-day Event?"),
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            onChanged: (bool changed) {
                                              setState(() {
                                                multiday = changed;
                                                recurring = false;
                                              });
                                            },
                                          ),
                                        ),
                                        (multiday)
                                            ? Spacer()
                                            : Flexible(
                                                child: FormBuilderSwitch(
                                                  initialValue: false,
                                                  name: "isRecurring",
                                                  title:
                                                      Text("Recurring Event?"),
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                  ),
                                                  onChanged: (bool changed) {
                                                    setState(() {
                                                      recurring = changed;
                                                    });
                                                  },
                                                ),
                                              )
                                      ],
                                    ),
                                  // The Container below only appears if recurring
                                  // is true.
                                  // The Container below contains the dateRange
                                  // Picker OR the DateTime Picker, depending on
                                  // the boolean: multiday.
                                  Container(
                                    margin: (event != null)
                                        ? EdgeInsets.only(top: 15)
                                        : null,
                                    child: (multiday)
                                        ? FormBuilderDateRangePicker(
                                            firstDate: (event != null)
                                                ? event.datetimeStart
                                                : DateTime.now(),
                                            lastDate: (event != null)
                                                ? event.datetimeEnd
                                                : DateTime.now()
                                                    .add(Duration(days: 365)),
                                            initialValue: (event != null)
                                                ? DateTimeRange(
                                                    start: event.datetimeStart,
                                                    end: event.datetimeEnd)
                                                : null,
                                            decoration: InputDecoration(
                                              labelText: "Multi-Day Event",
                                              hintText:
                                                  "pick start and end date",
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
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                child:
                                                    FormBuilderDateTimePicker(
                                                  initialValue: (event == null)
                                                      ? null
                                                      : event.datetimeStart,
                                                  name: "datetimeStart",
                                                  validator:
                                                      FormBuilderValidators
                                                          .required(context),
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Event Start Date/Time",
                                                    hintText:
                                                        "pick date and time",
                                                    icon: Icon(Icons
                                                        .calendar_today_sharp),
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
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                child:
                                                    FormBuilderDateTimePicker(
                                                  initialValue: (event == null)
                                                      ? null
                                                      : event.datetimeEnd,
                                                  name: "timeEnd",
                                                  inputType: InputType.time,
                                                  validator:
                                                      FormBuilderValidators
                                                          .compose([
                                                    FormBuilderValidators
                                                        .required(context),
                                                    (value) {
                                                      _formKey.currentState
                                                          .save();
                                                      DateTime startTime =
                                                          _formKey.currentState
                                                                  .value[
                                                              'datetimeStart'];
                                                      print(startTime);
                                                      print(value);
                                                    }
                                                  ]),
                                                  // FormBuilderValidators
                                                  //     .required(context),
                                                  decoration: InputDecoration(
                                                    labelText: "Event End Time",
                                                    hintText: "pick end time",
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

                                  Container(
                                    margin: (event != null)
                                        ? EdgeInsets.only(top: 15)
                                        : EdgeInsets.only(top: 0),
                                    child: (recurring)
                                        ? Column(
                                            children: [
                                              Container(
                                                  margin:
                                                      EdgeInsets.only(top: 15),
                                                  child: FormBuilderDropdown(
                                                      validator:
                                                          FormBuilderValidators
                                                              .required(
                                                                  context),
                                                      name: "recurringType",
                                                      hint: Text("None"),
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            "Recurring Type?",
                                                        icon: Icon(Icons.timer),
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
                                                      allowClear: true,
                                                      items: recurringEventOptions
                                                          .map((choice) =>
                                                              DropdownMenuItem(
                                                                  value: choice,
                                                                  child: Text(
                                                                      "$choice")))
                                                          .toList())),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 15),
                                                child:
                                                    FormBuilderDateTimePicker(
                                                  name: "recurringEnd",
                                                  validator:
                                                      FormBuilderValidators
                                                          .required(context),
                                                  inputType: InputType.date,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        "Recurring End Date",
                                                    hintText: "pick end date ",
                                                    icon: Icon(Icons
                                                        .calendar_today_sharp),
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
                                          )
                                        : null,
                                  ),
                                  FormBuilderImagePicker(
                                    name: 'image',
                                    enabled: true,
                                    initialValue:
                                        (event != null && event.imgURL != null)
                                            ? [event.imgURL]
                                            : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Pick Photo',
                                    ),
                                    maxImages: 1,
                                  ),
                                  SizedBox(height: 10),
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
                                      ))),
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
    //Method to add Event to FireStore
    //=========================================
    Future<void> _addEvent(Map<String, dynamic> event) async {
      File imgFile;
      // below is helper method to add repeating(recurring events)
      void _addRepeatingEvent(var event, {File imageFile}) {
        String repeatType = event['recurringType'];
        DateTime end =
            event['recurringEnd'].add(Duration(hours: 23, minutes: 59));
        event.remove('recurringType');
        event.remove('recurringEnd');
        while (event['datetimeStart'].isBefore(end)) {
          addEvent(event, fireStore, imageFile: imageFile);
          event['datetimeStart'] = addDateTime(
              dateTime: event['datetimeStart'], repeatType: repeatType);
          event['datetimeEnd'] = addDateTime(
              dateTime: event['datetimeEnd'], repeatType: repeatType);
        }
      }

      Map<String, dynamic> eventInfo = {...event};
      eventInfo['LatLng'] = null;
      if (multiday) {
        eventInfo['datetimeStart'] = eventInfo['dateRange'].start;
        eventInfo['datetimeEnd'] = eventInfo['dateRange'].end;
        eventInfo.remove('dateRange');
      } else {
        eventInfo['datetimeEnd'] = DateTime(
            event['datetimeStart'].year,
            event['datetimeStart'].month,
            event['datetimeStart'].day,
            event['timeEnd'].hour,
            event['timeEnd'].minute);
        eventInfo.remove('timeEnd');
      }

      if (eventInfo['image'] != null && eventInfo['image'].isNotEmpty) {
        /// NEW LINES FROM USER APP - JASON
        /// Compresses image file
        /// can delete comments after testing & migrating to admin app
        File compressedFile = await FlutterNativeImage.compressImage(
          eventInfo['image'][0],
          quality: 5,
        );
        imgFile = compressedFile;
      } else {
        eventInfo['imgURL'] = null;
      }
      eventInfo.remove('isRecurring');
      eventInfo.remove('image');
      if (recurring) {
        _addRepeatingEvent(eventInfo, imageFile: imgFile);
      } else {
        return addEvent(eventInfo, fireStore, imageFile: imgFile);
      }
    }

    Future<void> _editEvent(Map<String, dynamic> form) {
      if (form['image'] != null &&
          form['image'].isNotEmpty &&
          form['image'][0] != event.imgURL) {
        uploadFile(form['image'][0], event.id, "events").then((v) =>
            downloadURL(event.id, "events").then((imgURL) =>
                fireStore.doc(event.id).update({"imgURL": imgURL})));
      } else if (form['image'].isEmpty && event.imgURL != null) {
        fireStore.doc(event.id).update({"imgURL": null});
      }

      DateTime timeEnd = DateTime(
          form['datetimeStart'].year,
          form['datetimeStart'].month,
          form['datetimeStart'].day,
          form['timeEnd'].hour,
          form['timeEnd'].minute);
      fireStore
          .doc(event.id)
          .update({
            'title': form['title'],
            'address': form['address'],
            'description': form['description'],
            'datetimeStart': form['datetimeStart'],
            'datetimeEnd': timeEnd,
          })
          .then((value) => {
                print("Event updated: ${event.id} : ${event.name}"),
                fireStore.doc(event.id).update({"id": event.id})
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

      if (event == null) {
        print("adding event");
        _addEvent(_formKey.currentState.value);
      } else {
        print("editing event");
        _editEvent(_formKey.currentState.value);
      }

      // Navigate back to Previous Page
      setState(() {
        Navigator.pop(context);
      });
    }
  }
}
