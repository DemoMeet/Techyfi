import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/pages/reports/invoice_report_user.dart';
import 'package:groceyfi02/pages/reports/widget/invoice_report_list_item.dart';
import 'package:groceyfi02/pages/reports/widget/invoice_report_user_items.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/Single.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../../model/invoiceListModel.dart';

class PurchaseReportUser extends StatefulWidget {
  
  
  Navbools nn;
  PurchaseReportUser(
      {super.key,
        
        required this.nn,
        });

  @override
  State<PurchaseReportUser> createState() => _PurchaseReportUserState();
}

class _PurchaseReportUserState extends State<PurchaseReportUser> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  var suser = [];
  var _selecteduser;
  double _totalamount = 0;
  bool _progress = false, _empty = false;
  DateTime selectedstartDate = DateTime.now();
  DateTime selectedendDate = DateTime.now();
  bool _first = false,
      _nametop = false,
      _totaltop = false,
      _totalbot = false,
      _datetop = false,
      _datebot = false;
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;

  List<InvoiceListModel> allInvoiceListModels = [];
  List<InvoiceListModel> foundInvoiceListModels = [];
  void _fetchDatas() async {
    suser.add("Super Admin");
    await FirebaseFirestore.instance
        .collection('User')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        suser.add(element["Name"]);
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  _selectstartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedstartDate,
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
    if (picked != null && picked != selectedstartDate)
      setState(() {
        selectedstartDate = picked;
      });
  }

  _selectendDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedendDate,
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
    if (picked != null && picked != selectedendDate) {
      setState(() {
        selectedendDate = picked;
      });
    }
  }


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.report = true;
      widget.nn.report_purchase_supplier= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments(DateTime startDate, DateTime endDate) async {
    int s = 0;
    allInvoiceListModels = [];

    setState(() {
      _progress = true;
    });
    await FirebaseFirestore.instance
        .collection('Purchase')
        .where("Invoice Date", isGreaterThan: startDate)
        .where("Invoice Date", isLessThan: endDate)
        .where("User", isEqualTo: _selecteduser)
        .get()
        .then((querySnapshot) {
      print(querySnapshot.docs.length);
      print(querySnapshot.size);
      if (querySnapshot.size == 0) {
        setState(() {
          _progress = false;
          _empty = true;
        });
      } else {
        querySnapshot.docs.forEach((element) {
          allInvoiceListModels.add(InvoiceListModel(
              discount: element["Discount"],
              total: element["Grand Total"],
              due: element["Due"],profit: 0,retn: element["Return"],
              paid: element["Paid"],accountID: element["Account ID"],
              invoiceNo: element["Invoice No"],
              user: element['User'],
              customerID: element["Supplier ID"],
              customerName: element["Supplier"],
              invoiceDate: element["Invoice Date"].toDate(),
              invoiceID: element.id,
              sl: s));
          s++;
          runds();
        });
      }
    }).catchError((error) => print("Failed to add user: $error"));
  }

  void runds() {
    setState(() {
      _empty = false;
      _progress = false;
      foundInvoiceListModels = allInvoiceListModels;
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
      _totalamount = 0;
      for (int ss = 0; ss < foundInvoiceListModels.length; ss++) {
        _totalamount = _totalamount + foundInvoiceListModels[ss].total;
      }
      return foundInvoiceListModels;
    }

 

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
                child: Container(
                  margin: EdgeInsets.only(top: _height / 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              left: 30,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: "Purchase Report (User)",
                                  size: 30,
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
                                const Expanded(
                                    child: SizedBox(
                                      height: 1,
                                    )),
                                SizedBox(
                                  height: 1,
                                  width: _width / 25,
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
                                      text: "Start Date",
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: InkWell(
                                      onTap: () => _selectstartDate(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: CustomText(
                                          text: DateFormat.yMMMd()
                                              .format(selectedstartDate)
                                              .toString(),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: CustomText(
                                      text: "End Date",
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: InkWell(
                                      onTap: () => _selectendDate(context),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: CustomText(
                                          text: DateFormat.yMMMd()
                                              .format(selectedendDate)
                                              .toString(),
                                          size: 16,
                                        ),
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
                                      text: "User",
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      isExpanded: true,
                                      hint: const Text('Select User'),
                                      value: _selecteduser,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selecteduser = newValue.toString();
                                        });
                                      },
                                      items: suser.map((location) {
                                        return DropdownMenuItem(
                                          value: location,
                                          child: Text(location),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _fetchDocuments(
                                            selectedstartDate, selectedendDate);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonbg,
                                        elevation: 20,
                                        padding: EdgeInsets.symmetric(vertical: 20),
                                      ),
                                      child: CustomText(
                                        text: "Submit",
                                        weight: FontWeight.bold,
                                        color: Colors.white,
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
                          SizedBox(
                            height: 20,
                          ),
                          Container(
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
                                                allInvoiceListModels.sort(
                                                        (a, b) => a.sl.compareTo(b.sl));
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
                                                    allInvoiceListModels.sort(
                                                            (a, b) => a.invoiceDate
                                                            .compareTo(
                                                            b.invoiceDate));
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = true;
                                                    _totaltop = false;
                                                    _totalbot = false;
                                                    allInvoiceListModels.sort(
                                                            (b, a) => a.invoiceDate
                                                            .compareTo(
                                                            b.invoiceDate));
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
                                                    allInvoiceListModels.sort((a,
                                                        b) =>
                                                        a.total.compareTo(b.total));
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = false;
                                                    _totaltop = false;
                                                    _totalbot = true;
                                                    allInvoiceListModels.sort((b,
                                                        a) =>
                                                        a.total.compareTo(b.total));
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
                                    ],
                                  ),
                                ),
                                _progress
                                    ? Container(
                                  height: _height / 2.1,
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                )
                                    : _empty
                                    ? Container(
                                  height: _height / 2.1,
                                  alignment: Alignment.center,
                                  child: const Text(
                                      "Select Correct Dates And Product Name.. No Item Available"),
                                )
                                    : Container(
                                  height: foundInvoiceListModels.length <=
                                      10
                                      ? _height / 2
                                      : _height / 2 +
                                      (foundInvoiceListModels.length -
                                          10) *
                                          50.0,
                                  child: FutureBuilder(
                                    builder:
                                        (ctx, AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                                "Select Dates And user Name.."),
                                          );
                                        } else if (snapshot.hasData) {
                                          return MediaQuery.removePadding(
                                            context: context,
                                            removeTop: true,
                                            child: ListView.builder(
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              itemCount:
                                              snapshot.data.length,
                                              itemBuilder:
                                                  (context, index) {
                                                return InvoiceReportUserItems(
                                                  index: index,
                                                  cst: snapshot
                                                      .data[index],
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return const Center(
                                        child: Text(
                                            "Select Correct Dates And user Name.."),
                                      );
                                    },
                                    future: getCust(),
                                  ),
                                ),
                                _width > 600
                                    ? Container(
                                  color: Colors.grey.shade200,
                                  padding: EdgeInsets.only(
                                      left: 15,
                                      right: 15,
                                      top: 5,
                                      bottom: 25),
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
                                        flex: 36,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Total : ",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            _totalamount.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      Text(" "),
                                      Expanded(
                                        child: Container(),
                                        flex: 2,
                                      ),
                                    ],
                                  ),
                                )
                                    : const SizedBox(),
                              ],
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
