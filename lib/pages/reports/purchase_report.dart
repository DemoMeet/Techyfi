import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_list_item.dart';
import 'package:groceyfi02/pages/reports/widget/invoice_report_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/customer.dart';
import '../../model/invoiceListModel.dart';
import '../../model/nav_bools.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class PurchaseReport extends StatefulWidget {
  
  
  Navbools nn;
  PurchaseReport(
      { required this.nn});

  @override
  State<PurchaseReport> createState() => _PurchaseReportState();
}

class _PurchaseReportState extends State<PurchaseReport> {
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
  List<bool> _click = [];
  List<InvoiceListModel> allPurchaseReports = [];
  List<InvoiceListModel> foundPurchaseReports = [];
  TextEditingController search_Invoice = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.report = true;
      widget.nn.report_purchase = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Purchase')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allPurchaseReports.add(InvoiceListModel(
            discount: element["Discount"],accountID: element["Account ID"],
            total: element["Grand Total"],
            due: element["Due"],retn: element["Return"],
            paid: element["Paid"],
            invoiceNo: element["Invoice No"],
            user: element['User'],profit: 0,
            customerID: element["Supplier ID"],
            customerName: element["Supplier"],
            invoiceDate: element["Invoice Date"].toDate(),
            invoiceID: element.id,
            sl: s));
        s++;
      });
    });
    foundPurchaseReports = allPurchaseReports;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundPurchaseReports.length; i += _items) {
      chunks.add(foundPurchaseReports.sublist(
          i,
          i + _items > foundPurchaseReports.length
              ? foundPurchaseReports.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundPurchaseReports.length / _items).floor() + 1;
    });
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
      results = allPurchaseReports;
    } else {
      results = allPurchaseReports
          .where((user) => user.invoiceNo
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundPurchaseReports = results;
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
      for (int i = 0; i < allPurchaseReports.length; i++) {
        if ((allPurchaseReports[i].invoiceDate.compareTo(startDate) >= 0 &&
                allPurchaseReports[i].invoiceDate.compareTo(endDate) <= 0) ||
            (allPurchaseReports[i].invoiceDate.difference(startDate).inDays ==
                    1 ||
                allPurchaseReports[i].invoiceDate.difference(endDate).inDays ==
                    1)) {
          results.add(allPurchaseReports[i]);
        } else if (startDate.difference(endDate).inDays == 0) {
          if (allPurchaseReports[i].invoiceDate.compareTo(startDate) == 1) {
            results.add(allPurchaseReports[i]);
          }
        }
      }
      foundPurchaseReports = [];
      setState(() {
        foundPurchaseReports = results;
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

    Future<List<InvoiceListModel>> getCust() async {
      List<InvoiceListModel> PurchaseReports = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        PurchaseReports.add(chunks[_currentpagenum - 1][ss]);
      }
      return PurchaseReports;
    }

    double width = 1200;

 

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar:MyAppBar(height: _height,width:  _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn, ),
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
                                text: "Purchase Report",
                                size: 22,
                                weight: FontWeight.bold,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 20, top: 5),
                                child: InkWell(
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
                                            alignment: Alignment.centerRight,
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
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            child: InkWell(
                                              onTap: () =>
                                                  _selectstartDate(context),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
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
                                          )
                                        : SizedBox(),
                                    _width > 1000
                                        ? SizedBox(
                                            width: width / 130,
                                          )
                                        : SizedBox(),
                                    _width > 950
                                        ? Container(
                                            alignment: Alignment.centerRight,
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
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
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
                                              alignment: Alignment.centerRight,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
                                              child: CustomText(
                                                text: "Find",
                                                color: Colors.white,
                                                size: _width / 80,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
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
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.grey),
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
                                            allPurchaseReports.sort(
                                                (a, b) => a.sl.compareTo(b.sl));
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
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Purchase ID",
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
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Supplier Name",
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
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              "Invoice Date",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                        const Expanded(
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
                                                allPurchaseReports.sort(
                                                    (a, b) =>
                                                        a.invoiceDate.compareTo(
                                                            b.invoiceDate));
                                                makechunks();
                                              } else {
                                                _datetop = false;
                                                _datebot = true;
                                                _totaltop = false;
                                                _totalbot = false;
                                                allPurchaseReports.sort(
                                                    (b, a) =>
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
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                              ),
                                              Container(
                                                child: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: _datebot
                                                      ? Colors.black
                                                      : Colors.black45,
                                                ),
                                                transform:
                                                    Matrix4.translationValues(
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
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              "Total",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
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
                                                allPurchaseReports.sort((a,
                                                        b) =>
                                                    a.total.compareTo(b.total));
                                                makechunks();
                                              } else {
                                                _datetop = false;
                                                _datebot = false;
                                                _totaltop = false;
                                                _totalbot = true;
                                                allPurchaseReports.sort((b,
                                                        a) =>
                                                    a.total.compareTo(b.total));
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
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                              ),
                                              Container(
                                                child: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: _totalbot
                                                      ? Colors.black
                                                      : Colors.black45,
                                                ),
                                                transform:
                                                    Matrix4.translationValues(
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
                                    child: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Added By",
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
                                            return InvoiceReportItem(
                                              index: index,
                                              cst: snapshot.data[index],
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
