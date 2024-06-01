import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/routing/routes.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';


class AddDesignation extends StatefulWidget {

  
  Navbools nn;
  AddDesignation({required  this.nn});
  @override
  State<AddDesignation> createState() => _AddDesignationState();
}

class _AddDesignationState extends State<AddDesignation> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conDesignationname = TextEditingController();
  final _conDesignationdetails = TextEditingController();

  int _sts = 1;
  _addDesignation() async {
    String cname = _conDesignationname.text;
    String cdetails = _conDesignationdetails.text;
    bool cstats = true;
    if(_sts == 2){
      cstats = false;
    }

    if (cname.isEmpty||cdetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Designation Name & Details is Required"),
      ));
    } else {
      FirebaseFirestore.instance.collection('Designation').add({
        'Name': cname,
        'Details': cdetails,
        'status': cstats,
      }).then((value) {

        widget.nn.setnavbool();
        widget.nn.human_resource = true;
        widget.nn.human_resource_employee = true;
        widget.nn.hr_employee_designation_list = true;
        Get.offNamed(designationlistPageRoute);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Designation Added Successfully!"),
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
                : SideMenuSmall(widget.nn,),
            Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: _height / 8, left: 30, right: _width / 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(text: "Add Designation", size: 32, weight: FontWeight.bold),

                      Container(
                        margin: EdgeInsets.only(top: _height / 5, left: 10, right: 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: SizedBox(
                                height: 1,
                              ),
                              flex: 4,
                            ),
                            Expanded(
                                flex: 5,
                                child: CustomText(
                                  text: "Designation Name",
                                  size: 16,
                                )),
                            Expanded(
                              flex: 10,
                              child: Container(
                                child: TextFormField(
                                  controller: _conDesignationname,
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
                                    hintText: "Designation Name",
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
                        margin: EdgeInsets.only(top: 20, left: 10, right: 10),
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
                                  text: "Designation Details",
                                  size: 16,
                                )),
                            Expanded(
                              flex: 10,
                              child: Container(
                                child: TextFormField(
                                  controller: _conDesignationdetails,
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
                                    hintText: "Designation Details",
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
                                    _addDesignation();
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
