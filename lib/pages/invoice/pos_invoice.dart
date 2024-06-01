import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/model/Single.dart';
import 'package:groceyfi02/pages/invoice/widget/ManufactList_POS.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_product_Grid.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_product_POS.dart';
import 'package:groceyfi02/pages/invoice/widget/topSection_POS.dart';

import 'package:get/get.dart';
import '../../model/Accounts.dart';
import '../../model/POSItem.dart';
import '../../helpers/screen_size_controller.dart';
import '../../model/Stock.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class PosInvoice extends StatefulWidget {
  Navbools nn;
  PosInvoice({required this.nn});
  @override
  State<PosInvoice> createState() => _PosInvoiceState();
}

class _PosInvoiceState extends State<PosInvoice> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  TextEditingController search_customer = TextEditingController();
  bool _first = false, _loading = true;
  bool selectedpm = false, bankpayment = false;
  late String _selectedcustomer;
  late Single _selectedcustomerid;
  var custmr = [];
  List<String> scustmr = [];
  List<Product> allProducts = [], searchproduct = [], foundProducts = [];
  List<Stock> stocks = [];
  late POSItem pOSItem;
  List<POSItem> positems = [];
  List<Single> manufact = [];
  int innum = 1;
  List<Accounts> _cashaccounts = [];
  List<Accounts> _bankaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount;
  var _selectedAccountid;

  double width = 1200,
      _subtotal = 0.0,
      _grandtotal = 0.0,
      _nettotal = 0.0,
      _previous = 0.0,
      _dueamount = 0.0;

  final _conpurvat = TextEditingController(text: "0.0"),
      _conpurdiscount = TextEditingController(text: "0.0"),
      _conpurpaid = TextEditingController(text: "0.0");

  void _adddatase() {
    _subtotal = 0.0;
    _grandtotal = 0.0;
    _nettotal = 0.0;
    _dueamount = 0.0;
    setState(() {
      for (var i = 0; i < positems.length; i++) {
        _subtotal = _subtotal + positems[i].total;
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

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.invoice = true;
      widget.nn.invoice_pos = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    setState(() {
      custmr = [];
      scustmr = [];
      selectedpm = false; bankpayment = false;
      _loading = true;
      custmr.add(Single(name: "Walking Customer", id: "0000"));
      scustmr.add("Walking Customer");
      _selectedcustomer = "Walking Customer";
      _selectedcustomerid = Single(name: "Walking Customer", id: "0000");
    });
    allProducts = [];
    searchproduct = [];
    foundProducts = [];
    stocks = [];
    positems = [];
    manufact = [];
    innum = 1;
    _cashaccounts = [];
    _bankaccounts = [];
    sbankaccounts = [];
    scashaccounts = [];
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allProducts.add(Product(
          name: element["Product Name"],
          category: element["Category Name"],
          brand: element["Brand Name"],
          user: element['User'],
          id: element.id,
          code: element['Code'],bodyrate: element["Body Rate"],
          sl: 0,
          details: element["Product Details"],
          menuperprice: element['Purchase Price'],
          perprice: element["Product Price"],
          strength: element["Strength"],
          unit: element["Unit Name"],
          img: element["Image"],
          imgurl: element["ImageURL"],
        ));
        s++;
      });
    }).catchError((error) {
      print(error);
    });
    foundProducts = allProducts;
    searchproduct = foundProducts;
    manufact.add(Single.withSelected(
        name: "ALL", id: "0", details: "0", selected: true));
    await FirebaseFirestore.instance
        .collection('Category')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        manufact.add(Single.withSelected(
            name: element["Name"],
            id: element.id,
            details: "Supplier",
            selected: false));
      });
    });
    await FirebaseFirestore.instance
        .collection('Customer')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        custmr.add(Single(name: element["Name"], id: element.id));
        scustmr.add(element["Name"].toString());
        setState(() {});
      });
    });
    await FirebaseFirestore.instance
        .collection('Invoice')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        innum++;
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
          _loading = false;
        });
      });
      _adddatase();
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<Product> results = [];
    if (enteredKeyword.isEmpty) {
      results = foundProducts;
    } else {
      results = foundProducts
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      searchproduct = results;
    });
  }

  void _runManuFact(String enteredKeyword) {
    List<Product> results = [];
    if (enteredKeyword.isEmpty) {
      results = allProducts;
    } else {
      results = allProducts
          .where((user) => user.category
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundProducts = results;
      searchproduct = foundProducts;
      search_customer = TextEditingController();
    });
  }

  void setManufact(int index) {
    if (index == 0) {
      searchproduct = allProducts;
      setState(() {});
    } else {
      _runManuFact(manufact[index].name);
    }
    manufact.forEach((f) => f.selected = false);
    manufact.insert(
        index,
        Single.withSelected(
            name: manufact[index].name,
            id: manufact[index].id,
            details: "Supplier",
            selected: true));
    setState(() {});
    manufact.remove(manufact[index + 1]);
  }

  void removeproductfrominvoice(POSItem sss) {
    setState(() {
      positems.remove(sss);
    });
  }

  Future<void> addProductToInvoice(int index) async {
    String productId = searchproduct[index].id;

    Stock stocks = Stock(
        productId: "",
        productName: "",
        //expireDate: DateTime.now(),
        price: 0,
        manuPrice: 0,
        productqty: 0,
        serial: 0,
        total: 0);
    double totalstock = 0.0;
    await FirebaseFirestore.instance
        .collection('Stock')
        .doc(productId)
        .get()
        .then((element) {
      if (element.exists) {
        totalstock = element["Quantity"];
        stocks = Stock(
        //  expireDate: element["Expire Date"].toDate(),
          manuPrice: element["Supplier Price"],
          productId: element["Product ID"],
          productName: element["Product Name"],
          productqty: element["Quantity"],
          price: element["Price"],
          serial: 0,
          total: 0,
        );
      }
    });

    int existingIndex =
        positems.indexWhere((item) => item.product.id == productId);

    if (existingIndex != -1) {
      int currentQuantity = int.parse(positems[existingIndex].quantity.text);
      if (currentQuantity + 1 <= totalstock) {
        positems[existingIndex].quantity.text =
            (currentQuantity + 1).toString();
        positems[existingIndex].total =
            (currentQuantity + 1) * positems[existingIndex].product.perprice;
      }
    } else {
      if (totalstock == 0) {
        positems.add(POSItem(
          product: searchproduct[index],
          quantity: TextEditingController(text: "0"),
          totalstock: totalstock,
          selectedStock: stocks!,
          total: searchproduct[index].perprice * 0,
        ));
      } else {
        positems.add(POSItem(
          product: searchproduct[index],
          quantity: TextEditingController(text: "1"),
          totalstock: totalstock,
          selectedStock: stocks!,
          total: searchproduct[index].perprice * 1,
        ));
      }
    }
    _adddatase();
  }

  Future<List<Product>> getProduct() async {
    return searchproduct;
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    int items = 4;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    Future<void> _setcustpay(String id, String name) async {
      if (id != "0000") {
        setState(() {
          _selectedcustomer = name;
          _selectedcustomerid = custmr[scustmr.indexOf(name)];
        });
        await FirebaseFirestore.instance
            .collection('Customer')
            .doc(id)
            .get()
            .then((element) {
          setState(() {
            _previous = element["Balance"];
          });
        }).catchError((error) {
          print(error);
        });
      }
      _adddatase();
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          height: _height,
          width: _width,
        ),
        body: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.screenSize.value
                    ? SideMenuBig(widget.nn)
                    : SideMenuSmall(
                        widget.nn,
                      ),
                Expanded(
                    child: _loading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : MeasuredSize(
                            onChange: (Size size) {
                              setState(() {
                                width = size.width;
                                if (_width > 1290) {
                                  items = 4;
                                } else {
                                  items = 3;
                                }
                              });
                            },
                            child: BarcodeKeyboardListener(
                              onBarcodeScanned: (barcode) {
                                Product? matchingProduct =
                                    searchproduct.firstWhere(
                                  (product) => product.code == barcode,
                                );
                                if (matchingProduct != null) {
                                  int indexOfMatchingProduct =
                                      searchproduct.indexOf(matchingProduct);
                                  addProductToInvoice(indexOfMatchingProduct);
                                } else {
                                  Get.snackbar("Barcode Scanning Failed",
                                      "No Product Is available with this Code",
                                      snackPosition: SnackPosition.BOTTOM,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                      margin: EdgeInsets.zero,
                                      duration:
                                          const Duration(milliseconds: 2000),
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
                              child: Container(
                                margin: EdgeInsets.only(top: _height / 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    POSTopSection(
                                        width: _width,
                                        runFilter: _runFilter,
                                        custmr: custmr,
                                        scustmr: scustmr,
                                        setcustpay: _setcustpay,
                                        selectedcustomerid: _selectedcustomerid,
                                        selectedcustomer: _selectedcustomer,
                                        search_customer: search_customer),
                                    POSSupplierList(
                                      setManuFact: setManufact,
                                      manufact: manufact,
                                      height: _height,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 10,
                                          top: 5,
                                        ),
                                        child: width > 670
                                            ? Row(
                                                children: [
                                                  InvoiceProductGrid(
                                                      column: false,
                                                      getProduct: getProduct,
                                                      width: _width,
                                                      height: _height,
                                                      addproducttoinvoice:
                                                          addProductToInvoice,
                                                      wit: width),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  InvoiceProductPOS(
                                                    column: false,
                                                    positems: positems,
                                                    removeproductfrominvoice:
                                                        removeproductfrominvoice,
                                                    adddatase: _adddatase,bankpayment: bankpayment,selectedpm: selectedpm,
                                                    conpurdiscount:
                                                        _conpurdiscount,
                                                    fetchDocuments:
                                                        _fetchDocuments,
                                                    conpurpaid: _conpurpaid,
                                                    conpurvat: _conpurvat,
                                                    dueamount: _dueamount,
                                                    grandtotal: _grandtotal,
                                                    innum: innum,
                                                    nn: widget.nn,
                                                    selectedcustomer:
                                                        _selectedcustomer,
                                                    custmr: custmr,
                                                    selectedcustomerid:
                                                        _selectedcustomerid,
                                                    nettotal: _nettotal,
                                                    previous: _previous,
                                                    subtotal: _subtotal,
                                                    fullpaid: fullpaid,
                                                    bankaccounts: _bankaccounts,
                                                    cashaccounts: _cashaccounts,
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  InvoiceProductGrid(
                                                      column: true,
                                                      width: _width,
                                                      getProduct: getProduct,
                                                      height: _height,
                                                      addproducttoinvoice:
                                                          addProductToInvoice,
                                                      wit: width),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  InvoiceProductPOS(
                                                      column: true,
                                                      positems: positems,
                                                      adddatase: _adddatase,
                                                      conpurdiscount:
                                                          _conpurdiscount,
                                                      conpurpaid: _conpurpaid,
                                                      conpurvat: _conpurvat,
                                                      dueamount: _dueamount,bankpayment: bankpayment,selectedpm: selectedpm,
                                                      fetchDocuments:
                                                          _fetchDocuments,
                                                      grandtotal: _grandtotal,
                                                      nn: widget.nn,
                                                      innum: innum,
                                                      selectedcustomer:
                                                          _selectedcustomer,
                                                      custmr: custmr,
                                                      selectedcustomerid:
                                                          _selectedcustomerid,
                                                      nettotal: _nettotal,
                                                      previous: _previous,
                                                      subtotal: _subtotal,
                                                      fullpaid: fullpaid,
                                                      removeproductfrominvoice:
                                                          removeproductfrominvoice,
                                                      bankaccounts:
                                                          _bankaccounts,
                                                      cashaccounts:
                                                          _cashaccounts),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
              ],
            )));
  }
}
