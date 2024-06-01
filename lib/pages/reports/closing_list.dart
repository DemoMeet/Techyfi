import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/pages/reports/widget/closing_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/Closing.dart';
import '../../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../../model/Closing.dart';
import '../../model/Closing.dart';

class ClosingList extends StatefulWidget {
  
  
  Navbools nn;
  ClosingList(
      {super.key,
      
      required this.nn,
      });
  @override
  State<ClosingList> createState() => _ClosingListState();
}

class _ClosingListState extends State<ClosingList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  double _totalamount = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  TextEditingController search_closing = TextEditingController();
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false,
      _nametop = false,
      _namebot = false,
      _datetop = false,
      _datebot = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Closing> allClosing = [];
  List<Closing> foundClosing = [];
  TextEditingController search_Closing = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.report = true;
      widget.nn.report_closing_list = true;
      controller.onChange(false);
      _first = true;
    }
  }


  void _onEditClosing(Closing cst) {
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
        .collection('Closing')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allClosing.add(Closing(
            lastclosingamount: element["Last Closing Amount"],
            lastclosingdate: element["Last Closing Date"].toDate(),
            received: element["Received"],
            payment: element["Payment"],
            id: element["id"],
            balance: element["Balance"],user: element['User'],
            sl: s,
            remarks: element["Remarks"],
            date: element["Date"].toDate()));
        s++;
      });
    });
    foundClosing = allClosing;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundClosing.length; i += _items) {
      chunks.add(foundClosing.sublist(i,
          i + _items > foundClosing.length ? foundClosing.length : i + _items));
    }
    setState(() {
      _totalpagenum = (foundClosing.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    super.initState();
  }


  void _runFilter(String enteredKeyword) {
    List<Closing> results = [];
    if (enteredKeyword.isEmpty) {
      results = allClosing;
    } else {
      results = allClosing
          .where((user) => user.user
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundClosing = results;
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
      List<Closing> results = [];
      for (int i = 0; i < allClosing.length; i++) {
        if ((allClosing[i].date.compareTo(startDate) >= 0 &&
                allClosing[i].date.compareTo(endDate) <= 0) ||
            (allClosing[i].date.difference(startDate).inDays == 1 ||
                allClosing[i].date.difference(endDate).inDays == 1)) {
          results.add(allClosing[i]);
        } else if (startDate.difference(endDate).inDays == 0) {
          if (allClosing[i].date.compareTo(startDate) == 1) {
            results.add(allClosing[i]);
          }
        }
      }
      foundClosing = [];
      setState(() {
        foundClosing = results;
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

    Future<List<Closing>> getCust() async {
      List<Closing> closing = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        closing.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].balance;
      }
      return closing;
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
                                text: "Closing List",
                                size: 20,
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
                              ),
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
                              controller: search_closing,
                              decoration: InputDecoration(
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
                                            _nametop = false;
                                            _namebot = false;
                                            _datetop = false;
                                            _datebot = false;
                                            allClosing.sort(
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
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(left: 7),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Last Closing Amount",
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
                                            "Last Closing Date",
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
                                                allClosing.sort((a, b) =>
                                                    a.date.compareTo(b.date));
                                                makechunks();
                                              } else {
                                                _datetop = false;
                                                _datebot = true;
                                                allClosing.sort((b, a) =>
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
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Received",
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
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Payment",
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
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.only(left: 7),
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
                                  Text("|"),
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      margin: EdgeInsets.only(left: 7),
                                      child: Text(
                                        "Closed By",
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
                                        "Remarks",
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
                                    if (snapshot.hasError) {return const Center(
                                      child: Text(
                                          "No Closing Data Available.."),
                                    );
                                    } else if (snapshot.hasData) {
                                      return MediaQuery.removePadding(
                                        context: context,
                                        removeTop: true,
                                        child: ListView.builder(
                                          // physics: NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            return ClosingListItem(
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
                            _width > 600
                                ? Container(
                                    color: Colors.grey.shade200,
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
                                        Expanded(
                                          flex: 22,
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
                                          flex: 4,
                                        ),
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
