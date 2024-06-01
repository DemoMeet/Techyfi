import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/model/Accounts.dart';
import 'package:groceyfi02/pages/purchase/widgets/new_purchase_item.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../helpers/screen_size_controller.dart';
import '../../model/Single.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../model/purchase.dart';
import '../../routing/routes.dart';
import '../../widgets/scanning_progressbar.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddPurchase extends StatefulWidget {
  Navbools nn;
  AddPurchase({required this.nn});
  @override
  State<AddPurchase> createState() => _AddPurchaseState();
}

class _AddPurchaseState extends State<AddPurchase> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  double _subtotal = 0.0, _grandtotal = 0.0, _dueamount = 0.0;
  final _conpurinvoiceid = TextEditingController(),
      _conpurdetails = TextEditingController(),
      _conpurvat = TextEditingController(text: "0"),
      _conpurdiscount = TextEditingController(text: "0"),
      _conpurpaid = TextEditingController(text: "0");
  var manufact = [], smanufact = [], payment = ["Bank Payment", "Cash Payment"];
  bool selectedpm = false, bankpayment = false, processing = true;
  List<String> sproduct = [];
  List<Product> product = [];
  FirebaseStorage storage = FirebaseStorage.instance;
  var _selectedsupplier, _selectedpayment;
  List<Purchase> _listitem = [];
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount;
  var _selectedAccountid;
  var _selectedsupplierid;
  DateTime selectedDate = DateTime.now();

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Purchase')
        .get()
        .then((querySnapshot) {
      int innum = 1;
      querySnapshot.docs.forEach((element) {
        innum++;
      });
      _conpurinvoiceid.text = innum.toString();
    });

    await FirebaseFirestore.instance
        .collection('Supplier')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        manufact.add(Single(name: element["Name"], id: element.id));
        smanufact.add(element["Name"].toString());
      });
    });

    await FirebaseFirestore.instance
        .collection('Account')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        if (element["Bank"]) {
          _bankaccounts.add(Accounts(
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
          sbankaccounts.add(element["Account Number"]);
        } else {
          _cashaccounts.add(Accounts(
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
          scashaccounts.add(element["Cash Name"].toString());
        }
      });
    });
    product = [];
    sproduct = [];
    await FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        product.add(Product(
          name: element["Product Name"],
          category: element["Category Name"],
          brand: element["Brand Name"],
          user: element['User'],
          id: element.id,bodyrate: element["Body Rate"],
          code: element['Code'],
          sl: 0,
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
    processing = false;
    setState(() {});
  }

  @override
  void initState() {
    _fetchDatas();
    _listitem.add(Purchase(
        totalPurpricecontroller: TextEditingController(text: "0"),
        stockquantity: 0.0,
        productId: Product(
          name: '',
          category: '',
          brand: '',
          user: '',
          id: '',
          code: '',
          sl: 0,bodyrate: 0,
          details: '',
          menuperprice: 0,
          perprice: 0,
          strength: '',
          unit: '',
          img: false,
          imgurl: '',
        ),
        boxmrpcontrollers: TextEditingController(text: "0"),
        boxqtycontrollers: TextEditingController(text: "0"),
   //     expiredate: DateTime.now(),
        supplierpricecontrollers: TextEditingController(text: "0"),
        selectedproduct: ""));
    super.initState();
  }

  Future<void> _save() async {
    setState(() {
      processing = true;
    });
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String purchID = getRandomString(20);
    if (_selectedsupplier.toString().isEmpty ||
        _conpurinvoiceid.text.isEmpty ||
        _conpurpaid.text.isEmpty ||
        _selectedpayment.toString() == "null" ||
        _selectedAccountid.toString() == "null") {
      setState(() {
        processing = false;
      });
      Get.snackbar("Purchase Adding Failed.",
          "Supplier's Name, Invoice ID, Account and Payment Method is Required",
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
      bool hasEmptyField = false;
      if (_selectedAccountid.bal > double.parse(_conpurpaid.text)) {
        _listitem.forEach((ps) {
          if (ps.selectedproduct.isEmpty ||
              ps.totalPurpricecontroller.text.isEmpty ||
              double.parse(ps.boxqtycontrollers.text) <= 0) {
            hasEmptyField = true;
          }
        });
        if (hasEmptyField) {
          setState(() {
            processing = false;
          });
          Get.snackbar("Purchase Adding Failed.",
              "Product and Quantity is Required And Quantity Should be more the 0",
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
          for (int ss = 0; ss < _listitem.length; ss++) {
            Purchase ps = _listitem[ss];
            if (ss == _listitem.length - 1) {
              FirebaseFirestore.instance
                  .collection('Stock')
                  .doc(ps.productId.code)
                  .get()
                  .then((valss) {
                if (valss.exists) {
                  FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(ps.productId.code)
                      .update({
                    'Quantity': double.parse(ps.boxqtycontrollers.text) +
                        valss['Quantity'],
               //     'Expire Date': ps.expiredate,
                    'Body Rate': ps.productId.bodyrate,
                    'Supplier Price':
                        double.parse(ps.supplierpricecontrollers.text),
                    'Price': double.parse(ps.boxmrpcontrollers.text),
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(ps.productId.code)
                      .set({
                    'Product Name': ps.selectedproduct,
                    'Product ID': ps.productId.id,
            //        'Expire Date': ps.expiredate,
                    'Body Rate': ps.productId.bodyrate,
                    'Quantity': double.parse(ps.boxqtycontrollers.text),
                    'Supplier Price':
                        double.parse(ps.supplierpricecontrollers.text),
                    'Price': double.parse(ps.boxmrpcontrollers.text),
                  });
                }
              });

              FirebaseFirestore.instance.collection('PurchaseItem').add({
                'Serial': ss + 1,
                'Product Name': ps.selectedproduct,
                'Product ID': ps.productId.id,
                'Code': ps.productId.code,
          //      'Expire Date': ps.expiredate,
                'Quantity': double.parse(ps.boxqtycontrollers.text),
                'Invoice No': _conpurinvoiceid.text,
                'Invoice Date': selectedDate,
                'Supplier Price':
                    double.parse(ps.supplierpricecontrollers.text),
                'Price': double.parse(ps.boxmrpcontrollers.text),
                'Total': double.parse(ps.totalPurpricecontroller.text)
              }).then((valu) {
                if (_dueamount > 0) {
                  FirebaseFirestore.instance
                      .collection('Supplier')
                      .doc(_selectedsupplierid.id)
                      .get()
                      .then((element) {
                    FirebaseFirestore.instance
                        .collection('Supplier')
                        .doc(_selectedsupplierid.id)
                        .update({
                      'Balance': element["Balance"] + _dueamount,
                    }).then((value) {
                      FirebaseFirestore.instance.collection('Transaction').add({
                        'Name': _selectedsupplierid.name,
                        '2nd ID': _selectedsupplierid.id,
                        'Remarks': "Purchase",
                        'Submit Date': DateTime.now(),
                        'User': AuthService.to.user?.name,
                        'Type': 'Debit',
                        'Date': selectedDate,
                        'Payment Method': _selectedpayment,
                        'ID': purchID,
                        'Account ID': _selectedAccountid.uid,
                        'Account Details': _selectedAccountid.toJson(),
                        'Amount': double.parse(_conpurpaid.text),
                      });
                      FirebaseFirestore.instance
                          .collection('Account')
                          .doc(_selectedAccountid.uid)
                          .update({
                        'Balance': _selectedAccountid.bal -
                            double.parse(_conpurpaid.text),
                      });

                      FirebaseFirestore.instance
                          .collection('Purchase')
                          .doc(purchID)
                          .set({
                        'Payment Method': _selectedpayment,
                        'Details': _conpurdetails.text,
                        'Invoice No': _conpurinvoiceid.text,
                        'Invoice Date': selectedDate,
                        'User': AuthService.to.user?.name,
                        'Return':false,
                        'Account ID': _selectedAccountid.uid,
                        'Supplier': _selectedsupplier,
                        'Supplier ID': _selectedsupplierid.id,
                        'VAT': double.parse(_conpurvat.text),
                        'Discount': double.parse(_conpurdiscount.text),
                        'Paid': double.parse(_conpurpaid.text),
                        'Grand Total': _grandtotal,
                        'Due': _dueamount,
                      }).then((valu) {
                        widget.nn.setnavbool();
                        widget.nn.purchase = true;
                        widget.nn.purchase_list = true;
                        Get.offNamed(purchaselistPageRoute);
                        Get.snackbar("Purchase Adding Successfully.",
                            "Redirecting to Purchase List Page",
                            snackPosition: SnackPosition.BOTTOM,
                            colorText: Colors.white,
                            backgroundColor: Colors.green,
                            margin: EdgeInsets.zero,
                            duration: const Duration(milliseconds: 2000),
                            boxShadows: [
                              BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                            ],
                            borderRadius: 0);
                      }).catchError(
                              (error) => print("Failed to add user: $error"));
                    });
                  });
                } else {
                  FirebaseFirestore.instance.collection('Transaction').add({
                    'Name': _selectedsupplierid.name,
                    '2nd ID': _selectedsupplierid.id,
                    'Remarks': "Purchase",
                    'Submit Date': DateTime.now(),
                    'Date': selectedDate,
                    'Payment Method': _selectedpayment,
                    'Type': 'Debit',
                    'User': AuthService.to.user?.name,
                    'ID': purchID,
                    'Account ID': _selectedAccountid.uid,
                    'Account Details': _selectedAccountid.toJson(),
                    'Amount': double.parse(_conpurpaid.text),
                  });
                  FirebaseFirestore.instance
                      .collection('Account')
                      .doc(_selectedAccountid.uid)
                      .update({
                    'Balance':
                        _selectedAccountid.bal - double.parse(_conpurpaid.text),
                  });
                  FirebaseFirestore.instance
                      .collection('Purchase')
                      .doc(purchID)
                      .set({
                    'Payment Method': _selectedpayment,
                    'Details': _conpurdetails.text,
                    'Invoice No': _conpurinvoiceid.text,
                    'Invoice Date': selectedDate,
                    'Account ID': _selectedAccountid.uid,
                    'Supplier': _selectedsupplier,
                    'Return':false,
                    'User': AuthService.to.user?.name,
                    'Supplier ID': _selectedsupplierid.id,
                    'VAT': double.parse(_conpurvat.text),
                    'Discount': double.parse(_conpurdiscount.text),
                    'Paid': double.parse(_conpurpaid.text),
                    'Grand Total': _grandtotal,
                    'Due': _dueamount,
                  }).then((valu) {
                    widget.nn.setnavbool();
                    widget.nn.purchase = true;
                    widget.nn.purchase_list = true;
                    Get.offNamed(purchaselistPageRoute);
                    Get.snackbar("Purchase Adding Successfully.",
                        "Redirecting to Purchase List Page",
                        snackPosition: SnackPosition.BOTTOM,
                        colorText: Colors.white,
                        backgroundColor: Colors.green,
                        margin: EdgeInsets.zero,
                        duration: const Duration(milliseconds: 2000),
                        boxShadows: [
                          BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                        ],
                        borderRadius: 0);
                  }).catchError((error) => print("Failed to add user: $error"));
                }
              }).catchError((error) => print("Failed to add user: $error"));
            } else {
              FirebaseFirestore.instance
                  .collection('Stock')
                  .doc(ps.productId.code)
                  .get()
                  .then((valss) {
                if (valss.exists) {
                  FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(ps.productId.code)
                      .update({
                    'Quantity': double.parse(ps.boxqtycontrollers.text) +
                        valss['Quantity'],
        //            'Expire Date': ps.expiredate,
                    'Body Rate': ps.productId.bodyrate,
                    'Supplier Price':
                        double.parse(ps.supplierpricecontrollers.text),
                    'Price': double.parse(ps.boxmrpcontrollers.text),
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('Stock')
                      .doc(ps.productId.code)
                      .set({
                    'Product Name': ps.selectedproduct,
                    'Product ID': ps.productId.id,
        //            'Expire Date': ps.expiredate,
                    'Body Rate': ps.productId.bodyrate,
                    'Quantity': double.parse(ps.boxqtycontrollers.text),
                    'Supplier Price':
                        double.parse(ps.supplierpricecontrollers.text),
                    'Price': double.parse(ps.boxmrpcontrollers.text),
                  });
                }
              });

              FirebaseFirestore.instance.collection('PurchaseItem').add({
                'Serial': ss + 1,
                'Product Name': ps.selectedproduct,
                'Product ID': ps.productId.id,
                'Code': ps.productId.code,
        //        'Expire Date': ps.expiredate,
                'Quantity': double.parse(ps.boxqtycontrollers.text),
                'Invoice No': _conpurinvoiceid.text,
                'Invoice Date': selectedDate,
                'Supplier Price':
                    double.parse(ps.supplierpricecontrollers.text),
                'Price': double.parse(ps.boxmrpcontrollers.text),
                'Total': double.parse(ps.totalPurpricecontroller.text)
              });
            }
          }
        }
      } else {
        setState(() {
          processing = false;
        });
        Get.snackbar("Purchase Adding Failed.",
            "Selected account doesn't have sufficient balance is Required",
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

  bool _first = false;
  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.purchase = true;
      widget.nn.purchase_add = true;
      controller.onChange(false);
      _first = true;
    }
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

    Future.delayed(Duration.zero, () async {
      apply();
    });

    void deleteItem(Purchase index) {
      if (_listitem.length > 1) {
        setState(() {
          _listitem.remove(index);
        });
      }
    }


    Future<void> _getStock(String id, int index) async {
      await FirebaseFirestore.instance
          .collection('Stock')
          .doc(id)
          .get()
          .then((element) {
            if(element.exists){
              setState(() {
                _listitem[index].stockquantity = element["Quantity"];
              });
            }
      });
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
            height: _height,
            width: _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: _height / 8),
              child: processing
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
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
                                    text: "Add Purchase",
                                    size: 32,
                                    weight: FontWeight.bold),
                                GestureDetector(
                                  onTap: () {
                                    Get.dialog(
                                      Dialog(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        child: BarcodeKeyboardListener(
                                          onBarcodeScanned: (barcode) {
                                            Product? matchingProduct =
                                                product.firstWhere(
                                              (product) =>
                                                  product.code == barcode,
                                            );
                                            if (matchingProduct != null) {
                                              setState(() {
                                                _listitem.insert(
                                                    0,
                                                    Purchase(
                                                        totalPurpricecontroller:
                                                            TextEditingController(
                                                                text: "0"),
                                                        stockquantity: 0.0,
                                                        productId:
                                                            matchingProduct,
                                                        boxmrpcontrollers:
                                                            TextEditingController(
                                                                text: matchingProduct
                                                                    .perprice
                                                                    .toString()),
                                                        boxqtycontrollers:
                                                            TextEditingController(
                                                                text: "0"),
                                         //               expiredate:
                                         //                   DateTime.now(),
                                                        supplierpricecontrollers:
                                                            TextEditingController(
                                                                text: matchingProduct
                                                                    .menuperprice
                                                                    .toString()),
                                                        selectedproduct:
                                                            matchingProduct
                                                                .name));
                                              });
                                              _getStock(
                                                  product[product.indexWhere(
                                                          (product) =>
                                                              product.code ==
                                                              barcode)]
                                                      .id,
                                                  0);
                                            } else {
                                              Get.snackbar(
                                                  "Barcode Scanning Failed",
                                                  "No Product Is available with this Code",
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  colorText: Colors.white,
                                                  backgroundColor: Colors.red,
                                                  margin: EdgeInsets.zero,
                                                  duration: const Duration(
                                                      milliseconds: 2000),
                                                  boxShadows: [
                                                    const BoxShadow(
                                                        color: Colors.grey,
                                                        offset: Offset(-100, 0),
                                                        blurRadius: 20),
                                                  ],
                                                  borderRadius: 0);
                                            }
                                          },
                                          useKeyDownEvent: true,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Scan The Product Code',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "opensans",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 26),
                                                ),
                                                const SizedBox(height: 20.0),
                                                ScanningAnimation(),
                                                const SizedBox(height: 20.0),
                                                InkWell(
                                                  onTap: () {
                                                    Get.back();
                                                  },
                                                  child: Container(
                                                      width: 120,
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .transparent,
                                                          border: Border.all(
                                                              color: Colors.red,
                                                              width: 5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Row(
                                                        children: [
                                                          const Icon(
                                                            Icons.cancel,
                                                            color: Colors.red,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          CustomText(
                                                            text: "Cancel",
                                                            color: Colors.red,
                                                            size: 18,
                                                            weight:
                                                                FontWeight.bold,
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // useKeyDownEvent: Platform.isWindows,
                                        ),
                                      ),
                                      barrierDismissible: false,
                                    );
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: buttonbg,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.qr_code_scanner_rounded,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          CustomText(
                                            text: "Scan Product",
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 30, left: 10, right: 10),
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
                                          _selectedsupplierid = manufact[
                                              smanufact.indexOf(newValue)];
                                          _selectedsupplier =
                                              newValue.toString();
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
                                          borderRadius:
                                              BorderRadius.circular(5),
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
                            margin:
                                EdgeInsets.only(top: 10, left: 10, right: 10),
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
                          Container(
                            margin:
                                EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: CustomText(
                                      text: "Select Payment",
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
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      hint: const Text('Select Payment'),
                                      value: _selectedpayment,
                                      onChanged: (newValue) {
                                        setState(() {
                                          if (newValue.toString() ==
                                              payment[0]) {
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
                                          _selectedpayment =
                                              newValue.toString();
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
                                selectedpm
                                    ? bankpayment
                                        ? Expanded(
                                            flex: 2,
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child: CustomText(
                                                text: "Bank Payment",
                                                size: 16,
                                              ),
                                            ),
                                          )
                                        : Expanded(
                                            flex: 2,
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              child: CustomText(
                                                text: "Cash Payment",
                                                size: 16,
                                              ),
                                            ),
                                          )
                                    : const SizedBox(),
                                selectedpm
                                    ? bankpayment
                                        ? Expanded(
                                            flex: 5,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 20),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey.shade200,
                                              ),
                                              child: DropdownButton(
                                                underline: const SizedBox(),
                                                isExpanded: true,
                                                hint: const Text(
                                                    'Select Bank Account'),
                                                value: _selectedaccount,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _selectedaccount =
                                                        newValue.toString();
                                                    _selectedAccountid =
                                                        _bankaccounts[sbankaccounts
                                                            .indexOf(newValue
                                                                .toString())];
                                                  });
                                                },
                                                items: _bankaccounts
                                                    .map((location) {
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
                                              margin: EdgeInsets.only(left: 20),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Colors.grey.shade200,
                                              ),
                                              child: DropdownButton(
                                                underline: const SizedBox(),
                                                isExpanded: true,
                                                hint: const Text(
                                                    'Select Cash Counter'),
                                                value: _selectedaccount,
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    _selectedaccount =
                                                        newValue.toString();
                                                    _selectedAccountid =
                                                        _cashaccounts[scashaccounts
                                                            .indexOf(newValue
                                                                .toString())];
                                                  });
                                                },
                                                items: _cashaccounts
                                                    .map((location) {
                                                  return DropdownMenuItem(
                                                    value: location.cashname,
                                                    child:
                                                        Text(location.cashname),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          )
                                    : const SizedBox(),
                                selectedpm
                                    ? const Expanded(
                                        flex: 3,
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
                                                  TextEditingController(
                                                      text: "0"),
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
                                                  TextEditingController(
                                                      text: "0"),
                                              boxqtycontrollers:
                                                  TextEditingController(
                                                      text: "0"),
                                   //           expiredate: DateTime.now(),
                                              supplierpricecontrollers:
                                                  TextEditingController(
                                                      text: "0"),
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
                                          borderRadius:
                                              BorderRadius.circular(100),
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
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
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
                            padding: EdgeInsets.only(
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
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
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
                            padding: EdgeInsets.only(
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
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
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
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide: BorderSide(
                                              color: Colors.transparent),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                          borderSide:
                                              BorderSide(color: Colors.blue),
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
                            padding: EdgeInsets.only(
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
                            padding: EdgeInsets.only(
                                top: 15, left: 10, right: 30, bottom: 30),
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
                                        backgroundColor:
                                            Colors.deepOrangeAccent,
                                        elevation: 20,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 15),
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
            )),
          ],
        )));
  }
}
