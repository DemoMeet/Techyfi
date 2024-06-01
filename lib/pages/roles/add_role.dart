import 'dart:html';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/model/UserImage.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddUser extends StatefulWidget {
  
  Navbools nn;
  AddUser({required this.nn});
  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  int _sts = 1;
  Users usr = Users();
  final _concustname = TextEditingController();
  final _concustphone = TextEditingController();
  final _concustid = TextEditingController();
  final _concustpass = TextEditingController();
  final _concustdetails = TextEditingController();

  _AddUser() async {
    String cname = _concustname.text;
    String cphone = _concustphone.text;
    String cid = _concustid.text;
    String cpass = _concustpass.text;
    String cdetails = _concustdetails.text;
    String asset = usr.getActiveItems().asset;

    bool cstats = true;

    if(_sts == 2){
      cstats = false;
    }

    if (cname.isEmpty ||
        cid.isEmpty ||
        cpass.isEmpty) {
      Get.snackbar("User Adding Failed.",
          "User's Name, User ID and Password is Required",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          margin: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2000),
          boxShadows: [
            const BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
          ],
          borderRadius: 0);
    } else if (
        cpass.length <= 5) {
      Get.snackbar("User Adding Failed.",
          "Password Has to be 6 Digit Long.",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          margin: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2000),
          boxShadows: [
            const BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
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
      FirebaseFirestore.instance.collection('User').doc(ss).set({
        'Name': cname,
        'Phone': cphone,
        'ID': cid,
        'Password': cpass,
        'Details': cdetails,'User':AuthService.to.user?.name,
        'Assets': asset,
        'Last Login':DateTime.now(),
        'Last Logout':DateTime.now(),
        'UID':ss,
        'Admin': cstats,
      }).then((value) {
        widget.nn.setnavbool();
        widget.nn.management = true;
        widget.nn.unit_list = true;
        Get.offNamed(userlistPageRoute);
        Get.snackbar("User Added Successfully.",
            "Redirecting to User List Page.",
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
  void initState() {
    // TODO: implement initState
    super.initState();
    usr.inituser();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    print(_height);
 

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
              margin: EdgeInsets.only(
                  top: _height / 8, left: 30, right: _width / 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                        text: "Add User", size: 32, weight: FontWeight.bold),
                    Container(
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: CustomText(
                                text: "User's Name",
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
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
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
                                controller: _concustphone,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9]')),
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
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
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: CustomText(
                                text: "User ID",
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
                                controller: _concustid,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
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
                                controller: _concustpass,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: true,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
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
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: CustomText(
                                text: "Select Role",
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
                                text: "Details",
                                size: 16,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 10,
                            child: Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Column(
                                children: [
                                  RadioListTile(
                                    title: const Text("Admin"),
                                    value: 1,
                                    groupValue: _sts,
                                    onChanged: (value) {
                                      setState(() {
                                        _sts = int.parse(value.toString());
                                      });
                                    },
                                  ),
                                  RadioListTile(
                                    title: const Text("Employee"),
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
                                keyboardType: TextInputType.number,
                                controller: _concustdetails,
                                maxLines: null,
                                decoration: InputDecoration(
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
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
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: 10, bottom: 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  _AddUser();
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
                          const Expanded(
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
