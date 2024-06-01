import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/model/wastage.dart';
import 'package:groceyfi02/pages/return/widgets/return_wastage_item.dart';
import 'package:groceyfi02/pages/return/widgets/return_wastage_select_item.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/pages/invoice/widget/invoice_list_item.dart';
import 'package:groceyfi02/pages/return/widgets/invoice_return_list_item.dart';
import 'package:groceyfi02/pages/return/widgets/wastage_return_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/auth_service.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/Accounts.dart';
import '../../model/Return.dart';
import '../../model/Single.dart';
import '../../model/customer.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/custom_text.dart';
import 'invoice-return_details.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class ReturnWastage extends StatefulWidget {
  Navbools nn;
  ReturnWastage({required this.nn});
  @override
  State<ReturnWastage> createState() => _ReturnWastageState();
}

class _ReturnWastageState extends State<ReturnWastage> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  late FocusNode myFocusNode;
  var manufact = [], smanufact = [];
  var _selectedpayment;
  var _selectedsupplierid, _selectedsupplier;
  late List<Wastage> checkedItems;
  String dropdownvalue = 'Search By Invoice No';
  int val = 0;
  bool _first = false,
      _totaltop = false,
      _totalbot = false,
      _datebot = false,
      _datetop = false;
  double _totalamount = 0, _deduction = 0;
  final TextEditingController _recived_amount =
      TextEditingController(text: '0');
  var payment = ["Bank Payment", "Cash Payment"];
  bool selectedpm = false, bankpayment = false, processing = true;
  List<Accounts> _cashaccounts = [];
  List<Accounts> _bankaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount;
  var _selectedAccountid;
  int _retntype = 1;
  bool sup = true;
  List<bool> _click = [];
  List<Wastage> allInvoiceLists = [];
  List<Wastage> foundInvoiceLists = [];
  TextEditingController search_Invoice = TextEditingController();

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.returnss = true;
      widget.nn.return_wastage_list = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Wastage')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allInvoiceLists.add(Wastage(
            quantity: element["Quantity"],
            check: false,
            totalbuying: element["Total Buying"],
            price: element["Price"],
            productid: element["Product ID"],
            productname: element["Product Name"],
            sl: s));
        s++;
      });
    });

    setState(() {
      foundInvoiceLists = allInvoiceLists;
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
    List<Wastage> results = [];
    if (enteredKeyword.isEmpty) {
      results = allInvoiceLists;
    } else {
      results = allInvoiceLists
          .where((user) => user.productname
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundInvoiceLists = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    bool isAnyQuantityZero(List<TextEditingController> quantitys) {
      for (TextEditingController controller in quantitys) {
        int value = int.tryParse(controller.text) ?? 0;
        if (value == 0) {
          // Quantity is zero
          return true;
        }
      }
      // No quantity is zero
      return false;
    }
    void changeVal(String i) {
      setState(() {
        _click[val] = false;
        _click[int.parse(i)] = true;
        val = int.parse(i);
      });
    }

    Future<List<Wastage>> getCust() async {
      return foundInvoiceLists;
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
                                    text: "Wastage Return List",
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
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, top: 10, bottom: 10),
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
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Product Name",
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
                                            "Price",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      const Text("|"),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Quantity",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      const Text("|"),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Total Price",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      const Text("|"),
                                      Expanded(
                                        flex: 1,
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
                                SizedBox(
                                  height: _height / 1.50,
                                  child: FutureBuilder(
                                    builder: (ctx, AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                                "No Return Data Available.."),
                                          );
                                        } else if (snapshot.hasError) {
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
                                                return ReturnWastageItem(
                                                  index: index,
                                                  cst: snapshot.data[index],
                                                  click: _click[index],
                                                  changeVal: changeVal,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        checkedItems = allInvoiceLists
                                            .where((wastage) => wastage.check)
                                            .toList();
                                        List<TextEditingController> quantitys =
                                            [];

                                        for (int i = 0;
                                            i < checkedItems.length;
                                            i++) {
                                          quantitys.add(
                                              TextEditingController(text: "0"));
                                        }
                                        if (checkedItems.isNotEmpty) {
                                          showDialog(
                                            context: context,
                                            barrierColor: Colors.transparent,
                                            barrierDismissible: true,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setState) {
                                                  return Dialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    elevation: 20,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.7,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: Border.all(
                                                                      width:
                                                                          0.5,
                                                                      color: Colors
                                                                          .white),
                                                                  borderRadius: const BorderRadius
                                                                      .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15)),
                                                                  color: Colors
                                                                      .grey
                                                                      .shade200,
                                                                ),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            30,
                                                                        vertical:
                                                                            10),
                                                                width: double
                                                                    .infinity,
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .warning_amber_rounded,
                                                                      color: Colors
                                                                          .black87,
                                                                      size: 26,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    CustomText(
                                                                      text:
                                                                          "Return Wastage Products",
                                                                      size: 17,
                                                                      weight: FontWeight
                                                                          .bold,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    const Expanded(
                                                                        child:
                                                                            SizedBox()),
                                                                    GestureDetector(
                                                                      child: Icon(
                                                                          Icons
                                                                              .close),
                                                                      onTap:
                                                                          () {
                                                                        Get.back();
                                                                      },
                                                                    ),
                                                                  ],
                                                                )),
                                                          ),
                                                          Expanded(
                                                            flex: 9,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 20,
                                                                      right: 20,
                                                                      bottom:
                                                                          20,
                                                                      top: 10),
                                                              child:
                                                                  SingleChildScrollView(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              10,
                                                                          left:
                                                                              10,
                                                                          right:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          CustomText(
                                                                            text:
                                                                                "Select Return Type: ",
                                                                            size:
                                                                                16,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                RadioListTile(
                                                                              title: const Text("Supplier"),
                                                                              value: 1,
                                                                              groupValue: _retntype,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  _retntype = int.parse(value.toString());
                                                                                  sup = true;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                200,
                                                                            child:
                                                                                RadioListTile(
                                                                              title: const Text("Trash"),
                                                                              value: 2,
                                                                              groupValue: _retntype,
                                                                              onChanged: (value) {
                                                                                setState(() {
                                                                                  _retntype = int.parse(value.toString());
                                                                                  sup = false;
                                                                                });
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    sup
                                                                        ? Container(
                                                                            margin: const EdgeInsets.only(
                                                                                top: 10,
                                                                                left: 10,
                                                                                right: 10),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Expanded(
                                                                                  flex: 2,
                                                                                  child: Container(
                                                                                    alignment: Alignment.centerRight,
                                                                                    child: CustomText(
                                                                                      text: "Supplier",
                                                                                      size: 16,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 3,
                                                                                  child: Container(
                                                                                    margin: const EdgeInsets.only(left: 20),
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                                                                                          _selectedsupplierid = manufact[smanufact.indexOf(newValue)];
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
                                                                                const Expanded(
                                                                                  flex: 5,
                                                                                  child: SizedBox(
                                                                                    height: 1,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : SizedBox(),
                                                                    sup
                                                                        ? Container(
                                                                            margin: const EdgeInsets.only(
                                                                                top: 10,
                                                                                left: 10,
                                                                                right: 10),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Expanded(
                                                                                  flex: 2,
                                                                                  child: Container(
                                                                                    alignment: Alignment.centerRight,
                                                                                    child: CustomText(
                                                                                      text: "Select Payment",
                                                                                      size: 16,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 3,
                                                                                  child: Container(
                                                                                    margin: const EdgeInsets.only(left: 20),
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
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
                                                                                                text: "  Bank Payment",
                                                                                                size: 16,
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : Expanded(
                                                                                            flex: 2,
                                                                                            child: Container(
                                                                                              alignment: Alignment.centerRight,
                                                                                              child: CustomText(
                                                                                                text: "  Cash Payment",
                                                                                                size: 16,
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                    : const SizedBox(),
                                                                                selectedpm
                                                                                    ? bankpayment
                                                                                        ? Expanded(
                                                                                            flex: 3,
                                                                                            child: Container(
                                                                                              margin: EdgeInsets.only(left: 20),
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                color: Colors.grey.shade200,
                                                                                              ),
                                                                                              child: DropdownButton(
                                                                                                underline: const SizedBox(),
                                                                                                isExpanded: true,
                                                                                                hint: const Text('Select Bank Account'),
                                                                                                value: _selectedaccount,
                                                                                                onChanged: (Value) {
                                                                                                  setState(() {
                                                                                                    _selectedaccount = Value.toString();
                                                                                                    _selectedAccountid = _bankaccounts[sbankaccounts.indexOf(Value.toString())];
                                                                                                  });
                                                                                                },
                                                                                                items: _bankaccounts.map((location) {
                                                                                                  return DropdownMenuItem(
                                                                                                    value: location.accountnum,
                                                                                                    child: Text("${location.bankname} (${location.accountnum})"),
                                                                                                  );
                                                                                                }).toList(),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : Expanded(
                                                                                            flex: 3,
                                                                                            child: Container(
                                                                                              margin: EdgeInsets.only(left: 20),
                                                                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(5),
                                                                                                color: Colors.grey.shade200,
                                                                                              ),
                                                                                              child: DropdownButton(
                                                                                                underline: const SizedBox(),
                                                                                                isExpanded: true,
                                                                                                hint: const Text('Select Cash Counter'),
                                                                                                value: _selectedaccount,
                                                                                                onChanged: (Value) {
                                                                                                  setState(() {
                                                                                                    _selectedaccount = Value.toString();
                                                                                                    _selectedAccountid = _cashaccounts[scashaccounts.indexOf(Value.toString())];
                                                                                                  });
                                                                                                },
                                                                                                items: _cashaccounts.map((location) {
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
                                                                                    ? const SizedBox(
                                                                                        height: 1,
                                                                                      )
                                                                                    : const Expanded(
                                                                                        flex: 5,
                                                                                        child: SizedBox(
                                                                                          height: 1,
                                                                                        ),
                                                                                      ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : const SizedBox(),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Container(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              10,
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 30),
                                                                              child: Text(
                                                                                "SL",
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                              "|"),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Product Name",
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Text(
                                                                              "|"),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Avail QTY",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Text(
                                                                              "|"),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Container(
                                                                              alignment: Alignment.center,
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Price",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Text(
                                                                              "|"),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Container(
                                                                              alignment: Alignment.center,
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Total Buying",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Text(
                                                                              "|"),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Quantity",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const Text(
                                                                              "|"),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Container(
                                                                              alignment: Alignment.centerRight,
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Total",
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          _height /
                                                                              6.5,
                                                                      child: MediaQuery
                                                                          .removePadding(
                                                                        context:
                                                                            context,
                                                                        removeTop:
                                                                            true,
                                                                        child: ListView
                                                                            .builder(
                                                                          itemCount:
                                                                              checkedItems.length,
                                                                          itemBuilder:
                                                                              (context, index) {
                                                                            _click.add(false);

                                                                            updatetotals() {
                                                                              double totalAmount = 0;
                                                                              double deduction = 0;

                                                                              for (int i = 0; i < checkedItems.length; i++) {
                                                                                Wastage ss = checkedItems[i];
                                                                                totalAmount += ss.price * double.parse(quantitys[i].text.toString());
                                                                              }

                                                                              deduction = totalAmount - double.parse(_recived_amount.text);

                                                                              setState(() {
                                                                                _totalamount = totalAmount;
                                                                                _deduction = deduction;
                                                                              });
                                                                            }

                                                                            return ReturnWastageSelectItem(
                                                                              index: index,
                                                                              cst: checkedItems[index],
                                                                              quantitys: quantitys[index],
                                                                              click: _click[index],
                                                                              changeVal: updatetotals,
                                                                              fetchDocuments: _fetchDocuments,
                                                                            );
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                26,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Total : ",
                                                                                textAlign: TextAlign.right,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                6,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                _totalamount.toString(),
                                                                                textAlign: TextAlign.end,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    sup
                                                                        ? Container(
                                                                            color:
                                                                                Colors.grey.shade200,
                                                                            padding: const EdgeInsets.only(
                                                                                left: 15,
                                                                                top: 5,
                                                                                bottom: 5),
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  flex: 26,
                                                                                  child: Container(
                                                                                    margin: EdgeInsets.only(left: 7),
                                                                                    child: Text(
                                                                                      "Received : ",
                                                                                      textAlign: TextAlign.right,
                                                                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 15,
                                                                                ),
                                                                                Expanded(
                                                                                  flex: 6,
                                                                                  child: Container(
                                                                                    decoration: BoxDecoration(
                                                                                      border: Border.all(
                                                                                        width: 1,
                                                                                        color: Colors.grey.shade500,
                                                                                      ),
                                                                                      borderRadius: BorderRadius.circular(5),
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    alignment: Alignment.centerRight,
                                                                                    child: TextFormField(
                                                                                      controller: _recived_amount,
                                                                                      keyboardType: TextInputType.number,
                                                                                      textAlign: TextAlign.end,
                                                                                      inputFormatters: <TextInputFormatter>[
                                                                                        FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)')),
                                                                                      ],
                                                                                      style: TextStyle(fontSize: 12),
                                                                                      decoration: const InputDecoration(
                                                                                        isDense: true,
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                                                          borderSide: BorderSide(color: Colors.transparent),
                                                                                        ),
                                                                                        disabledBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                                                          borderSide: BorderSide(color: Colors.transparent),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                                                                          borderSide: BorderSide(color: Colors.blue),
                                                                                        ),
                                                                                        fillColor: Colors.white,
                                                                                        filled: true,
                                                                                      ),
                                                                                      onChanged: (val) {
                                                                                        setState(() {
                                                                                          if (val.isEmpty) {
                                                                                            _recived_amount.text = "0";
                                                                                          }
                                                                                          final number = int.tryParse(val);
                                                                                          if (number != null) {
                                                                                            final text = number.clamp(0, _totalamount).toString();
                                                                                            final selection = TextSelection.collapsed(
                                                                                              offset: text.length,
                                                                                            );
                                                                                            _recived_amount.value = TextEditingValue(
                                                                                              text: text,
                                                                                              selection: selection,
                                                                                            );

                                                                                            setState(() {
                                                                                              _deduction = _totalamount - double.parse(_recived_amount.text);
                                                                                            });
                                                                                          }
                                                                                        });
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : SizedBox(),
                                                                    Container(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      padding: const EdgeInsets.only(
                                                                          left:
                                                                              15,
                                                                          right:
                                                                              15,
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              5),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                26,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                "Deduction : ",
                                                                                textAlign: TextAlign.right,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                6,
                                                                            child:
                                                                                Container(
                                                                              margin: EdgeInsets.only(left: 7),
                                                                              child: Text(
                                                                                _deduction.toString(),
                                                                                textAlign: TextAlign.end,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: tabletitle, fontFamily: 'inter'),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .end,
                                                                      children: [
                                                                        sup
                                                                            ? ElevatedButton(
                                                                                onPressed: () {const _chars =
                                                                                    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                                                Random _rnd = Random();
                                                                                String getRandomString(int length) =>
                                                                                    String.fromCharCodes(Iterable.generate(
                                                                                        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
                                                                                String rtnID = getRandomString(20);
                                                                                  if (isAnyQuantityZero(quantitys) || _selectedpayment.toString() == "null" ||
                                                                                  _selectedAccountid.toString() == "null" || _selectedsupplierid.toString() == 'null') {
                                                                                    Get.snackbar("Wastage Return Failed.",
                                                                                        "Quantity should not be 0, supplier and payment method should be selected is Required",
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
                                                                                    List<Map> list = [];
                                                                                    for (int i = 0; i < checkedItems.length; i++) {
                                                                                      Wastage ss = checkedItems[i];
                                                                                      list.add({
                                                                                        "Product Name": ss.productname,
                                                                                        "Product ID": ss.productid,
                                                                                        "Quantity": double.parse(quantitys[i].text),
                                                                                        "Price": ss.price,
                                                                                      });
                                                                                      if(ss.quantity==double.parse(quantitys[i].text)){
                                                                                        FirebaseFirestore.instance
                                                                                            .collection('Wastage')
                                                                                            .doc(ss.productid).delete();
                                                                                      }else{
                                                                                        FirebaseFirestore.instance
                                                                                            .collection('Wastage')
                                                                                            .doc(ss.productid).update(
                                                                                            {
                                                                                              "Quantity":ss.quantity -  double.parse(quantitys[i].text),
                                                                                            });
                                                                                      }
                                                                                    }

                                                                                    FirebaseFirestore.instance
                                                                                        .collection('Supplier')
                                                                                        .doc(_selectedsupplierid.id)
                                                                                        .get()
                                                                                        .then((element) {
                                                                                      FirebaseFirestore.instance
                                                                                          .collection('Supplier')
                                                                                          .doc(_selectedsupplierid.id)
                                                                                          .update({
                                                                                        'Balance': element["Balance"] - double.parse(_recived_amount.text),
                                                                                      });
                                                                                    });

                                                                                    FirebaseFirestore.instance.collection('Transaction').add({
                                                                                      'Name': _selectedsupplierid.name,
                                                                                      '2nd ID': _selectedsupplierid.id,
                                                                                      'Remarks': "Wastage Return",
                                                                                      'Submit Date': DateTime.now(),
                                                                                      'Type': 'Debit',
                                                                                      'Date': DateTime.now(),
                                                                                      'Payment Method': _selectedpayment,
                                                                                      'ID': rtnID,
                                                                                      'User': AuthService.to.user?.name,
                                                                                      'Account ID': _selectedAccountid.uid,
                                                                                      'Account Details': _selectedAccountid.toJson(),
                                                                                      'Amount': double.parse(_recived_amount.text),
                                                                                    });
                                                                                    FirebaseFirestore.instance
                                                                                        .collection('Account')
                                                                                        .doc(_selectedAccountid.uid)
                                                                                        .update({
                                                                                      'Balance': _selectedAccountid.bal + double.parse(_recived_amount.text),
                                                                                    });

                                                                                    FirebaseFirestore.instance.collection('Trashbin').doc(rtnID).set({
                                                                                      'Products': list,
                                                                                      'Return ID': rtnID,
                                                                                      'User': AuthService.to.user?.name,
                                                                                      'Supplier Name': _selectedsupplierid.name,
                                                                                      'Supplier ID': _selectedsupplierid.id,
                                                                                      'Total Amount': _totalamount,
                                                                                      'Total Deduction': _deduction,
                                                                                      'Received Amount': double.parse(_recived_amount.text),
                                                                                      'Trash': false,
                                                                                      'Return Date': DateTime.now(),
                                                                                    }).then((valu) {
                                                                                      widget.nn.setnavbool();
                                                                                      widget.nn.return_trashbin = true;
                                                                                      widget.nn.returnss = true;
                                                                                      Get.offNamed(trashbinPageRoute);
                                                                                      Get.snackbar("Returned Successfully!",
                                                                                          "Wastage Processed..",
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
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: buttonbg,
                                                                                  elevation: 20,
                                                                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                                                ),
                                                                                child: CustomText(
                                                                                  text: "Save Return",
                                                                                  size: 14,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              )
                                                                            : ElevatedButton(
                                                                                onPressed: () {const _chars =
                                                                                    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
                                                                                Random _rnd = Random();
                                                                                String getRandomString(int length) =>
                                                                                    String.fromCharCodes(Iterable.generate(
                                                                                        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
                                                                                String rtnID = getRandomString(20);
                                                                                  if (isAnyQuantityZero(quantitys)) {
                                                                                    Get.snackbar("Wastage Trash Failed.",
                                                                                        "Quantity should not be 0",
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
                                                                                    List<Map> list = [];
                                                                                    for (int i = 0; i < checkedItems.length; i++) {
                                                                                      Wastage ss = checkedItems[i];
                                                                                      list.add({
                                                                                        "Product Name": ss.productname,
                                                                                        "Product ID": ss.productid,
                                                                                        "Quantity": double.parse(quantitys[i].text),
                                                                                        "Price": ss.price,
                                                                                      });
                                                                                      if(ss.quantity==double.parse(quantitys[i].text)){
                                                                                        FirebaseFirestore.instance
                                                                                            .collection('Wastage')
                                                                                            .doc(ss.productid).delete();
                                                                                      }else{
                                                                                        FirebaseFirestore.instance
                                                                                            .collection('Wastage')
                                                                                            .doc(ss.productid).update(
                                                                                            {
                                                                                              "Quantity":ss.quantity -  double.parse(quantitys[i].text),
                                                                                            });
                                                                                      }
                                                                                    }

                                                                                    FirebaseFirestore.instance.collection('Trashbin').doc(rtnID).set({
                                                                                      'Products': list,
                                                                                      'Return ID': rtnID,
                                                                                      'User': AuthService.to.user?.name,
                                                                                      'Supplier Name': "",
                                                                                      'Supplier ID': "",
                                                                                      'Total Amount': _totalamount,
                                                                                      'Total Deduction': _deduction,
                                                                                      'Received Amount': 0,
                                                                                      'Trash': true,
                                                                                      'Return Date': DateTime.now(),
                                                                                    }).then((valu) {
                                                                                      widget.nn.setnavbool();
                                                                                      widget.nn.return_trashbin = true;
                                                                                      widget.nn.returnss = true;
                                                                                      Get.offNamed(trashbinPageRoute);
                                                                                      Get.snackbar("Wastage Trashed Successfully!",
                                                                                          "Wastage Processed..",
                                                                                          snackPosition: SnackPosition.BOTTOM,
                                                                                          colorText: Colors.white,
                                                                                          backgroundColor: Colors.green,
                                                                                          margin: EdgeInsets.zero,
                                                                                          duration: const Duration(milliseconds: 2000),
                                                                                          boxShadows: [
                                                                                            const BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                                                                                          ],
                                                                                          borderRadius: 0);
                                                                                    }).catchError((error) => print("Failed to add user: $error"));
                                                                                  }
                                                                                },
                                                                                style: ElevatedButton.styleFrom(
                                                                                  backgroundColor: buttonbg,
                                                                                  elevation: 20,
                                                                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                                                                ),
                                                                                child: CustomText(
                                                                                  text: "Make Trash",
                                                                                  size: 14,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                        const SizedBox(
                                                                          width:
                                                                              25,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        } else {
                                          Get.snackbar("Wastage Return Failed.",
                                              "At least one item has to be selected to process return!!",
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              colorText: Colors.white,
                                              backgroundColor: Colors.red,
                                              margin: EdgeInsets.zero,
                                              duration: const Duration(
                                                  milliseconds: 2000),
                                              boxShadows: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    offset: Offset(-100, 0),
                                                    blurRadius: 20),
                                              ],
                                              borderRadius: 0);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonbg,
                                        elevation: 20,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 10),
                                      ),
                                      child: CustomText(
                                        text: "Process Wastage Return",
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 45,
                                    ),
                                  ],
                                ),
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
