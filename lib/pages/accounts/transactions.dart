import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/api/csv_transaction.dart';
import 'package:groceyfi02/pages/accounts/widgets/transaction_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../api/pdf_transaction.dart';
import '../../constants/style.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../model/Accounts.dart';
import '../../model/Transaction.dart';
import '../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

import '../../widgets/custom_text.dart';

class Transactionsss extends StatefulWidget {
  
  
  Navbools nn;
  Transactionsss(
      { required this.nn});

  @override
  State<Transactionsss> createState() => _TransactionsssState();
}

class _TransactionsssState extends State<Transactionsss> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  late FocusNode myFocusNode;
  String dropdownvalue = 'Search By Name';
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false,
      _nametop = false,
      _namebot = false,
      _baltop = false,
      _baldown = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Transactionss> allTransactionss = [];
  List<Transactionss> foundTransactionsss = [];
  TextEditingController search_Transactionss = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.account = true;
      widget.nn.transactions = true;
      controller.onChange(false);
      _first = true;
    }
  }


  void _refreshdata() {
    _click = [];
    allTransactionss = [];
    foundTransactionsss = [];
    _fetchDocuments();
  }

  void _fetchDocuments() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Transaction').orderBy("Submit Date", descending: true)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        allTransactionss.add(Transactionss(name: element["Name"],user: element['User'],type:  element["Type"], id2: element["2nd ID"], remarks: element["Remarks"], paymentmethod: element["Payment Method"], id1: element["ID"], accountid: element["Account ID"], date: element["Date"], submitdate: element["Submit Date"], account: element["Account Details"], amount: element["Amount"], sl: s));
        s++;
      });
    });
    foundTransactionsss = allTransactionss;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundTransactionsss.length; i += _items) {
      chunks.add(foundTransactionsss.sublist(
          i,
          i + _items > foundTransactionsss.length
              ? foundTransactionsss.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundTransactionsss.length / _items).floor() + 1;
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
    List<Transactionss> results = [];
    if (enteredKeyword.isEmpty) {
      results = allTransactionss;
    } else {
      results = allTransactionss
          .where((user) => user.name
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundTransactionsss = results;
    });
    makechunks();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });


    Future<List<Transactionss>> getCust() async {
      List<Transactionss> Transactionsss = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Transactionsss.add(chunks[_currentpagenum - 1][ss]);
      }
      return Transactionsss;
    }



    List<Transactionss> getlist() {
      List<Transactionss> customers = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        customers.add(chunks[_currentpagenum - 1][ss]);
      }
      return customers;
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        
        appBar:MyAppBar(height: _height,width:  _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn,),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: _height / 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      left: _width / 45.6,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomText(
                              text: "Transactions",
                              size: 22,
                              weight: FontWeight.bold,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              child: InkWell(
                                onTap: () {
                                  CsvTransaction.generateAndDownloadCsv(
                                      getlist(), 'Transaction_List.csv');
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
                                  PdfTransaction.generate(getlist());
                                },
                                child: Image.asset(
                                  "assets/icons/download_pdf.png",
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: _width / 5,
                          margin: EdgeInsets.only(
                              top: 10, bottom: 10, right: _width / 25),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextField(
                            focusNode: myFocusNode,
                            controller: search_Transactionss,
                            decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              prefixIcon: Icon(Icons.search),
                              hintText: dropdownvalue,
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
                                          _baldown = false;
                                          _baltop = false;
                                          _nametop = false;
                                          _namebot = false;
                                          allTransactionss.sort(
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
                                const Text("|"),
                                Expanded(
                                  flex: 6,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Bank Name/Cash Name",
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
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Bearer",
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
                                            if (!_nametop) {
                                              _baldown = false;
                                              _baltop = false;
                                              _nametop = true;
                                              _namebot = false;
                                              allTransactionss.sort((a, b) => a
                                                  .name
                                                  .compareTo(b.name));
                                              makechunks();
                                            } else {
                                              _baldown = false;
                                              _baltop = false;
                                              _nametop = false;
                                              _namebot = true;
                                              allTransactionss.sort((b, a) => a
                                                  .name
                                                  .compareTo(b.name));
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
                                const Text("|"),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Type",
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
                                  flex: 4,
                                  child: Container(
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
                                ),
                                const Text("|"),
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: const EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Amount",
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
                                            if (!_baltop) {
                                              _baldown = false;
                                              _baltop = true;
                                              _nametop = false;
                                              _namebot = false;
                                              allTransactionss.sort((a, b) =>
                                                  a.amount.compareTo(b.amount));
                                              makechunks();
                                            } else {
                                              _baldown = true;
                                              _baltop = false;
                                              _nametop = false;
                                              _namebot = false;
                                              allTransactionss.sort((b, a) =>
                                                  a.amount.compareTo(b.amount));
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
                                                color: _baltop
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
                                                color: _baldown
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
                                  flex:4,
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
                          SizedBox(
                            height: _height / 1.60,
                            child: FutureBuilder(
                              builder: (ctx, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    return const Center(
                                      child: Text("No Transaction Data Available.."),
                                    );
                                  } else if (snapshot.hasData) {
                                    return MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        // physics: NeverScrollableScrollPhysics(),
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          return TransactionListItem(
                                            index: index,
                                            cst: snapshot.data[index],
                                            fetchDocuments: _fetchDocuments,
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
                                      Expanded(
                                        child: SizedBox(
                                          height: 1,
                                        ),
                                        flex: 15,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        )));
  }
}
