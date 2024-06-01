import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:groceyfi02/widgets/custom_text.dart';
import 'package:path/path.dart' as path;

import '../../constants/style.dart';
import '../../model/products.dart';
import '../../model/Single.dart';
import '../../widgets/topnavigationbaredit.dart';
import '../../model/general.dart';

class EditUnit extends StatefulWidget {
  @override
  State<EditUnit> createState() => _EditUnitState();
}

class _EditUnitState extends State<EditUnit> {
  final _conUnitname = TextEditingController();
  bool isfirst = true;

  int _sts = 1;
  void _addinit(General gs) {
    print(_sts);
    _conUnitname.text = gs.name;
    if (gs.status == "Active") {
      _sts = 1;
    } else {
      _sts = 2;
    }
    setState(() {});
  }

  _editUnit(General gs) async {
    String cname = _conUnitname.text;
    bool cstats = true;
    if (_sts == 2) {
      cstats = false;
    }

    if (cname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Unit Name is Required"),
      ));
    } else {
      FirebaseFirestore.instance.collection('Unit').doc(gs.id).update({
        'Name': cname,
        'status': cstats,
      }).then((value) {
        Get.back();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Unit Updated Successfully!"),
        ));
      }).catchError((error) => print("Failed to add Unit: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    var arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    var cst = General.fromJson(jsonDecode(arguments['General']));
    if (isfirst) {
      _addinit(cst);
      isfirst = false;
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: MyAppBarEdit(height: _height, width: _width),
      body: Container(
        margin: EdgeInsets.only(top: _height / 8, left: 30, right: _width / 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: "Edit Unit", size: 32, weight: FontWeight.bold),
            Container(
              margin: EdgeInsets.only(top: _height / 5, left: 10, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 1,
                    ),
                    flex: 4,
                  ),
                  Expanded(
                      flex: 5,
                      child: CustomText(
                        text: "Unit Name",
                        size: 16,
                      )),
                  Expanded(
                    flex: 10,
                    child: Container(
                      child: TextFormField(
                        controller: _conUnitname,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          hintText: "Unit Name",
                          fillColor: Colors.grey.shade200,
                          filled: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 10),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 1,
                    ),
                    flex: 6,
                  ),
                  Expanded(
                      flex: 5,
                      child: CustomText(
                        text: "Status",
                        size: 16,
                      )),
                  Expanded(
                    flex: 13,
                    child: Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Column(
                        children: [
                          RadioListTile(
                            title: Text("Active"),
                            value: 1,
                            groupValue: _sts,
                            onChanged: (value) {
                              setState(() {
                                _sts = int.parse(value.toString());
                              });
                            },
                          ),
                          RadioListTile(
                            title: Text("Deactivate"),
                            value: 2,
                            groupValue: _sts,
                            onChanged: (value) {
                              setState(() {
                                _sts = int.parse(value.toString());
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 1,
                    ),
                    flex: 11,
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      child: ElevatedButton(
                        onPressed: () {
                          _editUnit(cst);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonbg,
                          elevation: 20,
                          padding: EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: CustomText(
                          text: "Submit",
                          weight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
  }
}
