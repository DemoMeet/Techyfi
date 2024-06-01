import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/pages/customers/widgets/customer_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../api/pdf_customer.dart';
import '../../constants/style.dart';
import '../../api/csv_customer.dart';
import '../../model/customer.dart';
import '../../routing/routes.dart';
import '../../helpers/screen_size_controller.dart';
import '../../widgets/custom_text.dart';
import 'edit_customer.dart';
import '../../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class CustomerList extends StatefulWidget {
  Navbools nn;
  CustomerList({
    super.key,
    required this.nn,
  });
  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
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
      _citytop = false,
      _citydown = false,
      _baltop = false,
      _baldown = false,
      _namebool = true,
      _phonbool = false,
      _addbool = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Customer> allcustomers = [];
  List<Customer> foundcustomers = [];
  final TextEditingController _searchcustomer = TextEditingController();

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.customer = true;
      widget.nn.customer_list = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    int s = 0;
    allcustomers = [];
    foundcustomers = [];
    await FirebaseFirestore.instance
        .collection('Customer')
        .get()
        .then((querySnapshot) {
      for (var element in querySnapshot.docs) {
        allcustomers.add(Customer(
            address: element["Address"],
            balance: element["Balance"],
            city: element["City"],
            email: element["Email"],
            user: element["User"],
            id: element.id,
            name: element["Name"],
            phone1: element["Phone"],
            phone2: element["Phone2"],
            zip: element['Zip Code'],
            sl: s));

        s++;
      }
    });
    foundcustomers = allcustomers;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundcustomers.length; i += _items) {
      chunks.add(foundcustomers.sublist(
          i,
          i + _items > foundcustomers.length
              ? foundcustomers.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundcustomers.length / _items).floor() + 1;
    });
  }

  void _refreshdata() {
    _click = [];
    allcustomers = [];
    foundcustomers = [];
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
    List<Customer> results = [];
    if (enteredKeyword.isEmpty) {
      results = allcustomers;
    } else {
      if (_phonbool) {
        results = allcustomers
            .where((user) => user.phone1
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
      } else if (_namebool) {
        results = allcustomers
            .where((user) =>
                user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
            .toList();
      } else if (_addbool) {
        results = allcustomers
            .where((user) => user.address
                .toLowerCase()
                .contains(enteredKeyword.toLowerCase()))
            .toList();
      }
    }
    setState(() {
      foundcustomers = results;
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

    Future<List<Customer>> getCust() async {
      List<Customer> customers = [];
      _totalamount = 0;
      if (chunks.isNotEmpty) {
        for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
          customers.add(chunks[_currentpagenum - 1][ss]);
          _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].balance;
        }
      }

      return customers;
    }

    List<Customer> getlist() {
      List<Customer> customers = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        customers.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].balance;
      }
      return customers;
    }

    void _onEditCustomer(Customer cst) async {
      var result = await Get.toNamed(
        editcustomerPageRoute,
        arguments: {
          'Customer': jsonEncode(cst),
        },
      );
      if (result == 'update') {
        _fetchDocuments();
      }
    }

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
                                  text: "Customer List",
                                  size: 22,
                                  weight: FontWeight.bold,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10, top: 5),
                                  child: InkWell(
                                    onTap: () {
                                      CsvCustomer.generateAndDownloadCsv(
                                          getlist(), 'Customer_List.csv');
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
                                      PdfCustomer.generate(
                                          getlist(), _totalamount);
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
                                  top: 7, bottom: 7, right: _width / 25),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  TextField(
                                    focusNode: myFocusNode,
                                    controller: _searchcustomer,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      prefixIcon: Icon(Icons.search),
                                      hintText: dropdownvalue,
                                      fillColor: Colors.white,
                                      filled: true,
                                    ),
                                    onChanged: (value) => _runFilter(value),
                                  ),
                                  DropdownButton<String>(
                                    isExpanded: true,
                                    underline: SizedBox(),
                                    items: <String>[
                                      'Search By Name',
                                      'Search By Phone',
                                      'Search By Address'
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        if (newValue == "Search By Name") {
                                          dropdownvalue = "Search Name";
                                          _namebool = true;
                                          _phonbool = false;
                                          _addbool = false;
                                        } else if (newValue ==
                                            "Search By Phone") {
                                          dropdownvalue = "Search Phone";
                                          _namebool = false;
                                          _phonbool = true;
                                          _addbool = false;
                                        } else {
                                          dropdownvalue = "Search Address";
                                          _namebool = false;
                                          _phonbool = false;
                                          _addbool = true;
                                        }
                                        myFocusNode.requestFocus();
                                      });
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          //color: Colors.blue,
                          height: _height / 1.27,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.grey.shade200,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _citytop = false;
                                              _citydown = false;
                                              _baldown = false;
                                              _baltop = false;
                                              _nametop = false;
                                              _namebot = false;
                                              allcustomers.sort((a, b) =>
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
                                      flex: 3,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Name",
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
                                                  _citytop = false;
                                                  _citydown = false;
                                                  _baldown = false;
                                                  _baltop = false;
                                                  _nametop = true;
                                                  _namebot = false;
                                                  allcustomers.sort((a, b) =>
                                                      a.name.compareTo(b.name));
                                                  makechunks();
                                                } else {
                                                  _citytop = false;
                                                  _citydown = false;
                                                  _baldown = false;
                                                  _baltop = false;
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allcustomers.sort((b, a) =>
                                                      a.name.compareTo(b.name));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _nametop
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
                                                    color: _namebot
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
                                      flex: 7,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "ADDRESS",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 9,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "EMAIL",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 10,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "MOBILE 1",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 8,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "MOBILE 2",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 8,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "CITY",
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
                                                if (!_citytop) {
                                                  _citytop = true;
                                                  _citydown = false;
                                                  _baldown = false;
                                                  _baltop = false;
                                                  _nametop = false;
                                                  _namebot = false;
                                                  allcustomers.sort((a, b) =>
                                                      a.city.compareTo(b.city));
                                                  makechunks();
                                                } else {
                                                  _citytop = false;
                                                  _citydown = true;
                                                  _baldown = false;
                                                  _baltop = false;
                                                  _nametop = false;
                                                  _namebot = false;
                                                  allcustomers.sort((b, a) =>
                                                      a.city.compareTo(b.city));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _citytop
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
                                                    color: _citydown
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
                                      flex: 6,
                                    ),
                                    Text("|"),
                                    Expanded(
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
                                                  _citytop = false;
                                                  _citydown = false;
                                                  _baldown = false;
                                                  _baltop = true;
                                                  _nametop = false;
                                                  _namebot = false;
                                                  allcustomers.sort((a, b) => a
                                                      .balance
                                                      .compareTo(b.balance));
                                                  makechunks();
                                                } else {
                                                  _citytop = false;
                                                  _citydown = false;
                                                  _baldown = true;
                                                  _baltop = false;
                                                  _nametop = false;
                                                  _namebot = false;
                                                  allcustomers.sort((b, a) => a
                                                      .balance
                                                      .compareTo(b.balance));
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
                                      flex: 6,
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
                              Expanded(
                                child: FutureBuilder(
                                  builder: (ctx, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text(
                                              "No Customer Data Available.."),
                                        );
                                      } else if (snapshot.hasData) {
                                        return MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              _click.add(false);
                                              return CustomerListItem(
                                                index: index,
                                                cst: snapshot.data[index],
                                                click: _click[index],
                                                changeVal: changeVal,
                                                fetchDocuments: _fetchDocuments,
                                                onEditCustomer: _onEditCustomer,
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
                                            flex: 42,
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.transparent,
                                                  ),
                                                  child: DropdownButton<int>(
                                                    value: _items,
                                                    icon: const Icon(Icons
                                                        .keyboard_arrow_down),
                                                    items:
                                                        items.map((int items) {
                                                      return DropdownMenuItem(
                                                        value: items,
                                                        child: CustomText(
                                                          text:
                                                              items.toString(),
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
                                                        _currentpagenum =
                                                            index + 1;
                                                        _click = [];
                                                      });
                                                    },
                                                  ),
                                                )
                                              : SizedBox(),
                                          const Expanded(
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
