import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:getwidget/getwidget.dart';
import 'package:vanderhoof_app/main.dart';

import 'commonFunction.dart';
import 'data.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'dart:io';

class AddBusinessPage extends StatefulWidget {
  @override
  _AddBusinessPageSate createState() => _AddBusinessPageSate();
}

class _AddBusinessPageSate extends State<AddBusinessPage> {
  //* Form key
  final _formKey = GlobalKey<FormBuilderState>();
  List<dynamic> category;

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
                                  Container(
                                      margin: EdgeInsets.only(top: 15),
                                      child: Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              final _key =
                                                  GlobalKey<FormBuilderState>();
                                              showDialog(
                                                  context: context,
                                                  barrierDismissible:
                                                      false, // user must tap button!
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      insetPadding:
                                                          EdgeInsets.all(10),
                                                      title: Text(
                                                          'Confirm Deletion'),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: <Widget>[
                                                            Text(
                                                                'Are you sure you want to delete:'),
                                                            // _buildChips(this),
                                                            Center(
                                                              child:
                                                                  FormBuilder(
                                                                      key: _key,
                                                                      child: Column(
                                                                          children: [
                                                                            FormBuilderFilterChip(
                                                                                spacing: 5,
                                                                                name: "category",
                                                                                options: _buildFieldOptions()),
                                                                          ])),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          child: Text('Yes'),
                                                          onPressed: () {
                                                            _key.currentState
                                                                .save();
                                                            category = _key
                                                                    .currentState
                                                                    .value[
                                                                'category'];

                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: Text('Cancel'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                        ),
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Text('Category'),
                                          ),
                                          Container(
                                              margin: EdgeInsets.only(left: 15),
                                              child: Text((category == null)
                                                  ? ""
                                                  : category.join(', '))),
                                        ],
                                      )),
                                  FormBuilderImagePicker(
                                    name: 'image',
                                    // placeholderImage: (event != null)
                                    //     ? NetworkImage(event.imgURL)
                                    //     : null,
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
    TextInputType inputType = TextInputType.text;
    if (email == true) {
      inputType = TextInputType.emailAddress;
      formValidator = FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        FormBuilderValidators.email(context)
      ]);
    } else if (url == true) {
      inputType = TextInputType.url;
      formValidator = FormBuilderValidators.compose([
        FormBuilderValidators.required(context),
        FormBuilderValidators.url(context)
      ]);
    } else if (phone == true) {
      inputType = TextInputType.phone;
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
      File imgFile;
      // // String imgURL;
      if (_formKey.currentState.value['image'].isNotEmpty) {
        imgFile = _formKey.currentState.value['image'][0];
      }
      String address = _formKey.currentState.value['address'];
      toLatLng(address).then((geopoint) {
        Map<String, dynamic> business = {
          ..._formKey.currentState.value,
          'imgURL': null,
          'LatLng': geopoint,
          'socialMedia': {'facebook': ".", 'instagram': ".", 'twitter': "."},
          'category': category
        };
        business.remove('image');
        addBusiness(business, imageFile: imgFile);
        // print(business);

        //=========================================
        //Navigate back to Business Page
        //=========================================
        // Navigator.pop(context);
      });
    }
  }
}

List<FormBuilderFieldOption<dynamic>> _buildFieldOptions() {
  List<FormBuilderFieldOption<dynamic>> options = [];
  for (int i = 0; i < categoryOptions.length; i++) {
    options.add(FormBuilderFieldOption(
        value: categoryOptions[i],
        child: Text(categoryOptions[i], textScaleFactor: 0.9)));
  }
  return options;
}
