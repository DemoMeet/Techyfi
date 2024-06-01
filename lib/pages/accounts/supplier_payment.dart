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

class SupplierPayment extends StatefulWidget {
  
  Navbools nn;
  SupplierPayment({required this.nn});
  @override
  State<SupplierPayment> createState() => _SupplierPaymentState();
}

class _SupplierPaymentState extends State<SupplierPayment> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  var _selectedsupplier;
  var _selectedsupplierid;
  var supplier = [], ssupplier = [];
  final _convoucherid = TextEditingController(),
      _consupplierAmount = TextEditingController();
  final _conremarks = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount, _selectedpayment;
  var _selectedAccountid;
  double _dueAmount = 0;
  double _leftAmount = 0;
  var payment = ["Bank Payment", "Cash Payment"];
  TimeOfDay selectedTime = TimeOfDay.now();
  int _sts = 1;

  bool selectedpm = false, bankpayment = false;

  _addunit() async {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String ss = getRandomString(20);

    double amount = double.parse(_consupplierAmount.text.toString());
    if (_selectedpayment.toString() == "null" ||
        _selectedsupplier.toString() == "null" ||
        _selectedAccountid.toString() == "null" ||
        _conremarks.text.isEmpty ||
        _consupplierAmount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("All Fields are Required to Process supplier!!"),
      ));
    } else {
      if (_selectedAccountid.bal > amount) {
        FirebaseFirestore.instance.collection('Transaction').add({
          'Name': _selectedsupplierid.name,
          '2nd ID': _selectedsupplierid.id,
          'Remarks': "Supplier Payment",
          'Submit Date': DateTime.now(),
          'User': AuthService.to.user?.name,
          'Date': selectedDate,
          'Type': 'Debit',
          'Payment Method': _selectedpayment,
          'ID': ss,
          'Account ID': _selectedAccountid.uid,
          'Account Details': _selectedAccountid.toJson(),
          'Amount': amount,
        });
        FirebaseFirestore.instance
            .collection('Account')
            .doc(_selectedAccountid.uid)
            .update({
          'Balance': _selectedAccountid.bal - amount,
        });
        FirebaseFirestore.instance
            .collection('Supplier')
            .doc(_selectedsupplierid.id)
            .update({
          'Balance': _dueAmount - amount,
        });

        FirebaseFirestore.instance.collection('PaymentVoucher').doc(ss).set({
          'Name': _selectedsupplierid.name,
          'ID': _selectedsupplierid.id,
          'Selected Date': selectedDate,
          'Payment': true,
          'Date': DateTime.now(),
          'UID': ss,'User':AuthService.to.user?.name,
          'Amount': amount,
          'Voucher ID': _convoucherid.text,
          'Remarks': _conremarks.text,
          'From': _selectedAccountid.bank
              ? _selectedAccountid.bankname
              : _selectedAccountid.cashname,
        }).then((value) {
          widget.nn.setnavbool();
          widget.nn.account = true;
          widget.nn.account_report = true;
          Get.offNamed(paymentreport);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Supplier Payment Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add user: $error"));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Selected Account Doesn't Have Sufficient Balance, Change Account."),
        ));
      }
    }
  }

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Supplier')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        supplier.add(Supplier(
            address: element["Address"],
            balance: element["Balance"],user: element['User'],
            city: element["City"],
            email: element["Email"],
            id: element.id,
            name: element["Name"],
            phone1: element["Phone"],zip: element["Zip Code"],
            phone2: element["Phone2"],
            sl: 0));
        ssupplier.add(element["Name"]);
        setState(() {});
      });
    });

    await FirebaseFirestore.instance
        .collection('PaymentVoucher')
        .get()
        .then((querySnapshot) {
      int innum = 1;
      querySnapshot.docs.forEach((element) {
        innum++;
        setState(() {});
      });
      _convoucherid.text = innum.toString();
    });

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
                cashname: element["Cash Name"],user: element['User'],
                bal: element["Balance"],
                sts: element["Status"],
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

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: buttonbg,
              onPrimary: Colors.white,
              onSurface: buttonbg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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
                        text: "Supplier Payment",
                        size: 32,
                        weight: FontWeight.bold),
                    Container(
                      margin:
                          EdgeInsets.only(top: _height / 14, left: 10, right: _width / 5),
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
                                text: "Voucher ID",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: _convoucherid,
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
                                hintText: "Voucher ID",
                                fillColor: Colors.grey.shade200,
                                filled: true,
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
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Date",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: DateFormat.yMMMd()
                                      .format(selectedDate)
                                      .toString(),
                                  size: 16,
                                ),
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
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Supplier Name",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select supplier'),
                                value: _selectedsupplier,
                                onChanged: (newValue) {
                                  setState(() {
                                    int indx = ssupplier.indexOf(newValue);
                                    _selectedsupplierid = supplier[indx];
                                    _selectedsupplier = newValue.toString();
                                    _dueAmount = _selectedsupplierid.balance;
                                  });
                                },
                                items: supplier.map((location) {
                                  return DropdownMenuItem(
                                    value: location.name,
                                    child: new Text(location.name),
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
                              controller: _consupplierAmount,
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
                                  if (_selectedsupplier != "") {
                                    final number = int.tryParse(val);
                                    if (number != null) {
                                      final text = number
                                          .clamp(
                                          0,
                                          _dueAmount)
                                          .toString();
                                      final selection = TextSelection.collapsed(
                                        offset: text.length,
                                      );
                                      _consupplierAmount.value =
                                          TextEditingValue(
                                            text: text,
                                            selection: selection,
                                          );
                                      _leftAmount =_dueAmount-double.parse(text);
                                    }
                                  } else {
                                    _consupplierAmount.text = '0';
                                  }
                                });
                              },
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
                                text: "Select Payment",
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
                                hint: const Text('Select Payment'),
                                value: _selectedpayment,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue.toString() == payment[0]) {
                                      selectedpm = true;
                                      bankpayment = true;
                                      var vs;
                                      _selectedaccount = vs;
                                      _selectedAccountid = vs;
                                    } else {
                                      selectedpm = true;
                                      bankpayment = false;
                                      var vs;
                                      _selectedaccount = vs;
                                      _selectedAccountid = vs;
                                    }
                                    _selectedpayment = newValue.toString();
                                  });
                                },
                                items: payment.map((location) {
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
                          selectedpm
                              ? bankpayment
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
                          selectedpm
                              ? bankpayment
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
                                          value: _selectedaccount,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedaccount =
                                                  newValue.toString();
                                              _selectedAccountid = _bankaccounts[
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
                                          value: _selectedaccount,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedaccount =
                                                  newValue.toString();
                                              _selectedAccountid = _cashaccounts[
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
