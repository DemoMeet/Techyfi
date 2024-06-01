import 'dart:collection';
import 'dart:math';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/pages/return/widgets/return_pur_list_item.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/pages/return/widgets/return_list_item.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../model/Accounts.dart';
import '../../model/Single.dart';
import '../../model/Stock.dart';
import '../../model/StockReturnItem.dart';
import '../../model/invoiceListModel.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../model/purchase.dart';
import '../../model/purchaseListModel.dart';
import '../../routing/routes.dart';
import '../../widgets/topnavigationbaredit.dart';

class ReturnPurchase extends StatefulWidget {
  InvoiceListModel cst;
  ReturnPurchase({
    required this.cst,
    required this.nn,
  });
  Navbools nn;
  @override
  State<ReturnPurchase> createState() => _ReturnPurchaseState();
}

class _ReturnPurchaseState extends State<ReturnPurchase> {
  List<StockReturnItem> _listitem = [];
  double nettotal = 0, totaldeduction = 0;
  bool selectedpm = false, bankpayment = false, processing = true;
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var payment = ["Bank Payment", "Cash Payment"];
  var _selectedaccount, _selectedpayment;
  var _selectedAccountid;

  int _sts = 1;
  _getItem() async {
    await FirebaseFirestore.instance
        .collection('PurchaseItem')
        .where("Invoice No", isEqualTo: widget.cst.invoiceNo)
        // .where("Invoice Date", isEqualTo: widget.cst.invoiceDate)
        // .orderBy("Serial")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        double qty = 0;
        await FirebaseFirestore.instance
            .collection('Stock')
            .doc(element["Product ID"])
            .get()
            .then((element) {
          qty = element["Quantity"];
        });
        setState(() {
          _listitem.add(StockReturnItem(
              deductioncontrollers: TextEditingController(text: "0"),
              returnqtycontrollers: TextEditingController(text: "0"),
              id: element.id,
              discount: qty,
              check: false,
    //          expireDate: element["Expire Date"].toDate(),
              productId: element["Product ID"],
              deductionval: 0,
              productName: element["Product Name"],
              qty: element["Quantity"],
              price: element["Price"],
              serial: element["Serial"],
              returningtotal: 0,
              buyingtotal: element["Total"]));
        });
      });
    }).catchError((error) => print("Failed to add user: $error"));


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
                user: element['User'],
                sts: element["Status"],
                bankname: element["Bank Name"],
                bank: element["Bank"],
                branch: element["Branch"],
                sl: 0));
            sbankaccounts.add(element["Account Number"]);
            if(element.id == widget.cst.accountID){
              selectedpm = true;
              bankpayment = true;
              _selectedpayment = "Bank Payment";
              _selectedaccount = element["Bank Name"];
              _selectedAccountid = _bankaccounts[
              sbankaccounts
                  .indexOf(element["Bank Name"])];
            }
          } else {

            _cashaccounts.add(Accounts(
                uid: element["UID"],
                accountname: element["Account Name"],
                accountnum: element["Account Number"],
                cashdetails: element["Cash Details"],
                cashname: element["Cash Name"],
                user: element['User'],
                bal: element["Balance"],
                sts: element["Status"],
                bankname: element["Bank Name"],
                bank: element["Bank"],
                branch: element["Branch"],
                sl: 0));
            scashaccounts.add(element["Cash Name"].toString());

            if(element.id == widget.cst.accountID){
              selectedpm = true;
              bankpayment = false;_selectedpayment = "Cash Payment";
              _selectedaccount =  element["Cash Name"];
              _selectedAccountid = _cashaccounts[
              scashaccounts
                  .indexOf(element["Cash Name"])];
            }
          }
          processing = false;
        });
      });
    });
  }

  updatetotals() {
    nettotal = 0;
    totaldeduction = 0;
    for (int i = 0; i < _listitem.length; i++) {
      StockReturnItem ss = _listitem[i];
      setState(() {
        nettotal = ss.returningtotal + nettotal;
        totaldeduction =
            double.parse(ss.deductioncontrollers.text) + totaldeduction;
      });
    }
  }

  Future<void> _save() async {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String rtnID = getRandomString(20);
    if (nettotal == 0 ||
        _selectedpayment.toString() == "null" ||
        _selectedAccountid.toString() == "null") {
      setState(() {
        processing = false;
      });
      Get.snackbar("Purchase Return Failed.",
          "Net total should not be 0 and payment method should be selected is Required",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          margin: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2000),
          boxShadows: [
            BoxShadow(
                color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
          ],
          borderRadius: 0);
    } else {
      if (_selectedAccountid.bal > nettotal) {
        if (_listitem
                .where((element) =>
                    element.check && element.returnqtycontrollers.text == "0")
                .toString() !=
            "()") {
          Get.snackbar("Purchase Return Failed.",
              "Checked Item Quantity Cannot be Zero..",
              snackPosition: SnackPosition.BOTTOM,
              colorText: Colors.white,
              backgroundColor: Colors.red,
              margin: EdgeInsets.zero,
              duration: const Duration(milliseconds: 2000),
              boxShadows: [
                BoxShadow(
                    color: Colors.grey,
                    offset: Offset(-100, 0),
                    blurRadius: 20),
              ],
              borderRadius: 0);
        } else {
          List<StockReturnItem> _listupdateds =
              _listitem.where((element) => element.check).toList();
          List<Map<String, dynamic>> list = [];
          for (int i = 0; i < _listupdateds.length; i++) {
            StockReturnItem ss = _listupdateds[i];
            list.add({
              "Product Name": ss.productName,
              "Product ID": ss.productId,
              "Return Qty": double.parse(ss.returnqtycontrollers.text),
              "Deduction": double.parse(ss.deductioncontrollers.text),
              "Quantity": ss.qty,
              "Price": ss.price,
            });
          }
          bool allValuesTrue = await checkAllValues(list);

          if (allValuesTrue) {
            if (_sts == 2) {
              List<StockReturnItem> _listupdated =
                  _listitem.where((element) => element.check).toList();
              List<Map> list = [];
              for (int i = 0; i < _listupdated.length; i++) {
                StockReturnItem ss = _listupdated[i];
                list.add({
                  "Product Name": ss.productName,
                  "Product ID": ss.productId,
                  "Return Qty": double.parse(ss.returnqtycontrollers.text),
                  "Deduction": double.parse(ss.deductioncontrollers.text),
                  "Quantity": ss.qty,
                  "Price": ss.price,
                });

                FirebaseFirestore.instance
                    .collection('Stock')
                    .doc(ss.productId)
                    .get()
                    .then((val) {
                  FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(ss.productId)
                      .update({
                    'Quantity': val['Quantity'] -
                        double.parse(ss.returnqtycontrollers.text),
                  });
                });
                FirebaseFirestore.instance
                    .collection('Wastage')
                    .doc(ss.productId)
                    .get()
                    .then((value) {
                  if (value.exists) {
                    FirebaseFirestore.instance
                        .collection('Wastage')
                        .doc(ss.productId)
                        .update({
                      "Product Name": ss.productName,
                      "Product ID": ss.productId,
                      "Quantity": double.parse(ss.returnqtycontrollers.text) + value["Quantity"],
                      "Price": ss.price,
                      'Total Buying': ss.buyingtotal + value['Total Buying'],
                    });
                  } else {
                    FirebaseFirestore.instance
                        .collection('Wastage')
                        .doc(ss.productId)
                        .set({
                      "Product Name": ss.productName,
                      "Product ID": ss.productId,
                      "Quantity": double.parse(ss.returnqtycontrollers.text),
                      "Price": ss.price,
                      'Total Buying': ss.buyingtotal,
                    });
                  }
                });
              }
              FirebaseFirestore.instance.collection('Return').doc(rtnID).set({
                'Returns': list,
                'Date': widget.cst.invoiceDate,
                'Invoice ID': '',
                'Purchase ID': widget.cst.invoiceID,
                'Customer Name': '',
                'Supplier Name': widget.cst.customerName,
                'ID': widget.cst.customerID,
                'Return ID': rtnID,
                'User': AuthService.to.user?.name,
                'Invoice No': widget.cst.invoiceNo,
                'Purchase': true,
                'Wastage': true,
                'Return Type': "Wastage Purchase Return",
                'Total Amount': nettotal,
                'Total Deduction': totaldeduction,
                'Return Date': DateTime.now(),
              }).then((valu) {
                widget.nn.setnavbool();
                widget.nn.return_invoice_list = true;
                widget.nn.returnss = true;
                Navigator.of(context)
                    .pushReplacementNamed(supplierreturnlistPageRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Returned Successfully!"),
                ));
              }).catchError((error) => print("Failed to add user: $error"));
            } else {
              List<StockReturnItem> _listupdated =
                  _listitem.where((element) => element.check).toList();
              List<Map> list = [];
              for (int i = 0; i < _listupdated.length; i++) {
                StockReturnItem ss = _listupdated[i];
                list.add({
                  "Product Name": ss.productName,
                  "Product ID": ss.productId,
                  "Return Qty": double.parse(ss.returnqtycontrollers.text),
                  "Deduction": double.parse(ss.deductioncontrollers.text),
                  "Quantity": ss.qty,
                  "Price": ss.price,
                });
                FirebaseFirestore.instance
                    .collection('Stock')
                    .doc(ss.productId)
                    .get()
                    .then((val) {
                  FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(ss.productId)
                      .update({
                    'Quantity': val['Quantity'] -
                        double.parse(ss.returnqtycontrollers.text),
                  });
                });
              }

              FirebaseFirestore.instance
                  .collection('Supplier')
                  .doc(widget.cst.customerID)
                  .get()
                  .then((element) {
                FirebaseFirestore.instance
                    .collection('Supplier')
                    .doc(widget.cst.customerID)
                    .update({
                  'Balance': element["Balance"] - nettotal,
                });
              });

              FirebaseFirestore.instance.collection('Transaction').add({
                'Name': widget.cst.customerName,
                '2nd ID': widget.cst.customerID,
                'Remarks': "Purchase Return",
                'Submit Date': DateTime.now(),
                'Type': 'Debit',
                'Date': DateTime.now(),
                'Payment Method': _selectedpayment,
                'ID': rtnID,
                'User': AuthService.to.user?.name,
                'Account ID': _selectedAccountid.uid,
                'Account Details': _selectedAccountid.toJson(),
                'Amount': nettotal,
              });
              FirebaseFirestore.instance
                  .collection('Account')
                  .doc(_selectedAccountid.uid)
                  .update({
                'Balance': _selectedAccountid.bal + nettotal,
              });

              FirebaseFirestore.instance
                  .collection('Purchase')
                  .doc(widget.cst.invoiceID)
                  .update({
                'Return': true,
              });
              FirebaseFirestore.instance.collection('Return').doc(rtnID).set({
                'Returns': list,
                'Date': widget.cst.invoiceDate,
                'Invoice ID': '',
                'Purchase ID': widget.cst.invoiceID,
                'Customer Name': '',
                'Supplier Name': widget.cst.customerName,
                'ID': widget.cst.customerID,
                'Invoice No': widget.cst.invoiceNo,
                'Return ID': rtnID,
                'User': AuthService.to.user?.name,
                'Purchase': true,
                'Wastage': false,
                'Return Type': "Purchase Return",
                'Total Amount': nettotal,
                'Total Deduction': totaldeduction,
                'Return Date': DateTime.now(),
              }).then((valu) {
                widget.nn.setnavbool();
                widget.nn.return_invoice_list = true;
                widget.nn.returnss = true;
                Navigator.of(context)
                    .pushReplacementNamed(supplierreturnlistPageRoute);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Returned Successfully!"),
                ));
              }).catchError((error) => print("Failed to add user: $error"));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "There Is One Or More Product Which is not available in Stock!!"),
            ));
          }
        }
      } else {
        setState(() {
          processing = false;
        });
        Get.snackbar("Purchase Return Failed.",
            "Account Doesn't have sufficient balance",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.red,
            margin: EdgeInsets.zero,
            duration: const Duration(milliseconds: 2000),
            boxShadows: [
              BoxShadow(
                  color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
            ],
            borderRadius: 0);
      }
    }
  }

  Future<bool> checkAllValues(List<Map<String, dynamic>> objects) async {
    List<Future<bool>> futures = [];

    for (Map<String, dynamic> obj in objects) {
      Future<bool> future = FirebaseFirestore.instance
          .collection('Stock')
          .doc(obj["Product ID"])
          .get()
          .then((value) {
          if (value["Quantity"] < obj["Return Qty"]) {
            print("Some values are false1");
            return false;
          }
        return true;
      });

      futures.add(future);
    }

    List<bool> results = await Future.wait(futures);

    // Check if any result is false, then return false
    if (results.contains(false)) {
      return false;
    }

    // If all results are true, return true
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getItem();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: MyAppBarEdit(height: _height, width: _width),
      body:processing?Center(child: CircularProgressIndicator(),): SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          margin: EdgeInsets.only(
              top: 20, left: _width / 6, right: _width / 6, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(left: 30),
                child: CustomText(
                    text: "Add Supplier Return",
                    size: 32,
                    weight: FontWeight.bold),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Invoice No",
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: CustomText(
                          text: widget.cst.invoiceNo,
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Date",
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: CustomText(
                          text: DateFormat.yMMMd()
                              .format(widget.cst.invoiceDate)
                              .toString(),
                          size: 16,
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Supplier Name",
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: CustomText(
                          text: widget.cst.customerName,
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Select Payment",
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 5,
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
                              value: location,
                              child: Text(location),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 10,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    selectedpm
                        ? bankpayment
                            ? Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: CustomText(
                                    text: "Bank Payment",
                                    size: 16,
                                  ),
                                ),
                              )
                            : Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: CustomText(
                                    text: "Cash Payment",
                                    size: 16,
                                  ),
                                ),
                              )
                        : const SizedBox(),
                    const SizedBox(
                      width: 10,
                    ),
                    selectedpm
                        ? bankpayment
                            ? Expanded(
                                flex: 5,
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
                                        _selectedaccount = newValue.toString();
                                        _selectedAccountid = _bankaccounts[
                                            sbankaccounts
                                                .indexOf(newValue.toString())];
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
                                flex: 5,
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
                                        _selectedaccount = newValue.toString();
                                        _selectedAccountid = _cashaccounts[
                                            scashaccounts
                                                .indexOf(newValue.toString())];
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
                    selectedpm
                        ? const Expanded(
                            flex: 9,
                            child: SizedBox(
                              height: 1,
                            ),
                          )
                        : const Expanded(
                            flex: 10,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey.shade200,
                margin: EdgeInsets.only(top: 20),
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "ACTION",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 10,
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "Product Info",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Brought Qty",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Avail Qty",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Return Qty",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Price",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Deduction",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("|"),
                    Expanded(
                      flex: 7,
                      child: Container(
                        child: Text(
                          "Total",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _listitem.length,
                  itemBuilder: (context, index) {
                    return ReturnPurListItem(
                      index: index,
                      cst: _listitem[index],
                      updatetotals: updatetotals,
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                          flex: 28,
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            child: Text(
                              "Total Deduction",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: tabletitle,
                                  fontFamily: 'inter'),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            child: Text(
                              totaldeduction.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: tabletitle,
                                  fontFamily: 'inter'),
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
              ),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15, top: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(),
                          flex: 28,
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            child: Text(
                              "Net Return",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: tabletitle,
                                  fontFamily: 'inter'),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(
                            margin: EdgeInsets.only(left: 7),
                            child: Text(
                              nettotal.toString(),
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: tabletitle,
                                  fontFamily: 'inter'),
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
              ),
              Container(
                color: Colors.grey,
                width: double.infinity,
                margin: EdgeInsets.only(top: 2),
                child: SizedBox(
                  height: 0.2,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 15, left: 10, right: 30, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 7,
                    ),
                    Expanded(
                      flex: 12,
                      child: Container(
                        margin: EdgeInsets.only(left: 5),
                        child: Column(
                          children: [
                            RadioListTile(
                              title: Text(
                                "Adjust With Stock",
                                style: TextStyle(fontSize: 14),
                              ),
                              value: 1,
                              groupValue: _sts,
                              onChanged: (value) {
                                setState(() {
                                  _sts = int.parse(value.toString());
                                });
                              },
                            ),
                            RadioListTile(
                              title: const Text(
                                "Wastage",
                                style: TextStyle(fontSize: 14),
                              ),
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
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 20,
                    ),
                    Expanded(
                      flex: 9,
                      child: Container(
                        child: ElevatedButton(
                          onPressed: () {
                            _save();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonbg,
                            elevation: 20,
                            padding: EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                          ),
                          child: CustomText(
                            text: "Return",
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
                      flex: 7,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
