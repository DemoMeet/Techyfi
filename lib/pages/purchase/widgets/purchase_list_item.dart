import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/purchaseListModel.dart';

class PurchaseListItem extends StatefulWidget {
  PurchaseListModel cst;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  final void Function(PurchaseListModel) onEditPurchase;
  final void Function(PurchaseListModel) onPurchseDetails;
  bool click;
  PurchaseListItem({
    required this.cst,
    required this.click,
    required this.changeVal,
    required this.onPurchseDetails,
    required this.index,
    required this.fetchDocuments,
    required this.onEditPurchase,
  });

  @override
  State<PurchaseListItem> createState() => _PurchaseListItemState();
}

class _PurchaseListItemState extends State<PurchaseListItem> {
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
            .collection('PurchaseItem')
            .where("Invoice No", isEqualTo: widget.cst.invoiceNo)
            .orderBy("Serial")
            .get()
            .then((querySnapshot) async {
          bool continueDeletion = true;

          for (var element in querySnapshot.docs) {
            DateTime ss = element["Invoice Date"].toDate();

            if ((widget.cst.purchaseDate.month == ss.month) &&
                (widget.cst.purchaseDate.day == ss.day) &&
                (widget.cst.purchaseDate.year == ss.year)) {
              await FirebaseFirestore.instance
                  .collection('Stock')
                  .doc(element["Product ID"])
                  .get()
                  .then((ssss) async {
                int quantity = ssss["Quantity"];

                if (!(quantity >= element["Quantity"])) {
                  continueDeletion = false;
                }
              });
            }
          }

          if (continueDeletion) {
            for (var element in querySnapshot.docs) {
              DateTime ss = element["Invoice Date"].toDate();

              if ((widget.cst.purchaseDate.month == ss.month) &&
                  (widget.cst.purchaseDate.day == ss.day) &&
                  (widget.cst.purchaseDate.year == ss.year)) {
                await FirebaseFirestore.instance
                    .collection('Stock')
                    .doc(element["Product ID"])
                    .get()
                    .then((ssss) async {
                  int quantity = ssss["Quantity"];

                  if (quantity >= element["Quantity"]) {
                    await FirebaseFirestore.instance
                        .collection('Stock')
                        .doc(element["Product ID"])
                        .update({"Quantity": quantity - element["Quantity"]});
                    await FirebaseFirestore.instance
                        .collection('PurchaseItem').doc(element.id).delete();
                  }
                });

                if (widget.cst.due > 0) {
                  FirebaseFirestore.instance
                      .collection('Supplier')
                      .doc(widget.cst.supplierID)
                      .get()
                      .then((element) {
                    FirebaseFirestore.instance
                        .collection('Supplier')
                        .doc(widget.cst.supplierID)
                        .update({
                      'Balance': element["Balance"] - widget.cst.due,
                    }).then((value) async {
                      FirebaseFirestore.instance
                          .collection('Transaction')
                          .where("ID", isEqualTo: widget.cst.purchaseID)
                          .get()
                          .then((value) {
                        value.docs.forEach((elements) async {
                          DateTime ss = elements["Date"].toDate();
                          if ((widget.cst.purchaseDate.month == ss.month) &&
                              (widget.cst.purchaseDate.day == ss.day) &&
                              (widget.cst.purchaseDate.year == ss.year)) {
                            FirebaseFirestore.instance
                                .collection('Transaction')
                                .doc(elements.id)
                                .delete();
                          }
                        });
                      });
                      await FirebaseFirestore.instance
                          .collection('Account')
                          .doc(widget.cst.accountID)
                          .get()
                          .then((ssss) async {
                        await FirebaseFirestore.instance
                            .collection('Account')
                            .doc(widget.cst.accountID)
                            .update(
                                {"Balance": ssss["Balance"] + widget.cst.paid});
                      });

                      FirebaseFirestore.instance
                          .collection('Purchase')
                          .doc(widget.cst.purchaseID)
                          .delete()
                          .then((value) {
                        widget.fetchDocuments();
                        Get.back();
                      });
                    });
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('Transaction')
                      .where("ID", isEqualTo: widget.cst.purchaseID)
                      .get()
                      .then((value) {
                    value.docs.forEach((elements) async {
                      DateTime ss = elements["Date"].toDate();
                      if ((widget.cst.purchaseDate.month == ss.month) &&
                          (widget.cst.purchaseDate.day == ss.day) &&
                          (widget.cst.purchaseDate.year == ss.year)) {
                        FirebaseFirestore.instance
                            .collection('Transaction')
                            .doc(elements.id)
                            .delete();
                      }
                    });
                  });
                  await FirebaseFirestore.instance
                      .collection('Account')
                      .doc(widget.cst.accountID)
                      .get()
                      .then((ssss) async {
                    await FirebaseFirestore.instance
                        .collection('Account')
                        .doc(widget.cst.accountID)
                        .update({"Balance": ssss["Balance"] + widget.cst.paid});
                  });

                  FirebaseFirestore.instance
                      .collection('Purchase')
                      .doc(widget.cst.purchaseID)
                      .delete()
                      .then((value) { widget.fetchDocuments();
                  Get.back();});
                }
              } else {
                Get.snackbar("Purchase Delete Failed.",
                    "Item Is Already Sold So cannot Process the Delete!",
                    snackPosition: SnackPosition.BOTTOM,
                    colorText: Colors.white,
                    backgroundColor: Colors.red,
                    margin: EdgeInsets.zero,
                    duration: const Duration(milliseconds: 2000),
                    boxShadows: [
                      const BoxShadow(
                          color: Colors.grey,
                          offset: Offset(-100, 0),
                          blurRadius: 20),
                    ],
                    borderRadius: 0);
                break;
              }
            }
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
                    widget.cst.purchaseID,
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
                    widget.cst.supplierName,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMMMd().format(widget.cst.purchaseDate),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
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
                flex: 2,
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
                                            widget.onPurchseDetails(
                                              widget.cst,
                                            );
                                          },
                                          child: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: _width / 75,
                                          )),
                                      // InkWell(
                                      //     onTap: (){
                                      //       widget.onEditPurchase(widget.cst);
                                      //     },
                                      //     child: Icon(
                                      //       Icons.edit_outlined,
                                      //       size: _width/75,
                                      //     )),
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
                                          onTap: () {},
                                          child: Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: _width / 55,
                                          )),
                                      InkWell(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.edit_outlined,
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
