import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/User.dart';
import '../../model/UserImage.dart';
import '../../model/nav_bools.dart';
import '../../widgets/topnavigationbaredit.dart';

class MyProfile extends StatefulWidget {

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  String loinlout = "";
  bool changeimg = false;
  Users usr = Users();
  late User cst;
  final _conmanname = TextEditingController();
  final _conmanphone = TextEditingController();
  final _conmanid = TextEditingController();
  final _conmanpass = TextEditingController();
  final _conmandetails = TextEditingController();

  _addUser(User cst) async {
    String mname = _conmanname.text;
    String mphone = _conmanphone.text;
    String mid = _conmanid.text;
    String  mpass = _conmanpass.text;
    String mdetails = _conmandetails.text;
    String asset = usr.getActiveItems().asset;

    if (mname.isEmpty ||
        mphone.isEmpty ||
        mid.isEmpty ||
        mdetails.isEmpty ||
        mpass.isEmpty) {
      
      Get.snackbar("Invalid Format.",
                     "User's Name, Phone, Address and Previous Balance is Required",
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
      if(!changeimg){
        FirebaseFirestore.instance.collection('User').doc(cst.id).update({
          'Name': mname,
          'Phone': mphone,
          'ID': mid,
          'Password': mpass,
          'Details': mdetails,
        }).then((valu) {
          Navigator.of(context).pop();
          Get.snackbar("Saved User Successfully.",
              "Redirected to User List Page!",
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
      }else{
        FirebaseFirestore.instance.collection('User').doc(cst.id).update({
          'Name': mname,
          'Phone': mphone,
          'ID': mid,
          'Password': mpass,
          'Details': mdetails,
          'Assets': asset,
        }).then((valu) {
          Navigator.of(context).pop();
          Get.snackbar("Saved User Successfully.",
              "Redirected to User List Page!",
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
  }

  void _addinit(User cst) {
    _conmanname.text = cst.name;
    _conmanphone.text = cst.phone;
    _conmanid.text = cst.id;
    _conmanpass.text = cst.pass;
    _conmandetails.text = cst.details;
    setState(() {
      loinlout = '${DateFormat('dd/MM/yyyy HH:mm a').format(cst.lastlogin)} --- ${DateFormat('dd/MM/yyyy HH:mm a').format(cst.lastlogout)}';
      int ss = usr.items.indexWhere((element) => element.asset == cst.asset);
      usr.setallfalse(ss);
    });
  }

  @override
  void initState() {
    super.initState();
    usr.inituser();
  }


  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    var arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;

    var cst = User.fromJson(jsonDecode(arguments['User']));
    _addinit(cst);

    return Scaffold(
      appBar: MyAppBarEdit(height: _height,width: _width),
      body: Obx(() => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.only(
              top: 20, left: _width / 6, right: _width / 6, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                  text: "My Profile", size: 32, weight: FontWeight.bold),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "User's Name",
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
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            hintText: "Users Name",
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
                          text: "ID",
                          size: 16,
                        )),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: CustomText(
                        text: "Password",
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
                          controller: _conmanid,
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
                            hintText: "User ID",
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
                          controller: _conmanpass,
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
                            hintText: "Password",
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
                          text: "Details",
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
                        text: "Last Login --- Last Logout",
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
                          controller: _conmandetails,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            hintText: "Details",
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
                        padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: Text(loinlout, style: const TextStyle(fontSize: 16),),
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
                          text: "Role",
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
                        text: "",
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
                        padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: Text(cst.sts?"Admin":"Employee", style: const TextStyle(fontSize: 16),),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
                    ),
                    const Expanded(
                      flex: 10,
                      child: SizedBox()
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: _height / 25, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "Select Avatar",
                          size: 16,
                        )),
                    const Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                    Expanded(
                        flex: 10,
                        child: CustomText(
                          text: "",
                          size: 16,
                        )),
                  ],
                ),
              ),
              Container(
                margin:
                const EdgeInsets.only(top: 10, left: 10, right: 10),
                height: 273.777782299,
                width: 1000,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 8,
                            crossAxisSpacing: 50.0,
                            mainAxisSpacing: 10.0,
                            children:
                            List.generate(usr.items.length, (index) {
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    usr.setallfalse(index);
                                    changeimg = true;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: usr.items[index].status?Colors.grey.shade200:Colors.transparent,
                                  child:
                                  Image.asset(usr.items[index].asset),
                                ),
                              );
                            })),
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
                      flex: 1,
                      child: Container(
                        child: ElevatedButton(
                          onPressed: () {
                            _addUser(cst);
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
    ));
  }
}
