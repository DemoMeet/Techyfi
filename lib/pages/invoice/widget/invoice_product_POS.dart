import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:groceyfi02/pages/invoice/widget/pos_invoice_item.dart';

import '../../../api/pdf_invoicePOS.dart';
import '../../../constants/style.dart';
import '../../../helpers/auth_service.dart';
import '../../../model/Accounts.dart';
import '../../../model/POSItem.dart';
import '../../../model/Single.dart';
import '../../../model/Stock.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/nav_bools.dart';
import '../../../routing/routes.dart';
import '../../../widgets/custom_text.dart';

class InvoiceProductPOS extends StatefulWidget {
  final bool column;
  final List<POSItem> positems;
  int innum;
  String selectedcustomer;
  Single selectedcustomerid;
  Navbools nn;
  final void Function() fetchDocuments;
  var custmr = [];
  List<Accounts> cashaccounts = [];
  List<Accounts> bankaccounts = [];
  final void Function(POSItem) removeproductfrominvoice;
  final void Function() adddatase, fullpaid;
  final double subtotal, grandtotal, nettotal, previous, dueamount;
  final conpurvat, conpurdiscount, conpurpaid;
  bool selectedpm, bankpayment;
  InvoiceProductPOS(
      {required this.column,
      required this.nn,
      required this.positems,
      required this.adddatase,
      required this.grandtotal,
      required this.innum,
      required this.selectedpm,
      required this.bankpayment,
      required this.selectedcustomer,
      required this.selectedcustomerid,
      required this.custmr,
      required this.subtotal,
      required this.nettotal,
      required this.previous,
      required this.fullpaid,
      required this.dueamount,
      required this.conpurvat,
      required this.conpurdiscount,
      required this.conpurpaid,
      required this.removeproductfrominvoice,
      required this.bankaccounts,
      required this.fetchDocuments,
      required this.cashaccounts});

  @override
  State<InvoiceProductPOS> createState() => _InvoiceProductPOSState();
}

class _InvoiceProductPOSState extends State<InvoiceProductPOS> {
  Future<void> _savedatate(Accounts accs) async {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    bool hasEmptyField = false;
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String invoiceID = getRandomString(20);
    DateTime newdate = DateTime.now();
    if (widget.conpurpaid.text.isEmpty || widget.positems.isEmpty) {
      Get.snackbar("Sales Adding Failed.",
          "Product, Account and Payment Method is Required",
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
      widget.positems.forEach((ps) {
        if (ps.quantity.text.isEmpty || double.parse(ps.quantity.text) <= 0) {
          hasEmptyField = true;
        }
      });
      if (hasEmptyField) {
        Get.snackbar("Sales Adding Failed.",
            "Product and Quantity is Required And Quantity Should be more the 0",
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
      } else if (widget.custmr[0].name == widget.selectedcustomer &&
          widget.dueamount != 0) {
        Get.snackbar(
            "Sales Adding Failed.", "Walking Customer Has to Pay Full Amount!!",
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
        for (int ss = 0; ss < widget.positems.length; ss++) {
          POSItem ps = widget.positems[ss];
          if (ss == widget.positems.length - 1) {
            FirebaseFirestore.instance
                .collection('Stock')
                .doc(ps.product.code)
                .update({
              'Quantity':
                  ps.selectedStock.productqty - double.parse(ps.quantity.text),
            });
            FirebaseFirestore.instance.collection('InvoiceItem').add({
              'Serial': ss + 1,
              'Product Name': ps.product.name,
              'Product ID': ps.product.id,
       //       'Expire Date': ps.selectedStock.expireDate,
              'Quantity': double.parse(ps.quantity.text),
              'Invoice No': widget.innum.toString(),
              "Body Rate": ps.product.bodyrate,
              'Invoice Date': newdate,
              'Price': ps.product.perprice,
              'Discount': 0.0,
              'Total': ps.total
            }).then((valu) {
              if (widget.custmr[0] == widget.selectedcustomer ||
                  widget.dueamount == 0) {
                FirebaseFirestore.instance.collection('Transaction').add({
                  'Name': widget.selectedcustomer,
                  '2nd ID': widget.selectedcustomerid.id,
                  'Remarks': "POS Invoice",
                  'Submit Date': DateTime.now(),
                  'Date': newdate,
                  'Type': 'Credit',
                  'User': AuthService.to.user?.name,
                  'Payment Method':
                      widget.bankpayment ? "Bank Payment" : "Cash Payment",
                  'ID': invoiceID,
                  'Account ID': accs.uid,
                  'Account Details': accs.toJson(),
                  'Amount': double.parse(widget.conpurpaid.text),
                });
                FirebaseFirestore.instance
                    .collection('Account')
                    .doc(accs.uid)
                    .update({
                  'Balance': accs.bal + double.parse(widget.conpurpaid.text),
                });
                FirebaseFirestore.instance
                    .collection('Invoice')
                    .doc(invoiceID)
                    .set({
                  'Payment Method':
                      widget.bankpayment ? "Bank Payment" : "Cash Payment",
                  'Details': "/*/POS INVOICE/*/",
                  'Invoice No': widget.innum.toString(),
                  'User': AuthService.to.user?.name,
                  'Return':false,
                  'Invoice Date': newdate,
                  "Account ID": accs.uid,
                  'Customer': widget.selectedcustomer,
                  'Customer ID': widget.selectedcustomerid.id,
                  'VAT': double.parse(widget.conpurvat.text),
                  'Discount': double.parse(widget.conpurdiscount.text),
                  'Paid': double.parse(widget.conpurpaid.text),
                  'Grand Total': widget.grandtotal,
                  'Due': widget.dueamount,
                  'Net Total': widget.nettotal,
                }).then((valu) {
                  setState(() {
                    widget.fetchDocuments();
                  });
                //  _makepdf(invoiceID);
                  Get.snackbar(
                      "Sales Adding Successfully.", "Printing The Invoice Page",
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.green,
                      margin: EdgeInsets.zero,
                      duration: const Duration(milliseconds: 2000),
                      boxShadows: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(-100, 0),
                            blurRadius: 20),
                      ],
                      borderRadius: 0);
                }).catchError((error) => print("Failed to add user: $error"));
              } else {
                FirebaseFirestore.instance
                    .collection('Customer')
                    .doc(widget.selectedcustomerid.id)
                    .get()
                    .then((element) {
                  FirebaseFirestore.instance
                      .collection('Customer')
                      .doc(widget.selectedcustomerid.id)
                      .update({
                    'Balance': widget.dueamount,
                  }).then((value) {
                    FirebaseFirestore.instance.collection('Transaction').add({
                      'Name': widget.selectedcustomer,
                      '2nd ID': widget.selectedcustomerid.id,
                      'Remarks': "POS Invoice",
                      'User': AuthService.to.user?.name,
                      'Type': 'Credit',
                      'Submit Date': DateTime.now(),
                      'Date': newdate,
                      'Payment Method':
                          widget.bankpayment ? "Bank Payment" : "Cash Payment",
                      'ID': invoiceID,
                      'Account ID': accs.uid,
                      'Account Details': accs.toJson(),
                      'Amount': double.parse(widget.conpurpaid.text),
                    });
                    FirebaseFirestore.instance
                        .collection('Account')
                        .doc(accs.uid)
                        .update({
                      'Balance':
                          accs.bal + double.parse(widget.conpurpaid.text),
                    });
                    FirebaseFirestore.instance
                        .collection('Invoice')
                        .doc(invoiceID)
                        .set({
                      'Payment Method':
                          widget.bankpayment ? "Bank Payment" : "Cash Payment",
                      'Details': "/*/POS INVOICE/*/",
                      'Invoice No': widget.innum.toString(),
                      'Invoice Date': newdate,
                      "Account ID": accs.uid,
                      'Return':false,
                      'Customer': widget.selectedcustomer,
                      'User': AuthService.to.user?.name,
                      'Customer ID': widget.selectedcustomerid.id,
                      'VAT': double.parse(widget.conpurvat.text),
                      'Discount': double.parse(widget.conpurdiscount.text),
                      'Paid': double.parse(widget.conpurpaid.text),
                      'Grand Total': widget.grandtotal,
                      'Net Total': widget.nettotal,
                      'Due': widget.dueamount,
                    }).then((valu) {
                      setState(() {
                        widget.fetchDocuments();
                      });
                  //    _makepdf(invoiceID);
                      Get.snackbar("Sales Adding Successfully.",
                          "Printing The Invoice Page",
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: Colors.white,
                          backgroundColor: Colors.green,
                          margin: EdgeInsets.zero,
                          duration: const Duration(milliseconds: 2000),
                          boxShadows: [
                            BoxShadow(
                                color: Colors.grey,
                                offset: Offset(-100, 0),
                                blurRadius: 20),
                          ],
                          borderRadius: 0);
                    }).catchError(
                            (error) => print("Failed to add user: $error"));
                  });
                });
              }
            }).catchError((error) => print("Failed to add user: $error"));
          } else {
            FirebaseFirestore.instance
                .collection('Stock')
                .doc(ps.product.code)
                .update({
              'Quantity':
                  ps.selectedStock.productqty - double.parse(ps.quantity.text),
            });
            FirebaseFirestore.instance.collection('InvoiceItem').add({
              'Serial': ss + 1,
              'Product Name': ps.product.name,
              'Product ID': ps.product.id,
          //    'Expire Date': ps.selectedStock.expireDate,
              'Quantity': double.parse(ps.quantity.text),
              "Body Rate": ps.product.bodyrate,
              'Invoice No': widget.innum.toString(),
              'Invoice Date': newdate,
              'Price': ps.product.perprice,
              'Discount': 0.0,
              'Total': ps.total
            });
          }
        }
      }
    }
  }

  Future<void> _makepdf(String invoiceid) async {
    InvoiceListModel? invs;
    String invnum = '';
    double save = 0;

    await FirebaseFirestore.instance
        .collection('Invoice')
        .doc(invoiceid)
        .get()
        .then((element) {
      invnum = element["Invoice No"];
      invs = InvoiceListModel(
        discount: element["Discount"],
        total: element["Grand Total"],
        due: element["Due"],
        paid: element["Paid"],retn: element["Return"],
        profit: 0,
        accountID: element["Account ID"],
        invoiceNo: element["Invoice No"],
        user: element['User'],
        customerID: element["Customer ID"],
        customerName: element["Customer"],
        invoiceDate: element["Invoice Date"].toDate(),
        invoiceID: element.id,
        sl: 0,
      );
    });

    List<Stock> InvoiceList = [];

    await FirebaseFirestore.instance
        .collection('InvoiceItem')
        .orderBy("Serial", descending: false)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element["Invoice No"] == invnum) {
          save = save + (element["Body Rate"] * element["Quantity"]);
          InvoiceList.add(Stock.forInvoice(
            productId: element["Product ID"],
            productName: element["Product Name"],
     //       expireDate: element["Expire Date"].toDate(),
            price: element["Price"],
            productqty: element["Quantity"],
            serial: element["Serial"],
            total: element["Total"],
            discount: element["Discount"],
          ));
        }
      });
    }).catchError((error) => print("Failed to add user: $error"));

    await PdfInvoicePOS.generate(invs!, InvoiceList, save);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
          color: Colors.white,
          border: Border.all(
            width: 0.5,
            color: Colors.white,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(4, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                color: Colors.grey.shade200,
                padding: EdgeInsets.only(top: 20, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      flex: widget.column ? 6 : 6,
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Text(
                          "Product Information",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    // Text("|"),
                    // Expanded(
                    //   flex: 4,
                    //   child: Container(
                    //     child: Text(
                    //       "Expire Date",
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //           fontSize: 12,
                    //           fontWeight: FontWeight.bold,
                    //           color: tabletitle,
                    //           fontFamily: 'inter'),
                    //     ),
                    //   ),
                    // ),
                    Text("|"),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          "Quantity",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    widget.column ? Text("|") : Text(" |"),
                    Expanded(
                      flex: 3,
                      child: Container(
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
                        child: Text(
                          "Total",
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
                      flex: widget.column ? 3 : 2,
                      child: Container(
                        margin: EdgeInsets.only(right: 10),
                        child: Text(
                          "Action",
                          textAlign: TextAlign.center,
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
                child: widget.positems.length == 0
                    ? Container(
                        margin: EdgeInsets.only(top: 5),
                        child: CustomText(
                          text: "No Product Selected",
                          size: 14,
                          weight: FontWeight.bold,
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.positems.length,
                        itemBuilder: (context, index) {
                          return POSInvoiceItem(
                              adddatase: widget.adddatase,
                              posItem: widget.positems[index],
                              removeproductfrominvoice:
                                  widget.removeproductfrominvoice);
                        },
                      ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Sub Total:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: CustomText(
                            text: widget.subtotal.toString(),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 2,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Invoice Discount:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: widget.conpurdiscount,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              widget.conpurdiscount.text = '0';
                            }
                            widget.adddatase();
                          },
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d*)'))
                          ],
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            isDense: true,
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
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "0.00",
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 2,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "VAT:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: widget.conpurvat,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              widget.conpurvat.text = '0';
                            }
                            widget.adddatase();
                          },
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d*)'))
                          ],
                          style: TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            isDense: true,
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
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "0.00",
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 2,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Grand Total:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: CustomText(
                            text: widget.grandtotal.toString(),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 2,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Previous:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: CustomText(
                            text: widget.previous.toString(),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 2,
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Net Total:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: CustomText(
                            text: widget.nettotal.toString(),
                            size: 12,
                          ),
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
                margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Paid Amount:",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        alignment: Alignment.center,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: widget.conpurpaid,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              widget.conpurpaid.text = '0';
                            }
                            widget.adddatase();
                          },
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d*)'))
                          ],
                          style: TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            isDense: true,
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
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "0.00",
                          ),
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
                margin: const EdgeInsets.only(
                    top: 5, left: 10, right: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex: 9, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Due Amount",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                        )),
                    const SizedBox(
                      width: 28,
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: CustomText(
                            text: widget.dueamount.toString(),
                            size: 12,
                          ),
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
                margin: const EdgeInsets.only(
                    top: 5, left: 10, right: 10, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.selectedpm
                        ? Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  widget.selectedpm = false;
                                });
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.white,
                                  border: Border.all(width: 0.5, color: dark),
                                ),
                                child: Icon(Icons.arrow_back_outlined,
                                    color: dark),
                              ),
                            ),
                          )
                        : SizedBox(),
                    widget.selectedpm
                        ? Expanded(
                            flex: 6,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 5),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Select Account : ",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: tabletitle,
                                    fontFamily: 'inter'),
                              ),
                            ),
                          )
                        : const SizedBox(),
                    widget.selectedpm
                        ? Expanded(flex: 10, child: Container())
                        : Expanded(flex: 19, child: Container()),
                    widget.selectedpm
                        ? const Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 1,
                            ),
                          )
                        : SizedBox(),
                    Expanded(
                      flex: 4,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.fullpaid();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrangeAccent,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: CustomText(
                          text: "Full Paid",
                          color: Colors.white,
                          size: 12,
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
              widget.selectedpm
                  ? Container(
                      color: Colors.grey.shade500,
                      width: double.infinity,
                      height: 1,
                    )
                  : SizedBox(),
              !widget.selectedpm
                  ? Container(
                      color: Colors.white,
                      padding: const EdgeInsets.only(
                          top: 5, left: 30, right: 30, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            flex: 12,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  widget.selectedpm = true;
                                  widget.bankpayment = true;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                elevation: 20,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                              ),
                              child: CustomText(
                                text: "Bank Payment",
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    widget.selectedpm = true;
                                    widget.bankpayment = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  elevation: 20,
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                ),
                                child: CustomText(
                                  text: "Cash Payment",
                                  color: Colors.white,
                                  size: 12,
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
                        ],
                      ),
                    )
                  : const SizedBox(),
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    widget.selectedpm
                        ? widget.bankpayment
                            ? SizedBox(
                                height: MediaQuery.of(context).size.height / 20,
                                child: MediaQuery.removePadding(
                                  removeTop: true,
                                  context: context,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: widget.bankaccounts.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _savedatate(
                                                widget.bankaccounts[index]);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            elevation: 20,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 10),
                                          ),
                                          child: CustomText(
                                            text:
                                                "${widget.bankaccounts[index].bankname} (${widget.bankaccounts[index].accountnum})",
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : SizedBox(
                                height: MediaQuery.of(context).size.height / 20,
                                child: MediaQuery.removePadding(
                                  removeTop: true,
                                  context: context,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: widget.cashaccounts.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: const EdgeInsets.only(left: 5),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _savedatate(
                                                widget.cashaccounts[index]);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            elevation: 20,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 10),
                                          ),
                                          child: CustomText(
                                            text: widget
                                                .cashaccounts[index].cashname,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                        : const SizedBox(),
                    const SizedBox(
                      width: 45,
                    ),
                  ],
                ),
              ),
              widget.selectedpm
                  ? const SizedBox(
                      height: 20,
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
