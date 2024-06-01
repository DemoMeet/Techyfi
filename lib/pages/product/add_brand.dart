import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddBrand extends StatefulWidget {

  
  Navbools nn;
  AddBrand({required  this.nn});
  @override
  State<AddBrand> createState() => _AddBrandState();
}

class _AddBrandState extends State<AddBrand> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
    final _conbrandname = TextEditingController();

    int _sts = 1;
    _addBrand() async
    {
      String cname = _conbrandname.text;
      bool cstats = true;
      if(_sts == 2){
        cstats = false;
      }
      const _chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      Random _rnd = Random();
      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length,
                  (_) => _chars.codeUnitAt(
                  _rnd.nextInt(_chars.length))));
      String ss = getRandomString(20);
      if (cname.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Brand Name is Required"),
        ));
      } else {
        FirebaseFirestore.instance.collection('Brand').doc(ss).set({
          'Name': cname,'ID':ss,
          'status': cstats,
        }).then((value) {
          widget.nn.setnavbool();
          widget.nn.product = true;
          widget.nn.brand_list = true;
          Get.offNamed(brandlistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Brand Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add Brand: $error"));
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
                    margin: EdgeInsets.only(top: _height / 8, left: 30, right: _width / 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(text: "Add Brand", size: 32, weight: FontWeight.bold),

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
                                    text: "Brand Name",
                                    size: 16,
                                  )),
                              Expanded(
                                flex: 10,
                                child: Container(
                                  child: TextFormField(
                                    controller: _conbrandname,
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
                                      hintText: "Brand Name",
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
                                  child: Column(children: [ RadioListTile(
                                    title: Text("Active"),
                                    value: 1,
                                    groupValue: _sts,
                                    onChanged: (value){
                                      setState(() {
                                        _sts = int.parse(value.toString());
                                      });
                                    },
                                  ),

                                    RadioListTile(
                                      title: Text("Deactivate"),
                                      value: 2,
                                      groupValue: _sts,
                                      onChanged: (value){
                                        setState(() {
                                          _sts = int.parse(value.toString());
                                        });
                                      },
                                    ),
                                  ],),
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
                                      _addBrand();
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
                  )),
            ],
          )));
    }
}
