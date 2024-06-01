import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/LendingPayment.dart';
import '../../../model/Single.dart';
import '../../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../widgets/lendingpayment_list_item.dart';

class LendingPersonLedger extends StatefulWidget {
  
  
  Navbools nn;
  LendingPersonLedger(
      {super.key,
      
      required this.nn,
      });
  @override
  State<LendingPersonLedger> createState() => _LendingPersonLedgerState();
}

class _LendingPersonLedgerState extends State<LendingPersonLedger> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  var _selectedLendingPayment;
  var _selectedLendingPaymentid;
  var lendingPayment = [];
  List<String> sLendingPayment = [];
  double _totaldebitamount = 0, _totalcreitamount = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false,
      _nametop = false,
      _namebot = false,
      _datetop = false,
      _datebot = false;
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<double> balance = [];
  List<LendingPayment> allLendingPayments = [];
  List<LendingPayment> foundLendingPayments = [];
  TextEditingController search_LendingPayment = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_lending = true;
      widget.nn.human_resource_personledger= true;
      controller.onChange(false);
      _first = true;
    }
  }

  Future<void> _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('LendingPerson')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        lendingPayment.add(Single(id: element.id, name: element["Name"]));
        sLendingPayment.add(element["Name"]);
        setState(() {});
      });
    });

    int s = 0;
    await FirebaseFirestore.instance
        .collection('LendingPayment')
        .orderBy("Date", descending: false)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allLendingPayments.add(LendingPayment(
          status: element["Status"],user: element['User'],
          lendingid: element["Lending ID"],
          lendingpersonid: element["Lending Person ID"],
          lendingpersonname: element["Lending Person Name"],
          remarks: element["Remarks"],
          sl: s,
          uid: element["UID"],
          amount: element["Amount"],
          date: element["Date"],
        ));
        if (s == 0) {
          if (element['Status'] == "Debit") {
            balance.add(element["Amount"]);
          } else {
            balance.add(-element["Amount"]);
          }
        } else {
          if (element['Status'] == "Debit") {
            balance.add(element["Amount"] + balance[s - 1]);
          } else {
            balance.add(-element["Amount"] + balance[s - 1]);
          }
        }

        s++;
      });
    });
    setState(() {
      foundLendingPayments = allLendingPayments;
    });
  }

  void _onEditLendingPayment(LendingPayment cst) {
    // Navigator.of(context).pushNamed(
    //   editSalaryPageRoute,
    //   arguments: {
    //     'Salary': jsonEncode(cst),
    //   },
    // );
  }
  void _fetchDocuments(DateTime startDate, DateTime endDate) async {
    int s = 0;
    allLendingPayments = [];
    foundLendingPayments = [];
    balance = [];
    await FirebaseFirestore.instance
        .collection('LendingPayment')
        .where("Date", isGreaterThan: startDate)
        .where("Date", isLessThan: endDate)
        .orderBy("Date", descending: false)
        .where("Lending Person ID", isEqualTo: _selectedLendingPaymentid.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allLendingPayments.add(LendingPayment(
          status: element["Status"],
          lendingid: element["Lending ID"],user: element['User'],
          lendingpersonid: element["Lending Person ID"],
          lendingpersonname: element["Lending Person Name"],
          remarks: element["Remarks"],
          sl: s,
          uid: element["UID"],
          amount: element["Amount"],
          date: element["Date"],
        ));
        if (s == 0) {
          if (element['Status'] == "Debit") {
            balance.add(element["Amount"]);
          } else {
            balance.add(-element["Amount"]);
          }
        } else {
          if (element['Status'] == "Debit") {
            balance.add(element["Amount"] + balance[s - 1]);
          } else {
            balance.add(-element["Amount"] + balance[s - 1]);
          }
        }
        s++;
      });
    });
    setState(() {
      foundLendingPayments = allLendingPayments;
    });
  }

  @override
  void initState() {
    _fetchDatas();
    listScrollController = ScrollController();
    super.initState();
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

    Future<List<LendingPayment>> getCust() async {
      List<LendingPayment> LendingPayments = [];
      _totalcreitamount = 0;
      _totaldebitamount = 0;
      for (int ss = 0; ss < foundLendingPayments.length; ss++) {
        LendingPayments.add(foundLendingPayments[ss]);
        if (foundLendingPayments[ss].status == "Debit") {
          _totaldebitamount = _totaldebitamount + foundLendingPayments[ss].amount;
        } else {
          _totalcreitamount = _totalcreitamount + foundLendingPayments[ss].amount;
        }
      }
      return LendingPayments;
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
                      margin: const EdgeInsets.only(left: 30, top: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            text: "Persons Ledger",
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
                          const Expanded(
                              child: SizedBox(
                            height: 1,
                          )),
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
                                        .format(startDate)
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
                                        .format(endDate)
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
                                text: "Select Lending Person",
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
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                            fontSize: 16, color: Colors.black),
                                      ),
                                    ),
                                    fit: FlexFit.loose,
                                    showSelectedItems: false,
                                    menuProps: const MenuProps(
                                      backgroundColor: Colors.white,
                                      elevation: 100,
                                    ),
                                    searchFieldProps: const TextFieldProps(
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
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                      ),
                                    ),
                                  ),
                                  dropdownBuilder: (context, selectedItem) {
                                    return Text(
                                      selectedItem ?? "Select Lending Person",
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    );
                                  },
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedLendingPaymentid = lendingPayment[
                                          sLendingPayment.indexOf(newValue!)];
                                      _selectedLendingPayment =
                                          newValue.toString();
                                    });
                                  },
                                  items: sLendingPayment,
                                  selectedItem: _selectedLendingPayment,
                                )),
                          ),
                          const Expanded(
                            child: SizedBox(
                              height: 1,
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  _fetchDocuments(startDate, endDate);
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
                    const SizedBox(
                      height: 20,
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
                                            _nametop = false;
                                            _namebot = false;
                                            _datetop = false;
                                            _datebot = false;
                                            allLendingPayments.sort(
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
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Lending Person Name",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
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
                                              if (!_nametop) {
                                                _nametop = true;
                                                _namebot = false;
                                                allLendingPayments.sort((a, b) =>
                                                    a.lendingpersonname.compareTo(
                                                        b.lendingpersonname));
                                              } else {
                                                _nametop = false;
                                                _namebot = true;
                                                allLendingPayments.sort((b, a) =>
                                                    a.lendingpersonname.compareTo(
                                                        b.lendingpersonname));
                                              }
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                                child: Icon(
                                                  Icons.arrow_drop_up,
                                                  color: _nametop
                                                      ? Colors.black
                                                      : Colors.black45,
                                                ),
                                              ),
                                              Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0, -8.0, 0.0),
                                                child: Icon(
                                                  Icons.arrow_drop_down,
                                                  color: _namebot
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
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Date",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
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
                                                allLendingPayments.sort((a, b) =>
                                                    a.date.compareTo(b.date));
                                              } else {
                                                _datetop = false;
                                                _datebot = true;
                                                allLendingPayments.sort((b, a) =>
                                                    a.date.compareTo(b.date));
                                              }
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                transform:
                                                    Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                                child: Icon(
                                                  Icons.arrow_drop_up,
                                                  color: _datetop
                                                      ? Colors.black
                                                      : Colors.black45,
                                                ),
                                              ),
                                              Container(
                                                transform:
                                                    Matrix4.translationValues(
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
                                  Text("|"),
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Remarks",
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
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Debit",
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
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Credit",
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
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Balance",
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
                              height: _height / 2,
                              child: FutureBuilder(
                                builder: (ctx, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                            "Select Dates And Person To Generate Lending Ledger.."),
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
                                            return LendingPaymentListItem(
                                              index: index,
                                              cst: snapshot.data[index],
                                              click: _click[index],
                                              changeVal: changeVal,
                                              balance: balance[index],
                                              editLendingPayment:
                                                  _onEditLendingPayment,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  }
                                  return const Center(
                                    child: Text(
                                        "Select Dates And LendingPayment Category.."),
                                  );
                                },
                                future: getCust(),
                              ),
                            ),
                            _width > 600
                                ? Container(
                                    color: Colors.grey.shade200,
                                    padding: EdgeInsets.only(
                                        left: 65, right: 15, top: 5, bottom: 5),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                            flex: 9, child: Text(" ")),
                                        Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                Container(
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
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 7),
                                                  child: Text(
                                                    _totaldebitamount
                                                        .toString(),
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
                                              ],
                                            )),
                                        Expanded(
                                            flex: 2,
                                            child: Row(
                                              children: [
                                                Container(
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
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 7),
                                                  child: Text(
                                                    _totalcreitamount
                                                        .toString(),
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
                                              ],
                                            )),
                                        Expanded(
                                          flex: 2,
                                          child: Container(),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
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
