import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../helpers/auth_service.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';

class AddLendingPerson extends StatefulWidget {
  
  Navbools nn;
  AddLendingPerson({required this.nn});
  @override
  State<AddLendingPerson> createState() => _AddLendingPersonState();
}

class _AddLendingPersonState extends State<AddLendingPerson> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _concustname = TextEditingController();
  final _concustphone = TextEditingController();
  final _concustaddress = TextEditingController();
  final _concustnidnumber = TextEditingController();
  final _concustphone2 = TextEditingController();
  final _concustreference = TextEditingController();


  _addlendingperson() async {
    String cname = _concustname.text;
    String cphone = _concustphone.text;
    String caddress = _concustaddress.text;
    String cnidnumber = _concustnidnumber.text;
    String cphone2 = _concustphone2.text;
    String creference = _concustreference.text;

    if (cname.isEmpty ||
        cphone.isEmpty ||
        caddress.isEmpty ||
        creference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Person's Name, Phone, Address and Reference is Required"),
      ));
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
      FirebaseFirestore.instance.collection('LendingPerson').doc(ss).set({
        'Name': cname,
        'Phone': cphone,
        'Phone2': cphone2,'User':AuthService.to.user?.name,
        'Address': caddress,
        'NID': cnidnumber,
        'UID':ss,
        'Reference': creference
      }).then((value) {
        widget.nn.setnavbool();
        widget.nn.human_resource = true;
        widget.nn.human_resource_lending = true;
        widget.nn.human_resource_lendingpersonlist = true;
        Get.offNamed(lendingpersonlistPageRoute);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green,
          content: Text("Person Added Successfully!"),
        ));
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
                : SideMenuSmall(widget.nn, ),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: _height / 8, left: 30, right: _width / 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "Add Lending Person", size: 32, weight: FontWeight.bold),
                        Container(
                          margin: EdgeInsets.only(top: _height / 12, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Person's Name",
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
                                      hintText: "Person's Name",
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
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
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
                                  text: "Nation ID Number",
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
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                      hintText: "Person's Address",
                                      fillColor: Colors.grey.shade200,
                                      filled: true,
                                    ),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: SizedBox(
                                  height: 1,
                                ),
                                flex: 1,
                              ),
                              Expanded(
                                flex: 10,
                                child: Container(
                                  child: TextFormField(
                                    controller: _concustnidnumber,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                      hintText: "NID Number",
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
                                  text: "Phone Number 2",
                                  size: 16,
                                ),
                              ),
                              const Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 1,
                                ),
                              ),
                              Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Reference",
                                    size: 16,
                                  )),
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
                                    controller: _concustphone2,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
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
                              ),
                              const Expanded(
                                flex: 1,
                                child: SizedBox(
                                  height: 1,
                                ),
                              ),
                              Expanded(
                                flex: 10,
                                child: Container(
                                  child: TextFormField(
                                    controller: _concustreference,
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.transparent),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                      hintText: "Reference",
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
                          margin: EdgeInsets.only(top: _height / 12, left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _addlendingperson();
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
