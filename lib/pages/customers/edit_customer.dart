import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../model/customer.dart';
import '../../model/nav_bools.dart';
import '../../widgets/topnavigationbaredit.dart';

class EditCustomer extends StatefulWidget {

  @override
  State<EditCustomer> createState() => _EditCustomerState();
}

class _EditCustomerState extends State<EditCustomer> {
  String memail = "", mphone2 = "", mzip = "", mcity = "";

  final _conmanname = TextEditingController();
  final _conmanphone = TextEditingController();
  final _conmanaddress = TextEditingController();
  final _conmanprevbal = TextEditingController();
  final _conmanemail = TextEditingController();
  final _conmanphone2 = TextEditingController();
  final _conmancity = TextEditingController();
  final _conmanzip = TextEditingController();

  _addCustomer(Customer cst) async {
    String mname = _conmanname.text;
    String mphone = _conmanphone.text;
    String maddress = _conmanaddress.text;
    String mprebal = _conmanprevbal.text;
    memail = _conmanemail.text;
    mphone2 = _conmanphone2.text;
    mzip = _conmanzip.text;
    mcity = _conmancity.text;

    if (mname.isEmpty ||
        mphone.isEmpty ||
        maddress.isEmpty ||
        mprebal.isEmpty) {
      
      Get.snackbar("Invalid Format.",
                     "Customer's Name, Phone, Address and Previous Balance is Required",
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                      margin: EdgeInsets.zero,
                      duration: const Duration(milliseconds: 2000),
                      boxShadows: [
                        BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                      ],
                      borderRadius: 0);
    } else {
      FirebaseFirestore.instance.collection('Customer').doc(cst.id).update({
        'Name': mname,
        'Phone': mphone,
        'Phone2': mphone2,
        'Address': maddress,'User':AuthService.to.user?.name,
        'Email': memail,
        'Balance': double.parse(mprebal),
        'Zip Code': mzip,
        'City': mcity
      }).then((valu) {
        Get.back(result: 'update');
      Get.snackbar("Saved Customer Successfully.",
                     "Redirected to Customer List Page!",
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.green,
                      margin: EdgeInsets.zero,
                      duration: const Duration(milliseconds: 2000),
                      boxShadows: [
                        BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                      ],
                      borderRadius: 0);
      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  void _addinit(Customer cst) {
    _conmanname.text = cst.name;
    _conmanphone.text = cst.phone1;
    _conmanaddress.text = cst.address;
    _conmanprevbal.text = cst.balance.toString();
    _conmanemail.text = cst.email;
    _conmanphone2.text = cst.phone2;
    _conmancity.text = cst.city;
    _conmanzip.text = cst.zip;

  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    var arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    var cst = Customer.fromJson(jsonDecode(arguments['Customer']));
    _addinit(cst);

    return Scaffold(
      appBar: MyAppBarEdit(height: _height,width: _width),
      body:SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.only(
              top: 20, left: _width / 6, right: _width / 6, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                  text: "Edit Customer", size: 32, weight: FontWeight.bold),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "Customer's Name",
                          size: 16,
                        )),
                    const Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: CustomText(
                        text: "Phone Number",
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmanname,
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
                            hintText: "Customers Name",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmanphone,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                            hintText: "Phone Number",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "Address",
                          size: 16,
                        )),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: CustomText(
                        text: "Email",
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmanaddress,
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
                            hintText: "Customers Address",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmanemail,
                          keyboardType: TextInputType.emailAddress,
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
                            hintText: "Email",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "City",
                          size: 16,
                        )),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: CustomText(
                        text: "Phone Number 2",
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmancity,
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
                            hintText: "City",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmanphone2,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                            hintText: "Phone Number 2",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "Zip",
                          size: 16,
                        )),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: CustomText(
                        text: "Previous Balance",
                        size: 16,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _conmanzip,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                            hintText: "Zip Code",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(
                        child: TextFormField(
                          controller: _conmanprevbal,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
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
                            hintText: "Previous Balance",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: ElevatedButton(
                          onPressed: () {
                            _addCustomer(cst);
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
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
