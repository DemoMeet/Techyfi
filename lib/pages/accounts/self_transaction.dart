import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/routing/routes.dart';

import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/Accounts.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../model/Supplier.dart';
import '../../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../../helpers/auth_service.dart';

class SelfTransaction extends StatefulWidget {
  
  Navbools nn;
  SelfTransaction({super.key, required this.nn});
  @override
  State<SelfTransaction> createState() => _SelfTransactionState();
}

class _SelfTransactionState extends State<SelfTransaction> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conAmount = TextEditingController();
  final _conremarks = TextEditingController();
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount1, _selectedpayment1;
  var _selectedAccountid1;
  var _selectedaccount2, _selectedpayment2;
  var _selectedAccountid2;
  double _dueAmount = 0;
  double _leftAmount = 0;
  var payment1 = ["Bank Payment", "Cash Payment"],payment2 = ["Bank Receives", "Cash Receives"];
  int _sts = 1;

  bool selectedpm1 = false, bankpayment1 = false;
  bool selectedpm2 = false, bankpayment2 = false;

  _addunit() async {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String ss = getRandomString(20);

    double amount = double.parse(_conAmount.text.toString());
    if (_selectedpayment1.toString() == "null" ||
        _selectedAccountid1.toString() == "null" ||_selectedpayment2.toString() == "null" ||
        _selectedAccountid2.toString() == "null" ||
        _conremarks.text.isEmpty ||
        _conAmount.text.isEmpty) {
      Get.snackbar("Balance Transfer Failed.",
          "All Fields are Required to Process Transaction!!",
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
      if (_selectedAccountid1 != _selectedAccountid2) {
        FirebaseFirestore.instance.collection('Transaction').add({
          'Name': _selectedAccountid2.bank?_selectedAccountid2.bankname:_selectedAccountid2.cashname,
          '2nd ID': _selectedAccountid2.uid,
          'Remarks': "Balance Transfer",
          'Submit Date': DateTime.now(),
          'Date': DateTime.now(),
          'Type': 'Self',
          'User': AuthService.to.user?.name,
          'Payment Method': _selectedpayment1,
          'ID': ss,
          'Account ID': _selectedAccountid1.uid,
          'Account Details': _selectedAccountid1.toJson(),
          'Amount': amount,
        });
        FirebaseFirestore.instance
            .collection('Account')
            .doc(_selectedAccountid1.uid)
            .update({
          'Balance': _selectedAccountid1.bal - amount,
        });
        FirebaseFirestore.instance
            .collection('Account')
            .doc(_selectedAccountid2.uid)
            .update({
          'Balance': _selectedAccountid2.bal + amount,
        });
        FirebaseFirestore.instance.collection('BalanceTransfer').doc(ss).set({
          'Date': DateTime.now(),
          'UID': ss,
          'Amount': amount,
          'From Account ID': _selectedAccountid1.uid,
          'From Account Details': _selectedAccountid1.toJson(),
          'To Account ID': _selectedAccountid2.uid,
          'To Account Details': _selectedAccountid2.toJson(),
          'Remarks': _conremarks.text,
        }).then((value) {
          widget.nn.setnavbool();
          widget.nn.account = true;
          widget.nn.account_selftransactionlist = true;
          Get.offNamed(selftransactionslist);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Supplier Payment Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add user: $error"));
      } else {
        Get.snackbar("Balance Transfer Failed.",
            "Both Account is same Select Different Accounts to Process Transaction!!",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red,
            margin: EdgeInsets.zero,
            duration: const Duration(milliseconds: 2000),
            boxShadows: [
              BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
            ],
            borderRadius: 0);
      }
    }
  }

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Account')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        setState(() {
          if (element["Bank"]) {
            _bankaccounts.add(Accounts(
                uid: element["UID"],
                accountname: element["Account Name"],
                accountnum: element["Account Number"],
                cashdetails: element["Cash Details"],
                cashname: element["Cash Name"],
                bal: element["Balance"],
                sts: element["Status"],user: element['User'],
                bankname: element["Bank Name"],
                bank: element["Bank"],
                branch: element["Branch"],
                sl: 0));
            sbankaccounts.add(element["Account Number"]);
          } else {
            _cashaccounts.add(Accounts(
                uid: element["UID"],
                accountname: element["Account Name"],
                accountnum: element["Account Number"],
                cashdetails: element["Cash Details"],
                cashname: element["Cash Name"],
                bal: element["Balance"],
                sts: element["Status"],user: element['User'],
                bankname: element["Bank Name"],
                bank: element["Bank"],
                branch: element["Branch"],
                sl: 0));
            scashaccounts.add(element["Cash Name"].toString());
          }
        });
      });
    });
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
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
              margin: EdgeInsets.only(
                  top: _height / 8, left: 30,),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                        text: "Balance Transfer",
                        size: 32,
                        weight: FontWeight.bold),
                    Container(
                      margin:  EdgeInsets.only(top: 30, left: 10, right: _width / 5),
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
                                text: "Select Debit Type",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Debit Type'),
                                value: _selectedpayment1,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue.toString() == payment1[0]) {
                                      selectedpm1 = true;
                                      bankpayment1 = true;
                                      var vs;
                                      _selectedaccount1 = vs;
                                      _selectedAccountid1 = vs;
                                    } else {
                                      selectedpm1 = true;
                                      bankpayment1 = false;
                                      var vs;
                                      _selectedaccount1 = vs;
                                      _selectedAccountid1 = vs;
                                    }
                                    _selectedpayment1 = newValue.toString();
                                  });
                                },
                                items: payment1.map((location) {
                                  return DropdownMenuItem(
                                    child: Text(location),
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
                      margin: EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          selectedpm1
                              ? bankpayment1
                              ? Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Bank Payment",
                                size: 16,
                              ))
                              : Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Cash Payment",
                                size: 16,
                              ))
                              : SizedBox(),
                          selectedpm1
                              ? bankpayment1
                              ? Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Debit Bank Account'),
                                value: _selectedaccount1,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedaccount1 =
                                        newValue.toString();
                                    _selectedAccountid1 = _bankaccounts[
                                    sbankaccounts.indexOf(
                                        newValue.toString())];
                                    _dueAmount = _selectedAccountid1.bal;
                                  });
                                },
                                items: _bankaccounts.map((location) {
                                  return DropdownMenuItem(
                                    value: location.accountnum,
                                    child: Text(
                                        "${location.bankname} (${location.accountnum})"),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                              : Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Debit Cash Counter'),
                                value: _selectedaccount1,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedaccount1 =
                                        newValue.toString();
                                    _selectedAccountid1 = _cashaccounts[
                                    scashaccounts.indexOf(
                                        newValue.toString())];
                                    _dueAmount = _selectedAccountid1.bal;
                                  });
                                },
                                items: _cashaccounts.map((location) {
                                  return DropdownMenuItem(
                                    value: location.cashname,
                                    child: Text(location.cashname),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 10,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                               CustomText(
                                text: "Due    ",
                                size: 16,
                              ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: _dueAmount.toString(),
                                size: 16,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 1,
                            ),
                          ), CustomText(
                                text: "Left    ",
                                size: 16,
                              ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: _leftAmount.toString(),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:  EdgeInsets.only(top: 10, left: 10, right: _width / 5),
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
                                text: "Amount",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: _conAmount,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]')),
                                FilteringTextInputFormatter.digitsOnly
                              ],
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
                                hintText: "Amount",
                                fillColor: Colors.grey.shade200,
                                filled: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  if (_selectedAccountid1 != "") {
                                    final number = int.tryParse(val);
                                    if (number != null) {
                                      final text = number
                                          .clamp(
                                          0,
                                          _selectedAccountid1.bal)
                                          .toString();
                                      final selection = TextSelection.collapsed(
                                        offset: text.length,
                                      );
                                      _conAmount.value =
                                          TextEditingValue(
                                            text: text,
                                            selection: selection,
                                          );
                                      _leftAmount =_dueAmount-double.parse(text);
                                    }
                                  } else {
                                    _conAmount.text = '0';
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),


                    Container(
                      margin:  EdgeInsets.only(top: 10, left: 10, right: _width / 5),
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
                                text: "Select Credit Type",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Credit Type'),
                                value: _selectedpayment2,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue.toString() == payment2[0]) {
                                      selectedpm2 = true;
                                      bankpayment2 = true;
                                      var vs;
                                      _selectedaccount2 = vs;
                                      _selectedAccountid2 = vs;
                                    } else {
                                      selectedpm2 = true;
                                      bankpayment2 = false;
                                      var vs;
                                      _selectedaccount2 = vs;
                                      _selectedAccountid2 = vs;
                                    }
                                    _selectedpayment2 = newValue.toString();
                                  });
                                },
                                items: payment2.map((location) {
                                  return DropdownMenuItem(
                                    child: Text(location),
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
                      margin: EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          selectedpm2
                              ? bankpayment2
                              ? Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Bank Receives",
                                size: 16,
                              ))
                              : Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Cash Receives",
                                size: 16,
                              ))
                              : SizedBox(),
                          selectedpm2
                              ? bankpayment2
                              ? Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Bank Account'),
                                value: _selectedaccount2,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedaccount2 =
                                        newValue.toString();
                                    _selectedAccountid2 = _bankaccounts[
                                    sbankaccounts.indexOf(
                                        newValue.toString())];
                                  });
                                },
                                items: _bankaccounts.map((location) {
                                  return DropdownMenuItem(
                                    value: location.accountnum,
                                    child: Text(
                                        "${location.bankname} (${location.accountnum})"),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                              : Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Cash Counter'),
                                value: _selectedaccount2,
                                onChanged: (newValue) {
                                  setState(() {
                                    _selectedaccount2 =
                                        newValue.toString();
                                    _selectedAccountid2 = _cashaccounts[
                                    scashaccounts.indexOf(
                                        newValue.toString())];
                                  });
                                },
                                items: _cashaccounts.map((location) {
                                  return DropdownMenuItem(
                                    value: location.cashname,
                                    child: Text(location.cashname),
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, left: 10, right: _width / 5),
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
                                text: "Remarks",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: _conremarks,
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
                                hintText: "Remarks",
                                fillColor: Colors.grey.shade200,
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: _height / 25, left: 10, right: _width / 5),
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
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  _addunit();
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
              ),
            )),
          ],
        )));
  }
}
