import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/pages/accounts/widgets/accounts_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../api/csv_account.dart';
import '../../api/pdf_account.dart';
import '../../constants/style.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../model/Accounts.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

import '../../widgets/custom_text.dart';

class AccountsList extends StatefulWidget {
  Navbools nn;
  AccountsList(
      {super.key,  required this.nn});

  @override
  State<AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<AccountsList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  late FocusNode myFocusNode;
  String dropdownvalue = 'Search By Name';
  double _totalamount = 0;
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
  List<Accounts> allAccounts = [];
  List<Accounts> foundAccountss = [];
  TextEditingController search_Accounts = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.account = true;
      widget.nn.account_list = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    _click = [];
    allAccounts = [];
    foundAccountss = [];
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Account')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        allAccounts.add(Accounts(
            uid: element["UID"],
            accountname: element["Account Name"],
            accountnum: element["Account Number"],
            cashdetails: element["Cash Details"],
            cashname: element["Cash Name"],user: element['User'],
            bal: element["Balance"],
            bankname: element["Bank Name"],
            sts: element["Status"],
            bank: element["Bank"],
            branch: element["Branch"],
            sl: s));
        s++;
      });
    });
    foundAccountss = allAccounts;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundAccountss.length; i += _items) {
      chunks.add(foundAccountss.sublist(
          i,
          i + _items > foundAccountss.length
              ? foundAccountss.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundAccountss.length / _items).floor() + 1;
    });
  }


  void _onEditManufact(Accounts cst) async  {
    var result = await Get.toNamed(editaccount,arguments: {
      'Account': jsonEncode(cst),
    },);
    if (result == 'update') {
      _fetchDocuments();
    }
  }
  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    myFocusNode = FocusNode();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<Accounts> results = [];
    if (enteredKeyword.isEmpty) {
      results = allAccounts;
    } else {
      results = allAccounts
          .where((user) => user.bankname
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundAccountss = results;
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

    void changeVal(String i) {
      setState(() {
        _click[val] = false;
        _click[int.parse(i)] = true;
        val = int.parse(i);
      });
    }

    Future<List<Accounts>> getCust() async {
      List<Accounts> Accountss = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Accountss.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].bal;
      }
      return Accountss;
    }

    List<Accounts> getlist() {
      List<Accounts> customers = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        customers.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].bal;
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
                : SideMenuSmall(widget.nn),
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
                              text: "Accounts List",
                              size: 22,
                              weight: FontWeight.bold,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 20, top: 5),
                              child: InkWell(
                                onTap: () {
                                  CsvAccount.generateAndDownloadCsv(
                                      getlist(), 'Account_List.csv');
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
                                  PdfAccount.generate(getlist(), _totalamount);
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
                            controller: search_Accounts,
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
                                  flex: 3,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 30),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _baldown = false;
                                          _baltop = false;
                                          _nametop = false;
                                          _namebot = false;
                                          allAccounts.sort(
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
                                  flex: 7,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Bank Name/Cash Name",
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
                                              allAccounts.sort((a, b) => a
                                                  .bankname
                                                  .compareTo(b.bankname));
                                              makechunks();
                                            } else {
                                              _baldown = false;
                                              _baltop = false;
                                              _nametop = false;
                                              _namebot = true;
                                              allAccounts.sort((b, a) => a
                                                  .bankname
                                                  .compareTo(b.bankname));
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
                                  flex: 7,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Account Name/ Cash Details",
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
                                  flex: 6,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Account Number",
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
                                  flex:5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Branch",
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
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Bank Type",
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
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "BALANCE",
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
                                              allAccounts.sort((a, b) =>
                                                  a.bal.compareTo(b.bal));
                                              makechunks();
                                            } else {
                                              _baldown = true;
                                              _baltop = false;
                                              _nametop = false;
                                              _namebot = false;
                                              allAccounts.sort((b, a) =>
                                                  a.bal.compareTo(b.bal));
                                              makechunks();
                                            }
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            Container(
                                              child: Icon(
                                                Icons.arrow_drop_up,
                                                color: _baltop
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
                                                color: _baldown
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
                                  flex: 6,
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
                                      child: Text("No Account Data Available.."),
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
                                          return AccountsListItem(
                                            index: index,
                                            cst: snapshot.data[index],
                                            click: _click[index],
                                            changeVal: changeVal,
                                            fetchDocuments: _fetchDocuments,
                                            onEditManufact: _onEditManufact,
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
                                  flex: 42,
                                ),
                                Expanded(
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
                                  flex: 6,
                                ),
                                Text(" "),
                                Expanded(
                                  child: Container(),
                                  flex: 4,
                                ),
                              ],
                            ),
                          )
                              : SizedBox(),
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
        ),  ),);
  }
}
