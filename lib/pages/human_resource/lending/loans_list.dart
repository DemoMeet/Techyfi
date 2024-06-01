import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/Accounts.dart';
import '../../../model/Lending.dart';
import '../../../widgets/custom_text.dart';
import '../widgets/Lending_list_item.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';

class LendingList extends StatefulWidget {
  
  
  Navbools nn;
  LendingList(
      {super.key,
      
      required this.nn,
      });
  @override
  State<LendingList> createState() => _LendingListState();
}

class _LendingListState extends State<LendingList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  double _totalamount = 0, _totalreturnedamount = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  var selectedaccount, selectedpayment;
  var selectedAccountid;
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var payment = ["Bank Payment", "Cash Payment"];
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false,
      _nametop = false,
      _namebot = false,
      _datetop = false,
      _datebot = false,
      _date1top = false,
      _date1bot = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Lending> allLendings = [];
  List<Lending> foundLendings = [];
  TextEditingController search_Lending = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_lending = true;
      widget.nn.human_resource_lendinglist= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _onEditLending(Lending cst) {
    // Navigator.of(context).pushNamed(
    //   editSalaryPageRoute,
    //   arguments: {
    //     'Salary': jsonEncode(cst),
    //   },
    // );
  }
  void _fetchDocuments() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Lending')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allLendings.add(Lending(
            name: element["Lending Person Name"],
            phone: element["Lending Person Phone"],
            lendingpersonid: element["Lending Person ID"],
            status: element["Status"],
            uid: element["UID"],
            user: element['User'],
            remarks: element["Remarks"],
            sl: s,
            amount: element["Amount"],
            returnedamount: element["Returned Amount"],
            date: element["Date"],
            returndate: element["Return Date"],
            lendingperson: element["Lending Person"],
            from: element["From"]));
        s++;
      });
    });
    foundLendings = allLendings;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundLendings.length; i += _items) {
      chunks.add(foundLendings.sublist(
          i, i + _items > foundLendings.length ? foundLendings.length : i + _items));
    }
    setState(() {
      _totalpagenum = (foundLendings.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    _fetchData();
    listScrollController = ScrollController();
    super.initState();
  }

  void _fetchData() async {
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
                user: element['User'],
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
    });
  }

  void _runFilter(String enteredKeyword) {
    List<Lending> results = [];
    print(enteredKeyword);
    if (enteredKeyword.isEmpty) {
      results = allLendings;
    } else {
      results = allLendings
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundLendings = results;
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
      List<Lending> results = [];
      for (int i = 0; i < allLendings.length; i++) {
        if ((allLendings[i].date.toDate().compareTo(startDate) >= 0 &&
                allLendings[i].date.toDate().compareTo(endDate) <= 0) ||
            (allLendings[i].date.toDate().difference(startDate).inDays == 1 ||
                allLendings[i].date.toDate().difference(endDate).inDays == 1)) {
          results.add(allLendings[i]);
        } else if (startDate.difference(endDate).inDays == 0) {
          if (allLendings[i].date.toDate().compareTo(startDate) == 1) {
            results.add(allLendings[i]);
          }
        }
      }
      foundLendings = [];
      setState(() {
        foundLendings = results;
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

    Future<List<Lending>> getCust() async {
      List<Lending> Lendings = [];
      _totalamount = 0;
      _totalreturnedamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Lendings.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].amount;
        _totalreturnedamount = _totalreturnedamount +
            chunks[_currentpagenum - 1][ss].returnedamount;
      }
      return Lendings;
    }

    double width = 1200;

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
                      margin: const EdgeInsets.only(
                        left: 30,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CustomText(
                                text: "Lending List",
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
                              controller: search_Lending,
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
                                            _nametop = false;
                                            _namebot = false;
                                            _datetop = false;
                                            _datebot = false;
                                            _date1top = false;
                                            _date1bot = false;
                                            allLendings.sort(
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
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Lending Name",
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
                                                _datetop = false;
                                                _datebot = false;
                                                _date1top = false;
                                                _date1bot = false;
                                                allLendings.sort((a, b) =>
                                                    a.name.compareTo(b.name));
                                                makechunks();
                                              } else {
                                                _nametop = false;
                                                _namebot = true;
                                                _datetop = false;
                                                _datebot = false;
                                                _date1top = false;
                                                _date1bot = false;
                                                allLendings.sort((b, a) =>
                                                    a.name.compareTo(b.name));
                                                makechunks();
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
                                                _date1top = false;
                                                _date1bot = false;
                                                _nametop = false;
                                                _namebot = false;
                                                allLendings.sort((a, b) =>
                                                    a.date.compareTo(b.date));
                                                makechunks();
                                              } else {
                                                _datetop = false;
                                                _datebot = true;
                                                _nametop = false;
                                                _namebot = false;
                                                _date1top = false;
                                                _date1bot = false;
                                                allLendings.sort((b, a) =>
                                                    a.date.compareTo(b.date));
                                                makechunks();
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
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Return Date",
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
                                              if (!_date1top) {
                                                _date1top = true;
                                                _date1bot = false;
                                                _datetop = false;
                                                _datebot = false;
                                                _nametop = false;
                                                _namebot = false;
                                                allLendings.sort((a, b) => a
                                                    .returndate
                                                    .compareTo(b.returndate));
                                                makechunks();
                                              } else {
                                                _date1top = false;
                                                _date1bot = true;
                                                _datetop = false;
                                                _datebot = false;
                                                _nametop = false;
                                                _namebot = false;
                                                allLendings.sort((b, a) => a
                                                    .returndate
                                                    .compareTo(b.returndate));
                                                makechunks();
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
                                    flex: 2,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "From",
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
                                        "Amount",
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
                                        "Returned Amount",
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
                                    flex: 1,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Status",
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
                                      margin: const EdgeInsets.only(
                                          left: 7, right: 7),
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
                              height: _height / 1.60,
                              child: FutureBuilder(
                                builder: (ctx, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text(
                                            "No Lending Data Available.."),
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
                                            return LendingListItem(
                                              index: index,
                                              bankaccounts: _bankaccounts,
                                              cashaccounts: _cashaccounts,
                                              sbankaccounts: sbankaccounts,
                                              scashaccounts: scashaccounts,
                                              nn: widget.nn,
                                              selectedaccount: selectedaccount,
                                              selectedpayment: selectedpayment,
                                              selectedAccountid:
                                                  selectedAccountid,
                                              cst: snapshot.data[index],
                                              click: _click[index],
                                              changeVal: changeVal,
                                              editLending: _onEditLending,
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
                                        left: 15, right: 15, top: 5, bottom: 5),
                                    child: Row(
                                      children: [
                                        Expanded(child: SizedBox()),
                                        Expanded(child: SizedBox()),
                                        Expanded(child: SizedBox()),
                                        Expanded(child: SizedBox()),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              "Total Amount : ",
                                              textAlign: TextAlign.right,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20),
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
                                        Text("|"),
                                        Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Total Returned Amount : ",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Text(
                                            _totalreturnedamount.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                        Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                            _width > 600
                                ? Row(
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
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
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
                                                onChanged: (int? newValue) {
                                                  setState(() {
                                                    _items = newValue!;
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
                                      _height > 610
                                          ? Container(
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
                                            )
                                          : SizedBox(),
                                      Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 15,
                                      ),
                                    ],
                                  )
                                : SizedBox(),
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
