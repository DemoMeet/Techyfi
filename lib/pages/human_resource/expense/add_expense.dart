import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/routing/routes.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../helpers/auth_service.dart';
import '../../../model/Accounts.dart';
import '../../../model/Single.dart';
import '../../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';

class AddExpense extends StatefulWidget {
  
  Navbools nn;
  AddExpense({required this.nn});
  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  var _selectedexpense;
  var _selectedexpenseid;
  bool others = false;
  var expense = [], sexpense = [];
  final _conExpenseAmount = TextEditingController();
  final _conotherstext = TextEditingController();
  DateTime selectedDate = DateTime.now();
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount, _selectedpayment;
  var _selectedAccountid;
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

    double amount = double.parse(_conExpenseAmount.text.toString());
    if (_selectedpayment.toString() == "null" ||
        _selectedexpense.toString() == "null" ||
        _selectedAccountid.toString() == "null" ||
        (others && _conotherstext.text.isEmpty) ||
        _conExpenseAmount.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("All Fields are Required to Process Expense!!"),
      ));
    } else {
      if (_selectedAccountid.bal > amount) {
        FirebaseFirestore.instance.collection('Transaction').add({
          'Name': others
              ? "Others (${_conotherstext.text})"
              : _selectedexpenseid.name,
          '2nd ID': _selectedexpenseid.id,
          'Remarks': "Item Expense",'User':AuthService.to.user?.name,
          'Submit Date': DateTime.now(),
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
        FirebaseFirestore.instance.collection('Expense').doc(ss).set({
          'Expense Name': _selectedexpenseid.name,
          'Expense ID': _selectedexpenseid.id,
          'Date': selectedDate,
          'UID': ss,
          'Amount': amount,'User':AuthService.to.user?.name,
          'Others': _conotherstext.text,
          'From': _selectedAccountid.bank
              ? _selectedAccountid.bankname
              : _selectedAccountid.cashname,
        }).then((value) {
          widget.nn.setnavbool();
          widget.nn.human_resource = true;
          widget.nn.human_resource_expense = true;
          widget.nn.hr_expense_expense_list = true;
          Get.offNamed(expenselistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Attendance Added Successfully!"),
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
    expense.add(Single(id: "000", name: "Others"));
    sexpense.add("Others");
    await FirebaseFirestore.instance
        .collection('ExpenseItem')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        expense.add(Single(id: element.id, name: element["Expense Item Name"]));
        sexpense.add(element["Expense Item Name"]);
        setState(() {});
      });
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
                accountnum: element["Account Number"],user: element['User'],
                cashdetails: element["Cash Details"],
                cashname: element["Cash Name"],
                bal: element["Balance"],
                sts: element["Status"],
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
                bal: element["Balance"],user: element['User'],
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
                  top: _height / 8, left: 30, right: _width / 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      text: "Add Expense", size: 32, weight: FontWeight.bold),
                  Container(
                    margin:
                        EdgeInsets.only(top: _height / 7, left: 10, right: 10),
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
                              text: "Date",
                              size: 16,
                            )),
                        Expanded(
                          flex: 10,
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
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
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                              text: "Expense Category",
                              size: 16,
                            )),
                        Expanded(
                          flex: 10,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade200,
                            ),
                            child: DropdownButton(
                              underline: SizedBox(),
                              isExpanded: true,
                              hint: Text('Select expense'),
                              value: _selectedexpense,
                              onChanged: (newValue) {
                                setState(() {
                                  int indx = sexpense.indexOf(newValue);
                                  _selectedexpenseid = expense[indx];
                                  _selectedexpense = newValue.toString();
                                  if (indx == 0) {
                                    others = true;
                                  } else {
                                    others = false;
                                  }
                                });
                              },
                              items: expense.map((location) {
                                return DropdownMenuItem(
                                  child: new Text(location.name),
                                  value: location.name,
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  others
                      ? Container(
                          margin: EdgeInsets.only(top: 10, left: 10, right: 10),
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
                                    text: "Others",
                                    size: 16,
                                  )),
                              Expanded(
                                flex: 10,
                                child: TextFormField(
                                  controller: _conotherstext,
                                  decoration: InputDecoration(
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    hintText: "Others Expense Name",
                                    fillColor: Colors.grey.shade200,
                                    filled: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                  Container(
                    margin: EdgeInsets.only(top: 10, left: 10, right: 10),
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
                              text: "Expensed Amount",
                              size: 16,
                            )),
                        Expanded(
                          flex: 10,
                          child: TextFormField(
                            controller: _conExpenseAmount,
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
                              hintText: "Expensed Amount",
                              fillColor: Colors.grey.shade200,
                              filled: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
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
                        EdgeInsets.only(top: _height / 25, left: 10, right: 10),
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
            )),
          ],
        )));
  }
}
