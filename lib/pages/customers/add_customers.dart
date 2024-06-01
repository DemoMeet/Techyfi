import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import 'package:get/get.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddCustomer extends StatefulWidget {
  
  Navbools nn;
  AddCustomer({required  this.nn});
  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  String cemail = "", cphone2 = "", czip = "", ccity = "";
  final _concustname = TextEditingController();
  final _concustphone = TextEditingController();
  final _concustaddress = TextEditingController();
  final _concustprevbal = TextEditingController();
  final _concustemail = TextEditingController();
  final _concustphone2 = TextEditingController();
  final _concustcity = TextEditingController();
  final _concustzip = TextEditingController();

  _addcustomer() async {
    String cname = _concustname.text;
    String cphone = _concustphone.text;
    String caddress = _concustaddress.text;
    String cprebal = _concustprevbal.text;
    cemail = _concustemail.text;
    cphone2 = _concustphone2.text;
    czip = _concustzip.text;
    ccity = _concustcity.text;

    if (cname.isEmpty ||
        cphone.isEmpty ||
        caddress.isEmpty ||
        cprebal.isEmpty) {
      Get.snackbar("Customer Adding Failed.",
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
      const _chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      Random _rnd = Random();
      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length,
                  (_) => _chars.codeUnitAt(
                  _rnd.nextInt(_chars.length))));
      String ss = getRandomString(20);
      FirebaseFirestore.instance.collection('Customer').doc(ss).set({
        'Name': cname,
        'Phone': cphone,
        'Phone2': cphone2,
        'Address': caddress,'User':AuthService.to.user?.name,
        'Balance': double.parse(cprebal),
        'Email': cemail,
        'UID':ss,
        'Zip Code': czip,
        'City': ccity
      }).then((value) {
        widget.nn.setnavbool();
        widget.nn.customer = true;
        widget.nn.customer_list = true;
        Get.offNamed(customerlistPageRoute);
      Get.snackbar("Customer Added Successfully.",
                      "Redirecting to Customer List Page.",
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

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

 
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar:MyAppBar(height: _height,width:  _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn,),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: _height / 8, left: 30, right: _width / 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "Add Customer", size: 32, weight: FontWeight.bold),
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
                                    controller: _concustname,
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
                                    controller: _concustphone,
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
                                    controller: _concustaddress,
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
                                    controller: _concustemail,
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
                                    controller: _concustcity,
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
                                    controller: _concustphone2,
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
                                    controller: _concustzip,
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
                                    controller: _concustprevbal,
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
                                      _addcustomer();
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
                )),
          ],
        )));
  }
}
