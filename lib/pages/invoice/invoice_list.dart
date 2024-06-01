import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../api/csv_invoice.dart';
import '../../api/pdf_invoicelist.dart';
import '../../api/pdf_invoiceA4PDF.dart';
import '../../api/pdf_invoicePOS.dart';
import '../../constants/style.dart';
import '../../model/Stock.dart';
import '../../model/customer.dart';
import '../../model/invoiceListModel.dart';
import '../../model/nav_bools.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../widgets/custom_text.dart';
import 'edit_invoice.dart';
import 'invoice_details.dart';
import 'invoice_detailsPOS.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class InvoiceList extends StatefulWidget {
  Navbools nn;
  InvoiceList({required this.nn});

  @override
  State<InvoiceList> createState() => _InvoiceListState();
}

class _InvoiceListState extends State<InvoiceList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  late FocusNode myFocusNode;
  String dropdownvalue = 'Search By Invoice No';
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false,
      _totaltop = false,
      _totalbot = false,
      _datebot = false,
      _datetop = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  double _totalamount = 0, _totalprofit = 0;
  List<bool> _click = [];
  List<InvoiceListModel> allInvoiceLists = [];
  List<InvoiceListModel> foundInvoiceLists = [];
  TextEditingController search_Invoice = TextEditingController();
  DateTime startDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime endDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.invoice = true;
      widget.nn.invoice_list = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    _click = [];
    allInvoiceLists = [];
    foundInvoiceLists = [];
    int s = 0;
    try {
      var invoiceQuery =
          await FirebaseFirestore.instance.collection('Invoice').get();

      await Future.wait(invoiceQuery.docs.map((invoiceDoc) async {
        double profits = 0;

        var invoiceItemQuery = await FirebaseFirestore.instance
            .collection('InvoiceItem')
            .where("Invoice No", isEqualTo: invoiceDoc["Invoice No"])
            .get();

        await Future.wait(invoiceItemQuery.docs.map((invoiceItemDoc) async {
          var stockDoc = await FirebaseFirestore.instance
              .collection('Stock')
              .doc(invoiceItemDoc["Product ID"])
              .get();

          profits += ((invoiceItemDoc["Price"] - stockDoc["Supplier Price"]) *
              invoiceItemDoc["Quantity"]);
        }));

        allInvoiceLists.add(InvoiceListModel(
          discount: invoiceDoc["Discount"],
          total: invoiceDoc["Grand Total"],
          due: invoiceDoc["Due"],
          accountID: invoiceDoc["Account ID"],
          retn: invoiceDoc["Return"],
          paid: invoiceDoc["Paid"],
          invoiceNo: invoiceDoc["Invoice No"],
          profit: profits,
          user: invoiceDoc['User'],
          customerID: invoiceDoc["Customer ID"],
          customerName: invoiceDoc["Customer"],
          invoiceDate: invoiceDoc["Invoice Date"].toDate(),
          invoiceID: invoiceDoc.id,
          sl: s,
        ));
        s++;
      }));
    } catch (error) {
      print("Failed to fetch data: $error");
    }
    foundInvoiceLists = allInvoiceLists;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundInvoiceLists.length; i += _items) {
      chunks.add(foundInvoiceLists.sublist(
          i,
          i + _items > foundInvoiceLists.length
              ? foundInvoiceLists.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundInvoiceLists.length / _items).floor() + 1;
    });
  }

  void _refreshdata() {
    _click = [];
    allInvoiceLists = [];
    foundInvoiceLists = [];
    _fetchDocuments();
  }

  Future<void> _onInvoiceDetails(InvoiceListModel cst) async {
    Customer mn;
    if (cst.customerID == "0000") {
      mn = Customer(
          name: "Walking Customer",
          address: "",
          email: "",
          phone1: "",
          phone2: "",
          user: '',
          city: "",
          balance: 0,
          id: "",
          zip: "",
          sl: 0);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InvoiceDetails(cst, _refreshdata, mn),
        ),
      );
    } else {
      await FirebaseFirestore.instance
          .collection('Customer')
          .doc(cst.customerID)
          .get()
          .then((element) {
        mn = Customer(
            name: element["Name"],
            address: element["Address"],
            email: element["Email"],
            phone1: element["Phone"],
            phone2: element["Phone2"],
            city: element["City"],
            balance: element["Balance"],
            id: element.id,
            user: element["User"],
            zip: element["Zip Code"],
            sl: 0);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => InvoiceDetails(cst, _refreshdata, mn),
          ),
        );
      });
    }
  }

  Future<void> _onInvoiceDetailsPOS(InvoiceListModel cst) async {
    String invoiceid = cst.invoiceID;
    InvoiceListModel? invs;
    String invnum = '';
    double save = 0;
    Customer mn = Customer(
        name: "Walking Customer",
        address: "",
        email: "",
        phone1: "",
        phone2: "",
        user: '',
        city: "",
        balance: 0,
        id: "",
        zip: "",
        sl: 0);
    if (cst.customerID == "0000") {
    } else {
      await FirebaseFirestore.instance
          .collection('Customer')
          .doc(cst.customerID)
          .get()
          .then((element) {
        mn = Customer(
            name: element["Name"],
            address: element["Address"],
            email: element["Email"],
            phone1: element["Phone"],
            phone2: element["Phone2"],
            city: element["City"],
            balance: element["Balance"],
            id: element.id,
            user: element["User"],
            zip: element["Zip Code"],
            sl: 0);
      });
    }
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
        paid: element["Paid"],
        retn: element["Return"],
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

    await PdfInvoiceA4PDF.generate(invs!, InvoiceList, mn, save);
  }

  void _onEditInvoice(InvoiceListModel cst) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditInvoice(cst, _refreshdata),
      ),
    );
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    myFocusNode = FocusNode();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<InvoiceListModel> results = [];
    if (enteredKeyword.isEmpty) {
      results = allInvoiceLists;
    } else {
      results = allInvoiceLists
          .where((user) => user.invoiceNo
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundInvoiceLists = results;
    });
    makechunks();
  }

  void _findData() {
    if (startDate.compareTo(endDate) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Invalid Date! Start Date Has to Be Greater Then End Date."),
      ));
    } else {
      List<InvoiceListModel> results = [];
      for (int i = 0; i < allInvoiceLists.length; i++) {
        if ((allInvoiceLists[i].invoiceDate.compareTo(startDate) >= 0 &&
                allInvoiceLists[i].invoiceDate.compareTo(endDate) <= 0) ||
            (allInvoiceLists[i].invoiceDate.difference(startDate).inDays == 1 ||
                allInvoiceLists[i].invoiceDate.difference(endDate).inDays ==
                    1)) {
          results.add(allInvoiceLists[i]);
        } else if (startDate.difference(endDate).inDays == 0) {
          if (allInvoiceLists[i].invoiceDate.compareTo(startDate) == 1) {
            results.add(allInvoiceLists[i]);
          }
        }
      }
      foundInvoiceLists = [];
      setState(() {
        foundInvoiceLists = results;
      });
      makechunks();
    }
  }

  _selectstartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
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
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  _selectendDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
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
    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    void changeVal(String i) {
      setState(() {
        _click[val] = false;
        _click[int.parse(i)] = true;
        val = int.parse(i);
      });
    }

    Future<List<InvoiceListModel>> getCust() async {
      List<InvoiceListModel> InvoiceLists = [];
      _totalamount = 0;
      _totalprofit = 0;
      if (chunks.isNotEmpty) {
        for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
          InvoiceLists.add(chunks[_currentpagenum - 1][ss]);
          _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].total;
          _totalprofit = _totalprofit + chunks[_currentpagenum - 1][ss].profit;
        }
      }
      return InvoiceLists;
    }

    List<InvoiceListModel> getlist() {
      List<InvoiceListModel> customers = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        customers.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].total;
      }
      return customers;
    }

    double width = 1200;

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
                    child: MeasuredSize(
                  onChange: (Size size) {
                    setState(() {
                      width = size.width;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: _height / 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            left: width / 45,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CustomText(
                                    text: "Invoice List",
                                    size: 22,
                                    weight: FontWeight.bold,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 20, top: 5),
                                    child: InkWell(
                                      onTap: () {
                                        CsvInvoice.generateAndDownloadCsv(
                                            getlist(), 'Sales_List.csv');
                                      },
                                      child: Image.asset(
                                        "assets/icons/download_csv.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 10, top: 5),
                                    child: InkWell(
                                      onTap: () {
                                        PdfInvoice.generate(
                                            getlist(), _totalamount);
                                      },
                                      child: Image.asset(
                                        "assets/icons/download_pdf.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  _width > 1000
                                      ? SizedBox(
                                          width: width / 70,
                                        )
                                      : SizedBox(),
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _width > 950
                                            ? Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CustomText(
                                                  text: "Start Date",
                                                  size: _width / 90,
                                                ),
                                              )
                                            : SizedBox(),
                                        _width > 660
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    left: width / 200),
                                                child: InkWell(
                                                  onTap: () =>
                                                      _selectstartDate(context),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white,
                                                    ),
                                                    child: CustomText(
                                                      text: DateFormat.yMMMd()
                                                          .format(startDate)
                                                          .toString(),
                                                      size: _width / 100,
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                        _width > 1000
                                            ? SizedBox(
                                                width: width / 130,
                                              )
                                            : SizedBox(),
                                        _width > 950
                                            ? Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: CustomText(
                                                  text: "End Date",
                                                  size: _width / 90,
                                                ),
                                              )
                                            : SizedBox(),
                                        _width > 660
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    left: width / 200),
                                                child: InkWell(
                                                  onTap: () =>
                                                      _selectendDate(context),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors.white,
                                                    ),
                                                    child: CustomText(
                                                      text: DateFormat.yMMMd()
                                                          .format(endDate)
                                                          .toString(),
                                                      size: _width / 100,
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          width: _width / 120,
                                        ),
                                        _width > 660
                                            ? InkWell(
                                                onTap: () => _findData(),
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                                  child: CustomText(
                                                    text: "Find",
                                                    color: Colors.white,
                                                    size: _width / 80,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: buttonbg,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                width: _width / 7,
                                margin: EdgeInsets.only(
                                    top: 10,
                                    bottom: 10,
                                    right: _width > 1000 ? _width / 35 : 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.white,
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: TextField(
                                  controller: search_Invoice,
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    prefixIcon: Icon(Icons.search),
                                    hintText: "Search",
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  onChanged: (value) => _runFilter(value),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.grey.shade200,
                                  padding: EdgeInsets.only(left: 15, right: 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 30),
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _totaltop = false;
                                                _totalbot = false;
                                                allInvoiceLists.sort((a, b) =>
                                                    a.sl.compareTo(b.sl));
                                                makechunks();
                                              });
                                            },
                                            child: Text(
                                              "SL",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Invoice No",
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
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Invoice ID",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                        flex: 3,
                                      ),
                                      Text("|"),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Customer Name",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                        flex: 4,
                                      ),
                                      Text("|"),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  "Invoice Date",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: SizedBox(
                                                width: 1,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (!_datetop) {
                                                    _datetop = true;
                                                    _datebot = false;
                                                    _totaltop = false;
                                                    _totalbot = false;
                                                    allInvoiceLists.sort((a,
                                                            b) =>
                                                        a.invoiceDate.compareTo(
                                                            b.invoiceDate));
                                                    makechunks();
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = true;
                                                    _totaltop = false;
                                                    _totalbot = false;
                                                    allInvoiceLists.sort((b,
                                                            a) =>
                                                        a.invoiceDate.compareTo(
                                                            b.invoiceDate));
                                                    makechunks();
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_drop_up,
                                                      color: _datetop
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, 8.0, 0.0),
                                                  ),
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: _datebot
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, -8.0, 0.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        flex: 3,
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  "Total",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (!_totaltop) {
                                                    _datetop = false;
                                                    _datebot = false;
                                                    _totaltop = true;
                                                    _totalbot = false;
                                                    allInvoiceLists.sort(
                                                        (a, b) => a.total
                                                            .compareTo(
                                                                b.total));
                                                    makechunks();
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = false;
                                                    _totaltop = false;
                                                    _totalbot = true;
                                                    allInvoiceLists.sort(
                                                        (b, a) => a.total
                                                            .compareTo(
                                                                b.total));
                                                    makechunks();
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_drop_up,
                                                      color: _totaltop
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, 8.0, 0.0),
                                                  ),
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: _totalbot
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, -8.0, 0.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  "Profit",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (!_totaltop) {
                                                    _datetop = false;
                                                    _datebot = false;
                                                    _totaltop = true;
                                                    _totalbot = false;
                                                    allInvoiceLists.sort(
                                                        (a, b) => a.total
                                                            .compareTo(
                                                                b.total));
                                                    makechunks();
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = false;
                                                    _totaltop = false;
                                                    _totalbot = true;
                                                    allInvoiceLists.sort(
                                                        (b, a) => a.total
                                                            .compareTo(
                                                                b.total));
                                                    makechunks();
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_drop_up,
                                                      color: _totaltop
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, 8.0, 0.0),
                                                  ),
                                                  Container(
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: _totalbot
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                    transform: Matrix4
                                                        .translationValues(
                                                            0.0, -8.0, 0.0),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text("|"),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "ACTION",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                        flex: 3,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: _height / 1.60,
                                  child: FutureBuilder(
                                    builder: (ctx, AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(left: 20),
                                            child: CustomText(
                                              text: "No Invoice Available!!",
                                              size: 18,
                                              weight: FontWeight.bold,
                                            ),
                                          );
                                        } else if (snapshot.hasData) {
                                          return MediaQuery.removePadding(
                                            context: context,
                                            removeTop: true,
                                            child: ListView.builder(
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                _click.add(false);
                                                return InvoiceListItem(
                                                  index: index,
                                                  onInvoiceDetails:
                                                      _onInvoiceDetails,
                                                  onEditInvoice: _onEditInvoice,
                                                  cst: snapshot.data[index],
                                                  click: _click[index],
                                                  changeVal: changeVal,
                                                  onInvoiceDetailsPOS:
                                                      _onInvoiceDetailsPOS,
                                                  fetchDocuments:
                                                      _fetchDocuments,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    future: getCust(),
                                  ),
                                ),
                                _width > 600
                                    ? Container(
                                        color: Colors.grey.shade200,
                                        padding: const EdgeInsets.only(
                                            left: 15,
                                            right: 15,
                                            top: 5,
                                            bottom: 5),
                                        child: Row(
                                          children: [
                                            Text(" "),
                                            Text(" "),
                                            Text(" "),
                                            Text(" "),
                                            Text(" "),
                                            Text(" "),
                                            Text(" "),
                                            Expanded(
                                              flex: 19,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  "Total : ",
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  " ৳${_totalamount}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  "Total Profit : ",
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 7),
                                                child: Text(
                                                  " ৳${NumberFormat('#,##,#00.##').format(_totalprofit)}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: tabletitle,
                                                      fontFamily: 'inter'),
                                                ),
                                              ),
                                            ),
                                            Text(" "),
                                            Expanded(
                                              child: Container(),
                                              flex: 6,
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 45),
                                        child: Row(
                                          children: [
                                            CustomText(
                                              text: "Show entries",
                                              size: 12,
                                              color: tabletitle,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              child: DropdownButton<int>(
                                                value: _items,
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down),
                                                items: items.map((int items) {
                                                  return DropdownMenuItem(
                                                    value: items,
                                                    child: CustomText(
                                                      text: items.toString(),
                                                      size: 12,
                                                      color: tabletitle,
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (int? Value) {
                                                  setState(() {
                                                    _items = Value!;
                                                    makechunks();
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 10,
                                      ),
                                      Container(
                                        width: _width / 3,
                                        child: NumberPaginator(
                                          controller: _controller,
                                          numberPages: _totalpagenum,
                                          onPageChange: (int index) {
                                            setState(() {
                                              _currentpagenum = index + 1;
                                              _click = [];
                                            });
                                          },
                                        ),
                                      ),
                                      const Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 15,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
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
