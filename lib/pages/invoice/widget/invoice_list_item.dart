import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

import '../../../constants/style.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/purchaseListModel.dart';

class InvoiceListItem extends StatefulWidget {
  InvoiceListModel cst;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  final void Function(InvoiceListModel) onEditInvoice;
  final void Function(InvoiceListModel) onInvoiceDetails;
  final void Function(InvoiceListModel) onInvoiceDetailsPOS;
  bool click;
  InvoiceListItem({
    required this.cst,
    required this.click,
    required this.changeVal,
    required this.onInvoiceDetails,
    required this.onInvoiceDetailsPOS,
    required this.index,
    required this.fetchDocuments,
    required this.onEditInvoice,
  });

  @override
  State<InvoiceListItem> createState() => _InvoiceListItemState();
}

class _InvoiceListItemState extends State<InvoiceListItem> {
  showDeleteDialog() {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Get.back();
      },
    );
    Widget continueButton = TextButton(
      child: const Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection('Account')
            .doc(widget.cst.accountID)
            .get()
            .then((ssss) async {
          if (ssss["Balance"] >= widget.cst.paid) {
            await FirebaseFirestore.instance
                .collection('Account')
                .doc(widget.cst.accountID)
                .update({"Balance": ssss["Balance"] - widget.cst.paid});

            await FirebaseFirestore.instance
                .collection('InvoiceItem')
                .where("Invoice No", isEqualTo: widget.cst.invoiceNo)
                .orderBy("Serial")
                .get()
                .then((querySnapshot) {
              querySnapshot.docs.forEach((element) async {
                DateTime ss = element["Invoice Date"].toDate();

                if ((widget.cst.invoiceDate.month == ss.month) &&
                    (widget.cst.invoiceDate.day == ss.day) &&
                    (widget.cst.invoiceDate.year == ss.year)) {
                  await FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(element["Product ID"])
                      .get()
                      .then((ssss) async {
                    int quantity = ssss["Quantity"];
                    await FirebaseFirestore.instance
                        .collection('Stock')
                        .doc(element["Product ID"])
                        .update({"Quantity": quantity + element["Quantity"]});

                    await FirebaseFirestore.instance
                        .collection('InvoiceItem').doc(element.id).delete();
                  });
                }
              });

              if (widget.cst.customerName == "Walking Customer") {
                FirebaseFirestore.instance
                    .collection('Transaction')
                    .where("ID", isEqualTo: widget.cst.invoiceID)
                    .get()
                    .then((value) {
                  value.docs.forEach((elements) async {
                    DateTime ss = elements["Date"].toDate();
                    if ((widget.cst.invoiceDate.month == ss.month) &&
                        (widget.cst.invoiceDate.day == ss.day) &&
                        (widget.cst.invoiceDate.year == ss.year)) {
                      FirebaseFirestore.instance
                          .collection('Transaction')
                          .doc(elements.id)
                          .delete();
                    }
                  });
                });

                FirebaseFirestore.instance
                    .collection('Invoice')
                    .doc(widget.cst.invoiceID)
                    .delete()
                    .then((value) {
                      Get.back();
                      widget.fetchDocuments();
                });
              } else {
                FirebaseFirestore.instance
                    .collection('Customer')
                    .doc(widget.cst.customerID)
                    .get()
                    .then((element) {
                  FirebaseFirestore.instance
                      .collection('Customer')
                      .doc(widget.cst.customerID)
                      .update({
                    'Balance': element["Balance"] - widget.cst.paid,
                  });
                });
                FirebaseFirestore.instance
                    .collection('Transaction')
                    .where("ID", isEqualTo: widget.cst.invoiceID)
                    .get()
                    .then((value) {
                  value.docs.forEach((elements) async {
                    DateTime ss = elements["Date"].toDate();
                    if ((widget.cst.invoiceDate.month == ss.month) &&
                        (widget.cst.invoiceDate.day == ss.day) &&
                        (widget.cst.invoiceDate.year == ss.year)) {
                      FirebaseFirestore.instance
                          .collection('Transaction')
                          .doc(elements.id)
                          .delete();
                    }
                  });
                });
                FirebaseFirestore.instance
                    .collection('Invoice')
                    .doc(widget.cst.invoiceID)
                    .delete()
                    .then((value) {

                  Get.back();
                  widget.fetchDocuments();
                });
              }
            }).catchError((error) => print("Failed to add user: $error"));
          } else {
            Get.snackbar(
                "Invoice Delete Failed.", "No Money Available in account!",
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
          }
        });
      },
    );
    Get.dialog(
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: AlertDialog(
              title: const Text(
                "Confirmation To Delete!!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Text(
                    "Permanently Delete the Purchase Including Transaction and all things related to Invoice No ${widget.cst.invoiceNo}?"),
              ),
              actions: [
                cancelButton,
                continueButton,
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.cst.sl + 1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.invoiceNo,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.invoiceID,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.customerName,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMd().format(widget.cst.invoiceDate),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "৳${widget.cst.total}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "৳${NumberFormat('#,##,#00.##').format(widget.cst.profit).toString()}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: widget.click
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin:
                                EdgeInsets.only(right: _width / 35, left: 10),
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
                                      InkWell(
                                          onTap: () {
                                            widget.onInvoiceDetails(widget.cst);
                                          },
                                          child: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: _width / 75,
                                          )),
                                      InkWell(
                                          onTap: () {
                                            widget.onInvoiceDetailsPOS(
                                                widget.cst);
                                          },
                                          child: Icon(
                                            Icons.point_of_sale_outlined,
                                            size: _width / 75,
                                          )),
                                      InkWell(
                                          onTap: () {
                                            showDeleteDialog();
                                          },
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: _width / 75,
                                          )),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            widget.onInvoiceDetails(widget.cst);
                                          },
                                          child: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: _width / 55,
                                          )),
                                      InkWell(
                                          onTap: () {
                                            widget.onInvoiceDetailsPOS(
                                                widget.cst);
                                          },
                                          child: Icon(
                                            Icons.point_of_sale_outlined,
                                            size: _width / 55,
                                          )),
                                      InkWell(
                                          onTap: () {
                                            showDeleteDialog();
                                          },
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
                            margin: EdgeInsets.only(right: _width / 25),
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
                                child: Icon(
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
