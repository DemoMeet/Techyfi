import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';



class AddBenefit extends StatefulWidget {

  
  Navbools nn;
  AddBenefit({required  this.nn});
  @override
  State<AddBenefit> createState() => _AddBenefitState();
}

class _AddBenefitState extends State<AddBenefit> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conbenename = TextEditingController();
  int _sts = 1;
  var payment = ["Add", "Deduct"];
  var _selectedbenefit;
  _addbenefit() async {
    
    String benename = _conbenename.text;
    bool cstats = true;
    if(_sts == 2){
      cstats = false;
    }
    
    
    if (benename.isEmpty || _selectedbenefit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Both Fields are Required"),
      ));
    } else {
      FirebaseFirestore.instance.collection('Benefit').add({
        'Benefit Name': benename,'status': cstats,
        'Benefit Type': _selectedbenefit,
      }).then((value) {

        widget.nn.setnavbool();
        widget.nn.human_resource =true;
        widget.nn.human_resource_payroll = true;
        widget.nn.hr_payroll_benefit_list = true;
        Get.offNamed(benefitlistPageRoute);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Benefit Added Successfully!"),
        ));


      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {double _height = MediaQuery.of(context).size.height;
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
                    CustomText(text: "Add Benefits", size: 32, weight: FontWeight.bold),

                    Container(
                      margin: EdgeInsets.only(top: _height / 10, left: 10, right: 10),
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
                                text: "Benefit Name",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              child: TextFormField(
                                controller: _conbenename,
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
                                  hintText: "Benefit Name",
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
                                text: "Benefit Type",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: SizedBox(),
                                isExpanded: true,
                                hint: Text('Select Benefit Type'),
                                value: _selectedbenefit,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedbenefit = newValue.toString();
                                  });
                                },
                                items: payment.map((location) {
                                  return DropdownMenuItem(
                                    child: new Text(location),
                                    value: location,
                                  );
                                }).toList(),
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
                          const Expanded(
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
                                  _addbenefit();
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

