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

class AddExpenseItem extends StatefulWidget {
  
  Navbools nn;
  AddExpenseItem({required this.nn});
  @override
  State<AddExpenseItem> createState() => _AddExpenseItemState();
}

class _AddExpenseItemState extends State<AddExpenseItem> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conepenseitemname = TextEditingController();
  int _sts = 1;
  _AddExpenseItem() async {
    String expensename = _conepenseitemname.text;
    bool cstats = true;
    if (_sts == 2) {
      cstats = false;
    }

    if (expensename.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Both Fields are Required"),
      ));
    } else {
      FirebaseFirestore.instance.collection('ExpenseItem').add({
        'Expense Item Name': expensename,
        'status': cstats,
      }).then((value) {
        widget.nn.setnavbool();
        widget.nn.human_resource = true;
        widget.nn.human_resource_expense = true;
        widget.nn.hr_expense_expense_item_list = true;
        Get.offNamed(expenseitemlistPageRoute);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Expense Added Successfully!"),
        ));
      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

 

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar:MyAppBar(height: height,width:  width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn, ),
            Expanded(
                child: Container(
              margin:
                  EdgeInsets.only(top: height / 8, left: 30, right: width / 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      text: "Add Expense Item",
                      size: 32,
                      weight: FontWeight.bold),
                  Container(
                    margin:
                        EdgeInsets.only(top: height / 10, left: 10, right: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 1,
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: CustomText(
                              text: "Expense Name",
                              size: 16,
                            )),
                        Expanded(
                          flex: 10,
                          child: Container(
                            child: TextFormField(
                              controller: _conepenseitemname,
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
                                hintText: "Expense Item Name",
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
                    margin: const EdgeInsets.only(top: 20, left: 20, right: 10),
                    child: Row(
                      children: [
                        const Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: 1,
                          ),
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
                            margin: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: const Text("Active"),
                                  value: 1,
                                  groupValue: _sts,
                                  onChanged: (value) {
                                    setState(() {
                                      _sts = int.parse(value.toString());
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text("Deactivate"),
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
                    margin:
                        EdgeInsets.only(top: height / 25, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          flex: 11,
                          child: SizedBox(
                            height: 1,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: ElevatedButton(
                            onPressed: () {
                              _AddExpenseItem();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonbg,
                              elevation: 20,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                            ),
                            child: CustomText(
                              text: "Submit",
                              weight: FontWeight.bold,
                              color: Colors.white,
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
