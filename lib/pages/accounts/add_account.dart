import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:groceyfi02/helpers/auth_service.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../constants/style.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddAccount extends StatefulWidget {
  
  Navbools nn;
  AddAccount({required this.nn});
  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conbankname = TextEditingController();
  final _conaccountnum = TextEditingController();
  final _conaccountname = TextEditingController();
  final _constartingbalance = TextEditingController();
  final _conbranch = TextEditingController();

  final _concashname = TextEditingController();
  final _concashdetails = TextEditingController();
  int _sts = 1, _banktype = 1;
  bool bank = true;

  _AddAccount() async {
    String bankname = _conbankname.text;
    String accountnum = _conaccountnum.text;
    String accountname = _conaccountname.text;
    String bal = _constartingbalance.text;
    String branch = _conbranch.text;
    String cashname = _concashname.text;
    String cashdetails = _concashdetails.text;

    if ((bank &&
            (bankname.isEmpty ||
                accountname.isEmpty ||
                accountnum.isEmpty ||
                bal.isEmpty)) ||
        (!bank && (cashname.isEmpty || cashdetails.isEmpty || bal.isEmpty))) {
      Get.snackbar(
          "Account Addition Failed", "Every Details of Account is Required",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          margin: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2000),
          boxShadows: [
            const BoxShadow(
                color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
          ],
          borderRadius: 0);
    } else {
      const _chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      Random _rnd = Random();
      String getRandomString(int length) =>
          String.fromCharCodes(Iterable.generate(
              length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
      String ss = getRandomString(20);
      bool cstats = true;
      if (_sts == 2) {
        cstats = false;
      }
      FirebaseFirestore.instance.collection('Account').doc(ss).set({
        'Bank Name': bankname,
        'Account Number': accountnum,
        'Account Name': accountname,
        'Branch': branch,
        'Cash Name': cashname,'User':AuthService.to.user?.name,
        'UID': ss,
        'Balance': double.parse(bal),
        'Cash Details': cashdetails,
        'Status': cstats,
        'Bank': bank
      }).then((valu) {
        widget.nn.setnavbool();
        widget.nn.account = true;
        widget.nn.account_list = true;
        Get.offNamed(accountlist);
        Get.snackbar(
            "Account Added Successfully", "Redirecting to Account List",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.green,
            margin: EdgeInsets.zero,
            duration: const Duration(milliseconds: 2000),
            boxShadows: [
              BoxShadow(
                  color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
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
        body: Obx(() =>Row(
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
                        text: "Add Account", size: 32, weight: FontWeight.bold),
                    Container(
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: CustomText(
                                text: "Select Type",
                                size: 16,
                              )),
                          const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          bank
                              ? Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Bank Name",
                                    size: 16,
                                  ),
                                )
                              : Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Cash Name",
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 10,
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: const Text("Bank/Mobile Bank"),
                                  value: 1,
                                  groupValue: _banktype,
                                  onChanged: (value) {
                                    setState(() {
                                      _banktype = int.parse(value.toString());
                                      bank = true;
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text("Cash Counter"),
                                  value: 2,
                                  groupValue: _banktype,
                                  onChanged: (value) {
                                    setState(() {
                                      _banktype = int.parse(value.toString());
                                      bank = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          bank
                              ? Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conbankname,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Bank Name",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _concashname,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Cash Name",
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
                          bank
                              ? Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Account Holder Name",
                                    size: 16,
                                  ))
                              : Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Cash Details",
                                    size: 16,
                                  )),
                          const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          bank
                              ? Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Account Number",
                                    size: 16,
                                  ),
                                )
                              : Expanded(
                                  flex: 10,
                                  child: CustomText(
                                    text: "Starting Balance",
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
                          bank
                              ? Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conaccountname,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Account Holder Name",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      maxLines: null,
                                      controller: _concashdetails,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Cash Details",
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
                          bank
                              ? Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _conaccountnum,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Account Number",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              : Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _constartingbalance,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Starting Balance",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                    bank
                        ? Container(
                            margin: EdgeInsets.only(
                                top: _height / 25, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 10,
                                    child: CustomText(
                                      text: "Starting Balance",
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
                                    text: "Branch",
                                    size: 16,
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox(),
                    bank
                        ? Container(
                            margin: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Container(
                                    child: TextFormField(
                                      controller: _constartingbalance,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9]')),
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Starting Balance",
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
                                      controller: _conbranch,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        enabledBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
                                        ),
                                        hintText: "Branch",
                                        fillColor: Colors.grey.shade200,
                                        filled: true,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox(),
                    Container(
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 10,
                              child: CustomText(
                                text: "Status",
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
                          const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                            flex: 10,
                            child: Container(),
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
                            flex: 1,
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  _AddAccount();
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
