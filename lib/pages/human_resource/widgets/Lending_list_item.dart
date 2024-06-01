import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Accounts.dart';
import '../../../model/Lending.dart';
import '../../../model/nav_bools.dart';
import '../../../routing/routes.dart';
import '../../../widgets/custom_text.dart';

class LendingListItem extends StatefulWidget {
  Lending cst;

  Navbools nn;
  List<Accounts> bankaccounts = [];
  List<Accounts> cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var payment = ["Bank Payment", "Cash Payment"];
  int index;
  final void Function(String) changeVal;
  final void Function(Lending) editLending;
  bool click;

  bool selectedpm = false, bankpayment = false;

  var selectedaccount, selectedpayment;
  var selectedAccountid;
  LendingListItem(
      {required this.cst,
      required this.click,
      required this.changeVal,
      required this.bankaccounts,
      required this.nn,
      required this.cashaccounts,
      required this.sbankaccounts,
      required this.scashaccounts,
      required this.selectedaccount,
      required this.selectedpayment,
      required this.selectedAccountid,
      required this.index,
      required this.editLending});

  @override
  State<LendingListItem> createState() => _LendingListItemState();
}

class _LendingListItemState extends State<LendingListItem> {
  double width = 1200;

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;

    showLendingPaymentDetailsDialog(BuildContext context, Lending lending) {
      final _conlendingreturnAmount = TextEditingController();
      final _conlendingreturnRemarks = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext contest) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                backgroundColor: Colors.white,
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2.7,
                  height: width / 3,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 0.5, color: Colors.white),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15)),
                              color: Colors.grey.shade200,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            width: double.infinity,
                            child: Row(
                              children: [
                                CustomText(
                                  text: "Add Return Payment For Lending",
                                  size: 18,
                                  weight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                const Expanded(child: SizedBox()),
                                GestureDetector(
                                  child: Icon(Icons.close),
                                  onTap: () {
                                    Navigator.of(contest).pop();
                                  },
                                ),
                              ],
                            )),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: CustomText(
                                        text: "Lending Person Name",
                                        font: "opensans",
                                        weight: FontWeight.bold,
                                        size: 14,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 10,
                                      child: CustomText(
                                        text: lending.name,
                                        font: "inter",
                                        size: 14,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: CustomText(
                                        text: "Lending Date",
                                        font: "opensans",
                                        weight: FontWeight.bold,
                                        size: 14,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 10,
                                      child: CustomText(
                                        size: 14,
                                        text: DateFormat.yMMMd()
                                            .format(lending.date.toDate())
                                            .toString(),
                                        font: "inter",
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: CustomText(
                                        text: "Returned Amount ",
                                        font: "opensans",
                                        weight: FontWeight.bold,
                                        size: 14,
                                      ),
                                    ),
                                    Expanded(
                                        flex: 10,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 40,
                                                child: TextFormField(
                                                  controller:
                                                      _conlendingreturnAmount,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(RegExp(r'[0-9]')),
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  style: TextStyle(fontSize: 14),
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                          color:
                                                              Colors.transparent),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue),
                                                    ),
                                                    hintText:
                                                        "Lending Return Amount",
                                                    fillColor:
                                                        Colors.grey.shade200,
                                                    filled: true,
                                                    isDense: true,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5,),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _conlendingreturnAmount.text =
                                                      lending.amount.toString();
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.all(10),
                                                child: CustomText(
                                                  text: "Full Paid",
                                                  font: "opensans",
                                                  color: Colors.green,
                                                  weight: FontWeight.bold,
                                                  size: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: CustomText(
                                          text: "Select Payment",
                                          weight: FontWeight.bold,
                                          size: 14,
                                        )),
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: DropdownButton(
                                          underline: const SizedBox(),
                                          isExpanded: true,
                                          hint: const Text(
                                            'Select Payment',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          value: widget.selectedpayment,
                                          onChanged: (newValue) {
                                            setState(() {
                                              if (newValue.toString() ==
                                                  widget.payment[0]) {
                                                widget.selectedpm = true;
                                                widget.bankpayment = true;
                                                var vs;
                                                widget.selectedaccount = vs;
                                                widget.selectedAccountid = vs;
                                              } else {
                                                widget.selectedpm = true;
                                                widget.bankpayment = false;
                                                var vs;
                                                widget.selectedaccount = vs;
                                                widget.selectedAccountid = vs;
                                              }
                                              widget.selectedpayment =
                                                  newValue.toString();
                                              print(widget.selectedpayment);
                                            });
                                          },
                                          items: widget.payment.map((location) {
                                            return DropdownMenuItem(
                                              value: location,
                                              child: Text(
                                                location,
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              widget.selectedpm
                                  ? Container(
                                      margin: const EdgeInsets.only(
                                          top: 5, left: 10, right: 10),
                                      child: Row(
                                        children: [
                                          widget.bankpayment
                                              ? Expanded(
                                                  flex: 5,
                                                  child: CustomText(
                                                    text: "Bank Payment",
                                                    weight: FontWeight.bold,
                                                    size: 14,
                                                  ))
                                              : Expanded(
                                                  flex: 5,
                                                  child: CustomText(
                                                    text: "Cash Payment",
                                                    weight: FontWeight.bold,
                                                    size: 14,
                                                  )),
                                          widget.bankpayment
                                              ? Expanded(
                                                  flex: 10,
                                                  child: Container(
                                                    height: 40,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                    child: DropdownButton(
                                                      underline:
                                                          const SizedBox(),
                                                      isExpanded: true,
                                                      hint: const Text(
                                                        'Select Bank Account',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      value: widget
                                                          .selectedaccount,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          widget.selectedaccount =
                                                              newValue
                                                                  .toString();
                                                          widget
                                                              .selectedAccountid = widget
                                                                  .bankaccounts[
                                                              widget
                                                                  .sbankaccounts
                                                                  .indexOf(newValue
                                                                      .toString())];
                                                        });
                                                      },
                                                      items: widget.bankaccounts
                                                          .map((location) {
                                                        return DropdownMenuItem(
                                                          value: location
                                                              .accountnum,
                                                          child: Text(
                                                            "${location.bankname} (${location.accountnum})",
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                )
                                              : Expanded(
                                                  flex: 10,
                                                  child: Container(
                                                    height: 40,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 2),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                                    child: DropdownButton(
                                                      underline:
                                                          const SizedBox(),
                                                      isExpanded: true,
                                                      hint: const Text(
                                                        'Select Cash Counter',
                                                        style: TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      value: widget
                                                          .selectedaccount,
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          widget.selectedaccount =
                                                              newValue
                                                                  .toString();
                                                          widget
                                                              .selectedAccountid = widget
                                                                  .cashaccounts[
                                                              widget
                                                                  .scashaccounts
                                                                  .indexOf(newValue
                                                                      .toString())];
                                                        });
                                                      },
                                                      items: widget.cashaccounts
                                                          .map((location) {
                                                        return DropdownMenuItem(
                                                          value:
                                                              location.cashname,
                                                          child: Text(
                                                            location.cashname,
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                )
                                        ],
                                      ),
                                    )
                                  : SizedBox(),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 5,
                                        child: CustomText(
                                          text: "Remarks",
                                          weight: FontWeight.bold,
                                          size: 14,
                                        )),
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        height: 40,
                                        child: TextFormField(
                                          controller: _conlendingreturnRemarks,
                                          maxLines: null,
                                          style: TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                            ),
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                              borderSide: BorderSide(
                                                  color: Colors.blue),
                                            ),
                                            hintText: "Remarks",
                                            fillColor: Colors.grey.shade200,
                                            filled: true,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 5, left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                            const _chars =
                                                'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                            Random _rnd = Random();
                                            String getRandomString(
                                                    int length) =>
                                                String.fromCharCodes(
                                                    Iterable.generate(
                                                        length,
                                                        (_) => _chars
                                                            .codeUnitAt(_rnd
                                                                .nextInt(_chars
                                                                    .length))));
                                            String ss = getRandomString(20);

                                            double amount = double.parse(
                                                _conlendingreturnAmount.text
                                                    .toString());
                                            if (widget.selectedpayment
                                                        .toString() ==
                                                    "null" ||
                                                widget.selectedAccountid
                                                        .toString() ==
                                                    "null" ||
                                                _conlendingreturnRemarks
                                                    .text.isEmpty ||
                                                _conlendingreturnAmount
                                                    .text.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "All Fields are Required to Process lending!!"),
                                              ));
                                            } else {
                                              if (amount > lending.amount) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                        const SnackBar(
                                                  content: Text(
                                                      "Return Amount Cannot be Bigger than Lending Amount!!"),
                                                ));
                                              } else if (amount ==
                                                  lending.amount) {
                                                FirebaseFirestore.instance
                                                    .collection('Transaction')
                                                    .add({
                                                  'Name': lending.name,
                                                  '2nd ID': lending.uid,
                                                  'Remarks': "Lending Return",
                                                  'Submit Date': DateTime.now(),
                                                  'Date': DateTime.now(),
                                                  'Type': 'Credit',
                                                  'Payment Method':
                                                      widget.selectedpayment,
                                                  'ID': ss,
                                                  'Account ID': widget
                                                      .selectedAccountid.uid,
                                                  'Account Details': widget
                                                      .selectedAccountid
                                                      .toJson(),
                                                  'Amount': amount,
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('Account')
                                                    .doc(widget
                                                        .selectedAccountid.uid)
                                                    .update({
                                                  'Balance': widget
                                                          .selectedAccountid
                                                          .bal +
                                                      amount,
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('Lending')
                                                    .doc(lending.uid)
                                                    .update({
                                                  'Return Date': DateTime.now(),
                                                  'Returned Amount': amount,
                                                  'Status': "Returned",
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('LendingPayment')
                                                    .doc(ss)
                                                    .set({
                                                  'Lending Person Name': lending.name,
                                                  'Lending Person ID':
                                                      lending.lendingpersonid,
                                                  'Lending ID': lending.uid,
                                                  'Amount': amount,
                                                  'Status':'Credit',
                                                  'Remarks':
                                                      _conlendingreturnRemarks
                                                          .text,
                                                  'Date': DateTime.now(),
                                                  'UID': ss,
                                                }).then((value) {
                                                  widget.nn.setnavbool();
                                                  widget.nn.human_resource =
                                                      true;
                                                  widget.nn
                                                          .human_resource_lending =
                                                      true;
                                                  widget.nn
                                                          .human_resource_lendinglist =
                                                      true;
                                                  Navigator.of(context)
                                                      .pushReplacementNamed(
                                                          lendinglistPageRoute);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    content: Text(
                                                        "Attendance Added Successfully!"),
                                                  ));
                                                }).catchError((error) => print(
                                                        "Failed to add user: $error"));
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection('Transaction')
                                                    .add({
                                                  'Name': lending.name,
                                                  '2nd ID': lending.uid,
                                                  'Remarks': "Lending Return",
                                                  'Submit Date': DateTime.now(),
                                                  'Date': DateTime.now(),
                                                  'Type': 'Credit',
                                                  'Payment Method':
                                                      widget.selectedpayment,
                                                  'ID': ss,
                                                  'Account ID': widget
                                                      .selectedAccountid.uid,
                                                  'Account Details': widget
                                                      .selectedAccountid
                                                      .toJson(),
                                                  'Amount': amount,
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('Account')
                                                    .doc(widget
                                                        .selectedAccountid.uid)
                                                    .update({
                                                  'Balance': widget
                                                          .selectedAccountid
                                                          .bal +
                                                      amount,
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('Lending')
                                                    .doc(lending.uid)
                                                    .update({
                                                  'Returned Amount': amount,
                                                  'Status': "Current",
                                                  'Return Date': DateTime.now(),
                                                });
                                                FirebaseFirestore.instance
                                                    .collection('LendingPayment')
                                                    .doc(ss)
                                                    .set({
                                                  'Lending Person Name': lending.name,
                                                  'Lending Person ID':
                                                      lending.lendingpersonid,
                                                  'Status':'Credit',
                                                  'Lending ID': lending.uid,
                                                  'Amount': amount,
                                                  'Remarks':
                                                      _conlendingreturnRemarks
                                                          .text,
                                                  'Date': DateTime.now(),
                                                  'UID': ss,
                                                }).then((value) {
                                                  widget.nn.setnavbool();
                                                  widget.nn.human_resource =
                                                      true;
                                                  widget.nn
                                                          .human_resource_lending =
                                                      true;
                                                  widget.nn
                                                          .human_resource_lendinglist =
                                                      true;
                                                  Navigator.of(context)
                                                      .pushReplacementNamed(
                                                          lendinglistPageRoute);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    backgroundColor:
                                                        Colors.green,
                                                    content: Text(
                                                        "Attendance Added Successfully!"),
                                                  ));
                                                }).catchError((error) => print(
                                                        "Failed to add user: $error"));
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: buttonbg,
                                            elevation: 20,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 20),
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
                              SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height / 16,
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.cst.sl + 1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.name,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.cst.date.toDate())
                        .toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMMMd()
                        .format(widget.cst.returndate.toDate())
                        .toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.from,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.amount.toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.returnedamount.toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.status,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  alignment: Alignment.center,
                  child: widget.click
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey.shade200,
                            ),
                            child: _width > 830
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      widget.cst.status == "Current"
                                          ? InkWell(
                                              onTap: () {
                                                showLendingPaymentDetailsDialog(
                                                    context, widget.cst);
                                              },
                                              child: Icon(
                                                Icons.attach_money_outlined,
                                                size: _width / 70,
                                              ))
                                          : SizedBox(),
                                      InkWell(
                                          onTap: () {
                                            widget.editLending(widget.cst);
                                          },
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: _width / 70,
                                          )),
                                      InkWell(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: _width / 70,
                                          )),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      widget.cst.status == "Current"
                                          ? InkWell(
                                              onTap: () {
                                                showLendingPaymentDetailsDialog(
                                                    context, widget.cst);
                                              },
                                              child: Icon(
                                                Icons.attach_money_outlined,
                                                size: _width / 70,
                                              ))
                                          : SizedBox(),
                                      InkWell(
                                          onTap: () {
                                            widget.editLending(widget.cst);
                                          },
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: _width / 55,
                                          )),
                                      InkWell(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: _width / 55,
                                          )),
                                    ],
                                  ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey.shade200,
                            ),
                            child: InkWell(
                                onTap: () {
                                  widget.changeVal(widget.index.toString());
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                  size: 18,
                                )),
                          ),
                        ),
                ),
              ),
            ],
          ),
          Container(
            height: .2,
            margin: EdgeInsets.only(top: 10),
            width: double.infinity,
            color: tabletitle,
          )
        ],
      ),
    );
  }
}
