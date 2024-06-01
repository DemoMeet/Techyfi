import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_list_item.dart';
import 'package:groceyfi02/pages/return/widgets/invoice_return_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/Return.dart';
import '../../model/customer.dart';
import '../../model/invoiceListModel.dart';
import '../../model/nav_bools.dart';
import '../../widgets/custom_text.dart';
import 'invoice-return_details.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class ManufactuerReturnList extends StatefulWidget {

  
  
  Navbools nn;
  ManufactuerReturnList(
      { required this.nn});
  @override
  State<ManufactuerReturnList> createState() => _ManufactuerReturnListState();
}

class _ManufactuerReturnListState extends State<ManufactuerReturnList> {
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
  List<Return> allInvoiceLists = [];
  List<Return> foundInvoiceLists = [];
  TextEditingController search_Invoice = TextEditingController();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.returnss = true;
      widget.nn.return_supplier_list= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Return').where('Purchase',isEqualTo: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allInvoiceLists.add(Return(wastage: element["Wastage"],user: element['User'],id: element["ID"],returntype: element["Return Type"],returns: element["Returns"],returndate: element["Return Date"],purchaseid: element["Purchase ID"],purchase: element["Purchase"],returnid:  element["Return ID"],invoiceno:  element["Invoice No"],suppliername:  element["Supplier Name"],dedamount:  element["Total Deduction"],invoiceid:  element["Invoice ID"], date:  element["Date"],amount:  element["Total Amount"],customername:  element["Supplier Name"],
            sl: s));
        s++;
      });
    });
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

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    myFocusNode = FocusNode();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<Return> results = [];
    if (enteredKeyword.isEmpty) {
      results = allInvoiceLists;
    } else {
      results = allInvoiceLists
          .where((user) => user.customername
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
      List<Return> results = [];
      for (int i = 0; i < allInvoiceLists.length; i++) {
        if ((allInvoiceLists[i].returndate.toDate().compareTo(startDate) >= 0 &&
            allInvoiceLists[i].returndate.toDate().compareTo(endDate) <= 0) ||
            (allInvoiceLists[i].returndate.toDate().difference(startDate).inDays == 1 ||
                allInvoiceLists[i].returndate.toDate().difference(endDate).inDays ==
                    1)) {
          results.add(allInvoiceLists[i]);
        } else if (startDate.difference(endDate).inDays == 0) {
          if (allInvoiceLists[i].returndate.toDate().compareTo(startDate) == 1) {
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

    Future<List<Return>> getCust() async {
      List<Return> InvoiceLists = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        InvoiceLists.add(chunks[_currentpagenum - 1][ss]);
      }
      return InvoiceLists;
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
                child:MeasuredSize(
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
                                    text: "Supplier Return List",
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
                                          margin: EdgeInsets.only(left: width / 200),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () => _selectstartDate(context),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
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
                                          margin: EdgeInsets.only(left: width / 200),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () => _selectendDate(context),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 5),
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
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: buttonbg,
                                            ),
                                            child: CustomText(
                                              text: "Find",
                                              color: Colors.white,
                                              size: _width / 80,
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
                                    borderRadius: BorderRadius.all(Radius.circular(10))),
                                child: TextField(
                                  controller: search_Invoice,
                                  decoration: const InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: Colors.grey),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                                                allInvoiceLists
                                                    .sort((a, b) => a.sl.compareTo(b.sl));
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
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                margin: const EdgeInsets.only(left: 7),
                                                child: Text(
                                                  "Return Date",
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
                                                  if (!_datetop) {
                                                    _datetop = true;
                                                    _datebot = false;
                                                    _totaltop = false;
                                                    _totalbot = false;
                                                    allInvoiceLists.sort((a, b) => a
                                                        .returndate.toDate()
                                                        .compareTo(b.returndate.toDate()));
                                                    makechunks();
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = true;
                                                    _totaltop = false;
                                                    _totalbot = false;
                                                    allInvoiceLists.sort((b, a) => a
                                                        .returndate.toDate()
                                                        .compareTo(b.returndate.toDate()));
                                                    makechunks();
                                                  }
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    transform: Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                                    child: Icon(
                                                      Icons.arrow_drop_up,
                                                      color: _datetop
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                  ),
                                                  Container(
                                                    transform: Matrix4.translationValues(
                                                        0.0, -8.0, 0.0),
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: _datebot
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Text("|"),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                    allInvoiceLists.sort((a, b) =>
                                                        a.amount.compareTo(b.amount));
                                                    makechunks();
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = false;
                                                    _totaltop = false;
                                                    _totalbot = true;
                                                    allInvoiceLists.sort((b, a) =>
                                                        a.amount.compareTo(b.amount));
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
                                                    transform: Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                                  ),
                                                  Container(
                                                    transform: Matrix4.translationValues(
                                                        0.0, -8.0, 0.0),
                                                    child: Icon(
                                                      Icons.arrow_drop_down,
                                                      color: _totalbot
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Return Type",
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
                                        flex: 2,
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
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: _height / 1.60,
                                  child: FutureBuilder(
                                    builder: (ctx,AsyncSnapshot snapshot) {
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
                                                return InvoiceReturnListItem(
                                                  index: index,
                                                  cst: snapshot.data[index],
                                                  click: _click[index],
                                                  changeVal: changeVal,
                                                  fetchDocuments: _fetchDocuments,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return Center(
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
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              child: DropdownButton<int>(
                                                value: _items,
                                                icon: const Icon(Icons.keyboard_arrow_down),
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
                                      const Expanded(
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
