import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:getwidget/getwidget.dart';
import 'package:vanderhoof_app/main.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

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
                                  _getTextField(
                                      "name",
                                      "Name",
                                      "Vanderhoof Chamber of Commerce",
                                      Icon(Icons.account_balance)),
                                  _getTextField(
                                      "address",
                                      "Address",
                                      "188 E Stewart Street, Unit 11, PO Box 126, Vanderhoof, BC,",
                                      Icon(Icons.add_location_alt_outlined)),
                                  _getTextField("phone", "Phone",
                                      "604-123-1234", Icon(Icons.phone),
                                      phone: true),
                                  _getTextField("website", "Website",
                                      "www.example.com", Icon(Icons.web),
                                      url: true),
                                  _getTextField(
                                      "email",
                                      "Email",
                                      "example@gmail.com",
                                      Icon(Icons.email_outlined),
                                      email: true),
                                  _getTextField(
                                      "description",
                                      "Description",
                                      "description of business",
                                      Icon(Icons.description_outlined)),
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
      String name, String labelText, String hintText, Icon icon,
      {email = false, url = false, phone = false}) {
    var formValidator;
    if (email == true) {
      formValidator = FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        FormBuilderValidators.email(context)
      ]);
    } else if (url == true) {
      formValidator = FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        FormBuilderValidators.url(context)
      ]);
    } else if (phone == true) {
      formValidator = FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        (value) {
          value = value.replaceAll('-', '');
          if (!RegExp(r'^[0-9]+$').hasMatch(value) || value.length != 10) {
            return "This field must be a phone number";
          } else {
            return null;
          }
        }
      ]);
    } else {
      formValidator = FormBuilderValidators.required(context);
    }
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: FormBuilderTextField(
        name: name,
        validator: formValidator,
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

    CollectionReference business =
        FirebaseFirestore.instance.collection('businesses');
    //=========================================
    //Method to add business to FireStore
    //=========================================
    Future<void> addBusiness(Map<String, dynamic> businessInfo) {
      return business
          .add(businessInfo)
          .then((value) => {
                print("Business Added:  ${value.id}"),
                business.doc(value.id).update({"id": value.id})
              })
          .catchError((error) => print("Failed to add Business: $error"));
    }

    //=========================================
    //Validate fields. If successful, then addBusiness()
    //=========================================
    final validationSuccess = _formKey.currentState.validate();
    if (validationSuccess) {
      _formKey.currentState.save();
      print(_formKey.currentState.value);
      addBusiness(_formKey.currentState.value);

      //=========================================
      //Navigate back to Business Page
      //=========================================
      Navigator.pop(context);
    }
  }
}