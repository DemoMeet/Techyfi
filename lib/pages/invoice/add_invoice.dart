import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_item.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../helpers/auth_service.dart';
import '../../model/Accounts.dart';
import '../../helpers/screen_size_controller.dart';
import '../../model/Single.dart';
import '../../model/Stock.dart';
import '../../model/invoice.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/scanning_progressbar.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AddInvoice extends StatefulWidget {
  
  
  Navbools nn;
  AddInvoice(
      { required this.nn});
  @override
  State<AddInvoice> createState() => _AddInvoiceState();
}

class _AddInvoiceState extends State<AddInvoice> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  double _subtotal = 0.0,
      _grandtotal = 0.0,
      _nettotal = 0.0,
      _previous = 0.0,
      _dueamount = 0.0;
  final _conpurinvoiceid = TextEditingController(),
      _conpurdetails = TextEditingController(),
      _conpurvat = TextEditingController(text: "0"),
      _conpurdiscount = TextEditingController(text: "0"),
      _conpurpaid = TextEditingController(text: "0");
  bool enabled = false;
  var custmr = [], payment = ["Bank Payment", "Cash Payment"];
  bool selectedpm = false, bankpayment = false, processing = true;
  List<String> scustmr = [], sproduct = [];
  List<Product> product = [];
  FirebaseStorage storage = FirebaseStorage.instance;
  var _selectedcustomer, _selectedpayment;
  List<Invoice> _listitem = [];
  var _selectedcustomerid;
  DateTime selectedDate = DateTime.now();
  List<Accounts> _cashaccounts = [];
  List<Accounts> _bankaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount;
  var _selectedAccountid;

  void _fetchDatas() async {
    product = [];
    sproduct = [];
    enabled = true;
    custmr.add(Single(name: "Walking Customer", id: "0000"));
    scustmr.add("Walking Customer");
    _selectedcustomer = "Walking Customer";
    _selectedcustomerid = custmr[0];
    await FirebaseFirestore.instance
        .collection('Stock')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        if (element["Quantity"] > 0) {
          await FirebaseFirestore.instance
              .collection('Products')
              .doc(element.id)
              .get()
              .then((ss) {
            setState(() {
              product.add(Product(
                name: ss["Product Name"],
                category: ss["Category Name"],
                brand: ss["Brand Name"],
                user: ss['User'],
                id: ss.id,
                code: ss['Code'],bodyrate: ss["Body Rate"],
                sl: 0,
                details: ss["Product Details"],
                menuperprice: ss['Purchase Price'],
                perprice: ss["Product Price"],
                strength: ss["Strength"],
                unit: ss["Unit Name"],
                img: ss["Image"],
                imgurl: ss["ImageURL"],
              ));
              sproduct.add(ss["Product Name"].toString());
            });
          });
        }
      });
    });

    await FirebaseFirestore.instance
        .collection('Customer')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        custmr.add(Single(name: element["Name"], id: element.id));
        scustmr.add(element["Name"].toString());
      });
    });
    await FirebaseFirestore.instance
        .collection('Invoice')
        .get()
        .then((querySnapshot) {
      int innum = 1;
      querySnapshot.docs.forEach((element) {
        innum++;
      });
      _conpurinvoiceid.text = innum.toString();
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
                user: element['User'],
                cashname: element["Cash Name"],
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
    processing =false;
    setState(() {});
  }

  @override
  void initState() {
    _fetchDatas();
    _listitem.add(Invoice(
        total: TextEditingController(text: "0"),
        selectedtype: "Per Box",
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
        quantitycontrollers: TextEditingController(text: "0"),
        pricecontrollers: TextEditingController(text: "0"),
        discountcontrollers: TextEditingController(text: "0"),
     //   expiredate: DateTime.now(),
        availqty: 0.0,
        stock: Stock(
            serial: 0,
            manuPrice: 0,
            price: 0,
            productqty: 0,
            productName: "",
            productId: "",
         //   expireDate: DateTime.now(),
            total: 0),
        selectedproduct: ""));
    super.initState();
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
      widget.nn.invoice = true;
      widget.nn.invoice_add = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _adddatase() {
    _subtotal = 0.0;
    _grandtotal = 0.0;
    _nettotal = 0.0;
    _dueamount = 0.0;
    setState(() {
      for (var i = 0; i < _listitem.length; i++) {
        _subtotal = _subtotal + double.parse(_listitem[i].total.text);
      }
      _grandtotal = double.parse(_conpurvat.text) -
          double.parse(_conpurdiscount.text) +
          _subtotal;
      _nettotal = _grandtotal + _previous;
      _dueamount = _nettotal - double.parse(_conpurpaid.text);
    });
  }

  void fullpaid() {
    setState(() {
      _conpurpaid.text = _nettotal.toString();
      _dueamount = 0.0;
    });
  }

  Future<void> _savedatate() async {
    setState(() {
      processing = true;
    });
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    bool hasEmptyField = false;
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String invoiceID = getRandomString(20);
    if (_conpurinvoiceid.text.isEmpty ||
        _selectedpayment.toString().isEmpty ||
        _conpurpaid.text.isEmpty ||
        _selectedpayment.toString() == "null" ||
        _selectedAccountid.toString() == "null") {
      setState(() {
        processing = false;
      });
      Get.snackbar("Sales Adding Failed.",
          "Invoice ID, Account and Payment Method is Required",
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
      _listitem.forEach((ps) {
        if (ps.selectedproduct.isEmpty ||
            double.parse(ps.quantitycontrollers.text) <= 0) {
          hasEmptyField = true;
        }
      });
      if (hasEmptyField) {
        setState(() {
          processing = false;
        });
        Get.snackbar("Sales Adding Failed.",
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
      } else if (custmr[0] == _selectedcustomer && _dueamount != 0) {
       setState(() {
          processing = false;
        });
        Get.snackbar("Sales Adding Failed.",
            "Walking Customer Has to Pay Full Amount!!",
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
          Invoice ps = _listitem[ss];
          if (ss == _listitem.length - 1) {
            FirebaseFirestore.instance
                .collection('Stock')
                .doc(ps.productId.code)
                .update({
              'Quantity': ps.stock.productqty -
                  double.parse(ps.quantitycontrollers.text),
            });
            FirebaseFirestore.instance.collection('InvoiceItem').add({
              'Serial': ss + 1,
              'Product Name': ps.selectedproduct,
              'Product ID': ps.productId.id,
            //  'Expire Date': ps.stock.expireDate,
              "Body Rate": ps.productId.bodyrate,
              'Quantity': double.parse(ps.quantitycontrollers.text),
              'Invoice No': _conpurinvoiceid.text,
              'Invoice Date': selectedDate,
              'Price': double.parse(ps.pricecontrollers.text),
              'Discount': double.parse(ps.discountcontrollers.text),
              'Total': double.parse(ps.total.text)
            }).then((valu) {
              if (custmr[0] == _selectedcustomer || _dueamount == 0) {
                FirebaseFirestore.instance.collection('Transaction').add({
                  'Name': _selectedcustomer,
                  '2nd ID': _selectedcustomerid.id,
                  'Remarks': "Invoice",
                  'Type': 'Credit',
                  'Submit Date': DateTime.now(),
                  'Date': selectedDate,
                  'User': AuthService.to.user?.name,
                  'Payment Method': _selectedpayment,
                  'ID': invoiceID,
                  'Account ID': _selectedAccountid.uid,
                  'Account Details': _selectedAccountid.toJson(),
                  'Amount': double.parse(_conpurpaid.text),
                });
                FirebaseFirestore.instance
                    .collection('Account')
                    .doc(_selectedAccountid.uid)
                    .update({
                  'Balance':
                      _selectedAccountid.bal + double.parse(_conpurpaid.text),
                });
                FirebaseFirestore.instance
                    .collection('Invoice')
                    .doc(invoiceID)
                    .set({
                  'Payment Method': _selectedpayment,
                  'Details': _conpurdetails.text,
                  'Invoice No': _conpurinvoiceid.text,
                  'Invoice Date': selectedDate,
                  'Customer': _selectedcustomer,
                  'Customer ID': _selectedcustomerid.id,
                  'Account ID': _selectedAccountid.uid,
                  'VAT': double.parse(_conpurvat.text),
                  'User': AuthService.to.user?.name,
                  'Discount': double.parse(_conpurdiscount.text),
                  'Paid': double.parse(_conpurpaid.text),
                  'Grand Total': _grandtotal,
                  'Return':false,
                  'Net Total': _nettotal,
                  'Due': _dueamount,
                }).then((valu) {
                  widget.nn.setnavbool();
                  widget.nn.invoice = true;
                  widget.nn.invoice_list = true;
                  Get.offNamed(invoicelistPageRoute);
                  Get.snackbar("Sales Adding Successfully.",
                      "Redirecting to Invoice List Page",
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
              } else {
                FirebaseFirestore.instance
                    .collection('Customer')
                    .doc(_selectedcustomerid.id)
                    .get()
                    .then((element) {
                  FirebaseFirestore.instance
                      .collection('Customer')
                      .doc(_selectedcustomerid.id)
                      .update({
                    'Balance': _dueamount,
                  }).then((value) {
                    FirebaseFirestore.instance.collection('Transaction').add({
                      'Name': _selectedcustomer,
                      '2nd ID': _selectedcustomerid.id,
                      'Remarks': "Invoice",
                      'Submit Date': DateTime.now(),
                      'Type': 'Credit',
                      'Date': selectedDate,
                      'Payment Method': _selectedpayment,
                      'ID': invoiceID,
                      'Account ID': _selectedAccountid.uid,
                      'Account Details': _selectedAccountid.toJson(),
                      'Amount': double.parse(_conpurpaid.text),
                    });
                    FirebaseFirestore.instance
                        .collection('Account')
                        .doc(_selectedAccountid.uid)
                        .update({
                      'Balance': _selectedAccountid.bal +
                          double.parse(_conpurpaid.text),
                    });
                    FirebaseFirestore.instance
                        .collection('Invoice')
                        .doc(invoiceID)
                        .set({
                      'Payment Method': _selectedpayment,
                      'Details': _conpurdetails.text,
                      'Invoice No': _conpurinvoiceid.text,
                      'Invoice Date': selectedDate,
                      'Customer': _selectedcustomer,
                      'Account ID': _selectedAccountid.uid,
                      'User': AuthService.to.user?.name,
                      'Customer ID': _selectedcustomerid.id,
                      'Return':false,
                      'VAT': double.parse(_conpurvat.text),
                      'Discount': double.parse(_conpurdiscount.text),
                      'Paid': double.parse(_conpurpaid.text),
                      'Grand Total': _grandtotal,
                      'Net Total': _nettotal,
                      'Due': _dueamount,
                    }).then((valu) {
                      widget.nn.setnavbool();
                      widget.nn.invoice = true;
                      widget.nn.invoice_list = true;
                      Get.offNamed(invoicelistPageRoute);
                      Get.snackbar("Sales Adding Successfully.",
                          "Redirecting to Invoice List Page",
                          snackPosition: SnackPosition.BOTTOM,
                          colorText: Colors.white,
                          backgroundColor: Colors.green,
                          margin: EdgeInsets.zero,
                          duration: const Duration(milliseconds: 2000),
                          boxShadows: [
                            BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                          ],
                          borderRadius: 0);
                    });
                  });
                });
              }
            }).catchError((error) => print("Failed to add user: $error"));
          } else {
            FirebaseFirestore.instance
                .collection('Stock')
                .doc(ps.productId.code)
                .update({
              'Quantity': ps.stock.productqty -
                  double.parse(ps.quantitycontrollers.text),
            });
            FirebaseFirestore.instance.collection('InvoiceItem').add({
              'Serial': ss + 1,
              'Product Name': ps.selectedproduct,
              'Product ID': ps.productId.id,
            //  'Expire Date': ps.stock.expireDate,
              "Body Rate": ps.productId.bodyrate,
              'Quantity': double.parse(ps.quantitycontrollers.text),
              'Invoice No': _conpurinvoiceid.text,
              'Invoice Date': selectedDate,
              'Price': double.parse(ps.pricecontrollers.text),
              'Discount': double.parse(ps.discountcontrollers.text),
              'Total': double.parse(ps.total.text)
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    void deleteItem(Invoice index) {
      if (_listitem.length > 1) {
        setState(() {
          _listitem.remove(index);
        });
      }
    }

    Future<void> _setcustpay() async {
      await FirebaseFirestore.instance
          .collection('Customer')
          .doc(_selectedcustomerid.id)
          .get()
          .then((element) {
        _previous = element["Balance"];
        setState(() {});
      });
      _adddatase();
    }

 

    Future<void> _getStock(int index) async {
      await FirebaseFirestore.instance
          .collection('Stock')
          .doc(product[index].id)
          .get()
          .then((element) {
        setState(() {
          _listitem[0].stock = Stock(
              productId: element["Product ID"],
              productName: element["Product Name"],
          //    expireDate: element["Expire Date"].toDate(),
              price: element["Price"],
              manuPrice: element["Supplier Price"],
              productqty: element["Quantity"],
              serial: 0,
              total: 0);
        });
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
                : SideMenuSmall(widget.nn, ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: _height / 8),
              child: processing?const Center(child: CircularProgressIndicator(),):SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 30, right: 120),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                                text: "Add Invoice",
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
                                          (product) => product.code == barcode,
                                        );
                                        if (matchingProduct != null) {
                                          print(
                                              "Product found: ${matchingProduct.name}");

                                          setState(() {
                                            _listitem.insert(
                                                0,
                                                Invoice(
                                                    total: TextEditingController(text: "0"),
                                                    selectedtype: "Per Box",
                                                    productId: matchingProduct,
                                                    quantitycontrollers:
                                                        TextEditingController(
                                                            text: "0"),
                                                    pricecontrollers:
                                                        TextEditingController(
                                                            text: matchingProduct
                                                                .perprice
                                                                .toString()),
                                                    discountcontrollers:
                                                        TextEditingController(
                                                            text: "0"),
                           //                         expiredate: DateTime.now(),
                                                    availqty: 0.0,
                                                    stock: Stock(
                                                        serial: 0,
                                                        manuPrice: 0,
                                                        price: 0,
                                                        productqty: 0,
                                                        productName: "",
                                                        productId: "",
                              //                          expireDate:
                               //                             DateTime.now(),
                                                        total: 0),
                                                    selectedproduct:
                                                        matchingProduct.name));
                                          });
                                          _getStock(product.indexWhere(
                                              (product) =>
                                                  product.code == barcode));
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
                                                  fontWeight: FontWeight.bold,
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
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.transparent,
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 5),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
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
                                                        weight: FontWeight.bold,
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
                                      borderRadius: BorderRadius.circular(5)),
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
                        margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Customer",
                                  size: 16,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                  margin: EdgeInsets.only(left: 20),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: DropdownSearch<String>(
                                    popupProps: PopupProps.menu(
                                      showSearchBox: true,
                                      itemBuilder: (BuildContext context,
                                              dynamic item, bool isSelected) =>
                                          Container(
                                        padding: EdgeInsets.all(15),
                                        child: Text(
                                          item,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      fit: FlexFit.loose,
                                      showSelectedItems: false,
                                      menuProps: MenuProps(
                                        backgroundColor: Colors.white,
                                        elevation: 100,
                                      ),
                                      searchFieldProps: TextFieldProps(
                                        style: TextStyle(fontSize: 16),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: "Search...",
                                        ),
                                      ),
                                    ),
                                    dropdownDecoratorProps:
                                        const DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    dropdownBuilder: (context, selectedItem) {
                                      return Text(
                                        selectedItem ?? "sss",
                                        style: TextStyle(fontSize: 16),
                                      );
                                    },
                                    onChanged: (Value) {
                                      setState(() {
                                        _selectedcustomer = Value.toString();
                                        if (Value != "Walking Customer") {
                                          _selectedcustomerid =
                                              custmr[scustmr.indexOf(Value!)];
                                          _setcustpay();
                                        }
                                      });
                                    },
                                    items: scustmr,
                                    selectedItem: custmr[0].name,
                                  )),
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Date",
                                  size: 16,
                                ),
                              ),
                              flex: 2,
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
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
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 1,
                              ),
                              flex: 3,
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
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Invoice No",
                                  size: 16,
                                ),
                              ),
                              flex: 3,
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
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
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
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Details",
                                  size: 16,
                                ),
                              ),
                              flex: 2,
                            ),
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: TextFormField(
                                  controller: _conpurdetails,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
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
                              child: SizedBox(
                                height: 1,
                              ),
                              flex: 3,
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
                                  onChanged: (Value) {
                                    setState(() {
                                      if (Value.toString() == payment[0]) {
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
                                      _selectedpayment = Value.toString();
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
                                                'Select Bank Account'),
                                            value: _selectedaccount,
                                            onChanged: (Value) {
                                              setState(() {
                                                _selectedaccount =
                                                    Value.toString();
                                                _selectedAccountid =
                                                    _bankaccounts[
                                                        sbankaccounts.indexOf(
                                                            Value.toString())];
                                              });
                                            },
                                            items:
                                                _bankaccounts.map((location) {
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
                                                'Select Cash Counter'),
                                            value: _selectedaccount,
                                            onChanged: (Value) {
                                              setState(() {
                                                _selectedaccount =
                                                    Value.toString();
                                                _selectedAccountid =
                                                    _cashaccounts[
                                                        scashaccounts.indexOf(
                                                            Value.toString())];
                                              });
                                            },
                                            items:
                                                _cashaccounts.map((location) {
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
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 15, bottom: 15),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
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
                              flex: 10,
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
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
                              flex: 4,
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
                              flex: 3,
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
                            //   flex: 5,
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
                              flex: 4,
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
                                margin: EdgeInsets.only(left: 5),
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
                              flex: 6,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Price",
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
                                margin: EdgeInsets.only(left: 7),
                                child: Text(
                                  "Discount %",
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
                                  "Total",
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
                            return InvoiceItem(
                              product: product,
                              enabled: enabled,
                              listitem: _listitem[index],
                              deleteItem: deleteItem,
                              adddatase: _adddatase,
                            );
                          },
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
                              flex: 63,
                            ),
                            Text("   "),
                            Expanded(
                              flex: 10,
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
                              flex: 5,
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(5),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _listitem.add(Invoice(
                                          total:  TextEditingController(text: "0"),
                                          selectedtype: "Per Box",
                                          productId: Product(
                                            name: '',
                                            category: '',
                                            brand: '',
                                            user: '',bodyrate: 0,
                                            id: '',
                                            code: '',
                                            sl: 0,
                                            details: '',
                                            menuperprice: 0,
                                            perprice: 0,
                                            strength: '',
                                            unit: '',
                                            img: false,
                                            imgurl: '',
                                          ),
                                          quantitycontrollers:
                                              TextEditingController(text: "0"),
                                          pricecontrollers:
                                              TextEditingController(text: "0"),
                                          discountcontrollers:
                                              TextEditingController(text: "0"),
                                  //        expiredate: DateTime.now(),
                                          availqty: 0.0,
                                          stock: Stock(
                                              serial: 0,
                                              manuPrice: 0,
                                              price: 0,
                                              productqty: 0,
                                              productName: "",
                                              productId: "",
                                  //            expireDate: DateTime.now(),
                                              total: 0),
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
                                    child: Icon(Icons.add,
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
                              flex: 61,
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
                            Text("   "),
                            Expanded(
                              flex: 10,
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
                                  decoration: InputDecoration(
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    hintText: "0.00",
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
                              flex: 5,
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
                              flex: 61,
                            ),
                            Text("   "),
                            Expanded(
                              flex: 10,
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
                                  decoration: InputDecoration(
                                    isDense: true,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    hintText: "0.00",
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: SizedBox(
                                height: 1,
                              ),
                              flex: 5,
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
                              flex: 63,
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
                              flex: 10,
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
                                    text: _grandtotal.toString(),
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
                              flex: 5,
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
                              flex: 63,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Previous",
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
                              flex: 10,
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
                                    text: _previous.toString(),
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
                              flex: 5,
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
                              flex: 63,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Net Total",
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
                              flex: 10,
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
                                    text: _nettotal.toString(),
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                            Text(" "),
                            const Expanded(
                              child: SizedBox(
                                height: 1,
                              ),
                              flex: 5,
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
                              flex: 61,
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
                              flex: 10,
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      borderSide:
                                          BorderSide(color: Colors.blue),
                                    ),
                                    hintText: "0.00",
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
                              flex: 5,
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
                              flex: 63,
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
                              flex: 10,
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
                            const Expanded(
                              child: SizedBox(
                                height: 1,
                              ),
                              flex: 5,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.grey,
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 2),
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
                            const Expanded(
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
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _savedatate();
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
                            const Expanded(
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
