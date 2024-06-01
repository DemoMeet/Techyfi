import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/pages/purchase/widgets/new_purchase_item.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../constants/style.dart';
import '../../model/Single.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../model/purchase.dart';
import '../../model/purchaseListModel.dart';
import '../../routing/routes.dart';
import '../../widgets/topnavigationbaredit.dart';

class EditPurchase extends StatefulWidget {
  PurchaseListModel cst;
  final void Function() refreshdata;
  EditPurchase(this.cst, this.refreshdata);
  @override
  State<EditPurchase> createState() => _EditPurchaseState();
}

class _EditPurchaseState extends State<EditPurchase> {
  double _listheight = 55.0,
      _subtotal = 0.0,
      _grandtotal = 0.0,
      _dueamount = 0.0;
  final _conpurinvoiceid = TextEditingController(),
      _conpurdetails = TextEditingController(),
      _conpurvat = TextEditingController(text: "0"),
      _conpurdiscount = TextEditingController(text: "0"),
      _conpurpaid = TextEditingController(text: "0");
  var manufact = [], smanufact = [];
  bool first = true;
  List<String> sproduct = [];
  List<Product> product = [];
  FirebaseStorage storage = FirebaseStorage.instance;
  var _selectedsupplier;
  List<Purchase> _listitem = [];
  var _selectedsupplierid;
  bool loading = true;
  DateTime selectedDate = DateTime.now();

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        setState(() {
          product.add(Product(
            name: element["Product Name"],
            category: element["Category Name"],
            brand: element["Brand Name"],
            user: element['User'],
            id: element.id,
            code: element['Code'],
            sl: 0,bodyrate: element["Body Rate"],
            details: element["Product Details"],
            menuperprice: element['Purchase Price'],
            perprice: element["Product Price"],
            strength: element["Strength"],
            unit: element["Unit Name"],
            img: element["Image"],
            imgurl: element["ImageURL"],
          ));
          sproduct.add(element["Product Name"].toString());
        });
      });
    });

    await FirebaseFirestore.instance
        .collection('Supplier')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        manufact.add(Single(name: element["Name"], id: element.id));
        smanufact.add(element["Name"].toString());
      });
      _List();
    });
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  Future<void> _save() async {
    // if (_selectedsupplier.toString().isEmpty ||
    //     _conpurinvoiceid.text.isEmpty || _conpurpaid.text.isEmpty ||
    //     _selectedpayment.toString().isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text(
    //         "Supplier's Name, Invoice ID and Payment Method is Required"),
    //   ));
    // } else {
    //   for (int ss = 0; ss < _listitem.length; ss++) {
    //     Purchase ps = _listitem[ss];
    //     if (ps.selectedproduct.isEmpty ||
    //         ps.batchidcontrollers.text.isEmpty ||
    //         ps.totalPurpricecontroller.text.isEmpty ||
    //         double.parse(ps.boxqtycontrollers.text) <= 0) {
    //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text(
    //             "Product, Batch ID is Required And Box Quantity Should be more the 0"),
    //       ));
    //     } else {
    //       if (ss == _listitem.length - 1) {
    //         FirebaseFirestore.instance.collection('Stock').add({
    //           'Product Name': ps.selectedproduct,
    //           'Product ID': ps.productId.id,
    //           'Batch': ps.batchidcontrollers.text,
    //           'Expire Date': ps.expiredate,
    //           'Leaf Type': ps.selectedleaf,
    //           'Leaf ID': ps.leafId.id,
    //           'Box Quantity': double.parse(ps.boxqtycontrollers.text),
    //           'Quantity': ps.quantity,
    //           'Product Per Price': ps.productId.perprice,
    //           'Supplier Per Price': ps.productId.menuperprice,
    //           'Supplier Box Price':
    //           double.parse(ps.supplierpricecontrollers.text),
    //           'Box Mrp': double.parse(ps.boxmrpcontrollers.text)
    //         });
    //         FirebaseFirestore.instance.collection('PurchaseItem').add({
    //           'Serial': ss + 1,
    //           'Product Name': ps.selectedproduct,
    //           'Product ID': ps.productId.id,
    //           'Batch': ps.batchidcontrollers.text,
    //           'Expire Date': ps.expiredate,
    //           'Leaf Type': ps.selectedleaf,
    //           'Leaf ID': ps.leafId.id,
    //           'Box Quantity': double.parse(ps.boxqtycontrollers.text),
    //           'Quantity': ps.quantity,
    //           'Invoice No': _conpurinvoiceid.text,
    //           'Invoice Date': selectedDate,
    //           'Product Per Price': ps.productId.perprice,
    //           'Supplier Per Price': ps.productId.menuperprice,
    //           'Supplier Box Price':
    //               double.parse(ps.supplierpricecontrollers.text),
    //           'Box Mrp': double.parse(ps.boxmrpcontrollers.text),
    //           'Total': double.parse(ps.totalPurpricecontroller.text)
    //         }).then((valu) {
    //           if (_dueamount > 0) {
    //             FirebaseFirestore.instance
    //                 .collection('Supplier')
    //                 .doc(_selectedsupplierid.id)
    //                 .get()
    //                 .then((element) {
    //               FirebaseFirestore.instance
    //                   .collection('Supplier')
    //                   .doc(_selectedsupplierid.id)
    //                   .update({
    //                 'Balance': element["Balance"] + _dueamount,
    //               }).then((value) {
    //                 FirebaseFirestore.instance.collection('Purchase').add({
    //                   'Payment Method': _selectedpayment,
    //                   'Details': _conpurdetails.text,
    //                   'Invoice No': _conpurinvoiceid.text,
    //                   'Invoice Date': selectedDate,
    //                   'Supplier': _selectedsupplier,
    //                   'Supplier ID': _selectedsupplierid.id,
    //                   'VAT': double.parse(_conpurvat.text),
    //                   'Discount': double.parse(_conpurdiscount.text),
    //                   'Paid': double.parse(_conpurpaid.text),
    //                   'Grand Total': _grandtotal,
    //                   'Due': _dueamount,
    //                 }).then((valu) {
    //                   Navigator.pop(context);
    //                   widget.refreshdata();
    //                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                     content: Text("Supplier Added Successfully!"),
    //                   ));
    //                 }).catchError(
    //                     (error) => print("Failed to add user: $error"));
    //               });
    //             });
    //           } else {
    //             FirebaseFirestore.instance.collection('Purchase').add({
    //               'Payment Method': _selectedpayment,
    //               'Details': _conpurdetails.text,
    //               'Invoice No': _conpurinvoiceid.text,
    //               'Invoice Date': selectedDate,
    //               'Supplier': _selectedsupplier,
    //               'Supplier ID': _selectedsupplierid.id,
    //               'VAT': double.parse(_conpurvat.text),
    //               'Discount': double.parse(_conpurdiscount.text),
    //               'Paid': double.parse(_conpurpaid.text),
    //               'Grand Total': _grandtotal,
    //               'Due': _dueamount,
    //             }).then((valu) {
    //               Navigator.pop(context);
    //               widget.refreshdata();
    //               ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //                 content: Text("Supplier Added Successfully!"),
    //               ));
    //             }).catchError((error) => print("Failed to add user: $error"));
    //           }
    //         }).catchError((error) => print("Failed to add user: $error"));
    //       } else {
    //         FirebaseFirestore.instance.collection('Stock').add({
    //           'Product Name': ps.selectedproduct,
    //           'Product ID': ps.productId.id,
    //           'Batch': ps.batchidcontrollers.text,
    //           'Expire Date': ps.expiredate,
    //           'Leaf Type': ps.selectedleaf,
    //           'Leaf ID': ps.leafId.id,
    //           'Box Quantity': double.parse(ps.boxqtycontrollers.text),
    //           'Quantity': ps.quantity,
    //           'Product Per Price': ps.productId.perprice,
    //           'Supplier Per Price': ps.productId.menuperprice,
    //           'Supplier Box Price':
    //           double.parse(ps.supplierpricecontrollers.text),
    //           'Box Mrp': double.parse(ps.boxmrpcontrollers.text),
    //         });
    //         FirebaseFirestore.instance.collection('PurchaseItem').add({
    //           'Serial': ss + 1,
    //           'Product Name': ps.selectedproduct,
    //           'Product ID': ps.productId.id,
    //           'Batch': ps.batchidcontrollers.text,
    //           'Expire Date': ps.expiredate,
    //           'Leaf Type': ps.selectedleaf,
    //           'Leaf ID': ps.leafId.id,
    //           'Box Quantity': double.parse(ps.boxqtycontrollers.text),
    //           'Quantity': ps.quantity,
    //           'Invoice No': _conpurinvoiceid.text,
    //           'Invoice Date': selectedDate,
    //           'Product Per Price': ps.productId.perprice,
    //           'Supplier Per Price': ps.productId.menuperprice,
    //           'Supplier Box Price':
    //               double.parse(ps.supplierpricecontrollers.text),
    //           'Box Mrp': double.parse(ps.boxmrpcontrollers.text),
    //           'Total': double.parse(ps.totalPurpricecontroller.text)
    //         });
    //       }
    //     }
    //   }
    // }
  }

  Future<void> _List() async {
    _selectedsupplierid = manufact[smanufact.indexOf(widget.cst.supplierName)];
    _selectedsupplier = widget.cst.supplierName;
    selectedDate = widget.cst.purchaseDate;

    _conpurinvoiceid.text = widget.cst.invoiceNo;
    _conpurdetails.text = widget.cst.details;
    _conpurvat.text = widget.cst.vat.toString();
    _conpurdiscount.text = widget.cst.discount.toString();
    _conpurpaid.text = widget.cst.paid.toString();

    _listitem = [];
    await FirebaseFirestore.instance
        .collection('PurchaseItem')
        .where("Invoice No", isEqualTo: widget.cst.invoiceNo)
        .orderBy("Serial")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        DateTime ss = element["Invoice Date"].toDate();
        if ((widget.cst.purchaseDate.month == ss.month) &&
            (widget.cst.purchaseDate.day == ss.day) &&
            (widget.cst.purchaseDate.year == ss.year)) {
          _listitem.add(Purchase.withid(
            pid: element.id,
              totalPurpricecontroller: TextEditingController(
                  text: (element["Supplier Price"] * element["Quantity"])
                      .toString()),
              stockquantity: await getStockqty(
                  product[sproduct.indexOf(element["Product Name"])].id),
              productId: product[sproduct.indexOf(element["Product Name"])],
              boxmrpcontrollers:
                  TextEditingController(text: element["Price"].toString()),
              boxqtycontrollers:
                  TextEditingController(text: element["Quantity"].toString()),
           //   expiredate: element["Expire Date"].toDate(),
              supplierpricecontrollers: TextEditingController(
                  text: element["Supplier Price"].toString()),
              selectedproduct: element["Product Name"]));
        }
      });
    });
  }

  Future<double> getStockqty(String pid) async {
    double stc = 0;
    await FirebaseFirestore.instance
        .collection('Stock')
        .doc(pid)
        .get()
        .then((element) {
      stc = element["Quantity"];
      loading = false;
      setState(() {});
    });
    return stc;
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
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _adddatase() {
    _subtotal = 0.0;
    _grandtotal = 0.0;
    _dueamount = 0.0;
    setState(() {
      for (var i = 0; i < _listitem.length; i++) {
        _subtotal =
            _subtotal + double.parse(_listitem[i].totalPurpricecontroller.text);
      }
      _grandtotal = double.parse(_conpurvat.text) -
          double.parse(_conpurdiscount.text) +
          _subtotal;
      _dueamount = _grandtotal - double.parse(_conpurpaid.text);
    });
  }

  void fullpaid() {
    setState(() {
      _conpurpaid.text = _grandtotal.toString();
      _dueamount = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    void deleteItem(Purchase index) {
      if (_listitem.length > 1) {
        setState(() {
          _listitem.remove(index);
        });
      }
    }

    Future<void> _getStock(String id, int index) async {
      // await FirebaseFirestore.instance
      //     .collection('Stock')
      //     .where("Product Name", isEqualTo: _listitem[index].productId.name)need to work here
      //     .where("Product ID", isEqualTo: _listitem[index].productId.id)
      //     .get()
      //     .then((querySnapshot) {
      //   querySnapshot.docs.forEach((element) {
      //     setState(() {
      //       _listitem[index].stockquantity += element["Quantity"];
      //     });
      //   });
      // });
    }

    return Scaffold(
      appBar: MyAppBarEdit(height: _height, width: _width),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: loading?Center(child: CircularProgressIndicator(),):Container(
          margin: EdgeInsets.only(
              top: 20, left: _width /12, right: _width / 12, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 30, right: 120),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(
                        text: "Edit Purchase",
                        size: 32,
                        weight: FontWeight.bold),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Supplier",
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: DropdownButton(
                          underline: SizedBox(),
                          isExpanded: true,
                          hint: const Text('Select Supplier'),
                          value: _selectedsupplier,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedsupplierid =
                                  manufact[smanufact.indexOf(newValue)];
                              _selectedsupplier = newValue.toString();
                            });
                          },
                          items: manufact.map((location) {
                            return DropdownMenuItem(
                              child: Text(location.name),
                              value: location.name,
                            );
                          }).toList(),
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
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
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
                    ),
                    const Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: TextFormField(
                          controller: _conpurinvoiceid,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            hintText: "Invoice No",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Details",
                          size: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: const EdgeInsets.only(left: 20),
                        child: TextFormField(
                          controller: _conpurdetails,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            hintText: "Purchase Details",
                            fillColor: Colors.grey.shade200,
                            filled: true,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(top: 10, left: 10, right: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Expanded(
              //         flex: 3,
              //         child: Container(
              //           alignment: Alignment.centerRight,
              //           child: CustomText(
              //             text: "Select Payment",
              //             size: 16,
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         flex: 5,
              //         child: Container(
              //           margin: const EdgeInsets.only(left: 20),
              //           child:Container(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 10, vertical: 15),
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(5),
              //               color: Colors.grey.shade200,
              //             ),
              //             child: CustomText(
              //               text: widget.cst.,
              //               size: 16,
              //             ),
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         flex: 2,
              //         child: Container(
              //           alignment: Alignment.centerRight,
              //           child: CustomText(
              //             text: "Bank Payment",
              //             size: 16,
              //           ),
              //         ),
              //       ),
              //       Expanded(
              //         flex: 5,
              //         child: Container(
              //           margin: EdgeInsets.only(left: 20),
              //           child: InkWell(
              //             onTap: () => _selectDate(context),
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(
              //                   horizontal: 10, vertical: 15),
              //               decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(5),
              //                 color: Colors.grey.shade200,
              //               ),
              //               child: CustomText(
              //                 text: widget.cst.,
              //                 size: 16,
              //               ),
              //             ),
              //           ),
              //         ),
              //       ),
              //       const Expanded(
              //         flex: 3,
              //         child: SizedBox(
              //           height: 1,
              //         ),
              //       )
              //     ],
              //   ),
              // ),
              Container(
                color: Colors.grey.shade200,
                margin: EdgeInsets.only(top: 20),
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 15, bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Product Code",
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
                      flex: 13,
                      child: Container(
                        margin: EdgeInsets.only(left: 15),
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
                          "Category",
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
                      flex: 4,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Unit",
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
                    //   flex: 6,
                    //   child: Container(
                    //     alignment: Alignment.center,
                    //     child: Text(
                    //       "Expire Date",
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
                      flex: 6,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Stock Qty",
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
                      flex: 7,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Quantity",
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
                        alignment: Alignment.center,
                        child: Text(
                          "Purchase Price",
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
                      flex: 6,
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 7),
                        child: Text(
                          "Sale Price",
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
                      flex: 12,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          "Total Purchase Price",
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
                          "ACTION",
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
                    return PurchaseItem(
                      product: product,
                      sproduct: sproduct,
                      index: index,
                      getStock: _getStock,
                      listitem: _listitem[index],
                      deleteItem: deleteItem,
                      adddatase: _adddatase,
                    );
                  },
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    Expanded(
                      flex: 74,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Sub Total",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    const Text("   "),
                    Expanded(
                      flex: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: EdgeInsets.only(left: 5, right: 5),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: CustomText(
                            text: _subtotal.toString(),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    Text(" "),
                    Expanded(
                      flex: 6,
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(5),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _listitem.add(Purchase(
                                  totalPurpricecontroller:
                                      TextEditingController(text: "0"),
                                  stockquantity: 0.0,
                                  productId: Product(
                                    name: '',
                                    category: '',
                                    brand: '',
                                    user: '',
                                    id: '',
                                    code: '',bodyrate: 0,
                                    sl: 0,
                                    details: '',
                                    menuperprice: 0,
                                    perprice: 0,
                                    strength: '',
                                    unit: '',
                                    img: false,
                                    imgurl: '',
                                  ),
                                  boxmrpcontrollers:
                                      TextEditingController(text: "0"),
                                  boxqtycontrollers:
                                      TextEditingController(text: "0"),
                   //               expiredate: DateTime.now(),
                                  supplierpricecontrollers:
                                      TextEditingController(text: "0"),
                                  selectedproduct: ""));
                            });
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.green,
                              ),
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.green[50],
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.green, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[400],
                width: double.infinity,
                margin: const EdgeInsets.only(top: 2),
                child: const SizedBox(
                  height: 0.2,
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    const Text(" "),
                    Expanded(
                      flex: 74,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "VAT",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    const Text("   "),
                    Expanded(
                      flex: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          controller: _conpurvat,
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _conpurvat.text = '0';
                            }
                            _adddatase();
                          },
                          keyboardType: TextInputType.number,
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
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 2),
                child: const SizedBox(
                  height: 0.2,
                ),
              ),
              Container(
                color: Colors.white,
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Expanded(
                      flex: 74,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Discount",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("   "),
                    Expanded(
                      flex: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          controller: _conpurdiscount,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d*)'))
                          ],
                          style: TextStyle(fontSize: 12),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _conpurdiscount.text = '0';
                            }
                            _adddatase();
                          },
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
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 6,
                    ),
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
                color: Colors.white,
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Expanded(
                      flex: 74,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Grand Total",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("   "),
                    Expanded(
                      flex: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: const EdgeInsets.only(left: 5, right: 5),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: CustomText(
                            text: _grandtotal.toString(),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    const Text(" "),
                    const Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 2),
                child: const SizedBox(
                  height: 0.2,
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Expanded(
                      flex: 74,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Paid Amount",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("   "),
                    Expanded(
                      flex: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey.shade500,
                          ),
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.white,
                        ),
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d*)'))
                          ],
                          controller: _conpurpaid,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              _conpurpaid.text = '0';
                            }
                            _adddatase();
                          },
                          textAlign: TextAlign.center,
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
                          ),
                        ),
                      ),
                    ),
                    const Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey,
                width: double.infinity,
                margin: const EdgeInsets.only(top: 2),
                child: const SizedBox(
                  height: 0.2,
                ),
              ),
              Container(
                color: Colors.white,
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
                child: Row(
                  children: [
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Text(" "),
                    Expanded(
                      flex: 74,
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Due Amount",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                    ),
                    Text("   "),
                    Expanded(
                      flex: 15,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        margin: EdgeInsets.only(left: 5, right: 5),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                          child: CustomText(
                            text: _dueamount.toString(),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                    Text(" "),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 6,
                    ),
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
                color: Colors.white,
                padding:
                    EdgeInsets.only(top: 15, left: 10, right: 30, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 13,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: ElevatedButton(
                          onPressed: () {
                            fullpaid();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            elevation: 20,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: CustomText(
                            text: "Full Paid",
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: ElevatedButton(
                          onPressed: () {
                            _save();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            elevation: 20,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: CustomText(
                            text: "Save",
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 1,
                      ),
                      flex: 1,
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
