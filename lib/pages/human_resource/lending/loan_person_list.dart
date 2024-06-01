import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../constants/style.dart';
import '../../../model/LendingPerson.dart';
import '../../../widgets/custom_text.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../widgets/lendingperson_list_item.dart';

class LendingPersonList extends StatefulWidget {
  
  
  Navbools nn;
  LendingPersonList(
      {super.key,
      
      required this.nn,
      });
  @override
  State<LendingPersonList> createState() => _LendingPersonListState();
}

class _LendingPersonListState extends State<LendingPersonList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false, _nametop = false, _namebot = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<LendingPerson> allLperson = [];
  List<LendingPerson> foundLperson = [];
  TextEditingController search_benefit = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_lending = true;
      widget.nn.human_resource_lendingpersonlist= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    allLperson = [];
    int s = 0;
    await FirebaseFirestore.instance
        .collection('LendingPerson')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allLperson.add(LendingPerson(
            name: element["Name"],
            phone: element["Phone"],
            phone2: element["Phone2"],user: element['User'],
            address: element["Address"],
            uid: element["UID"],
            nid: element["NID"],
            sl: s,
            reference: element["Reference"]));
        s++;
      });
    });
    foundLperson = allLperson;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundLperson.length; i += _items) {
      chunks.add(foundLperson.sublist(i,
          i + _items > foundLperson.length ? foundLperson.length : i + _items));
    }
    setState(() {
      _totalpagenum = (foundLperson.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<LendingPerson> results = [];
    print(enteredKeyword);
    if (enteredKeyword.isEmpty) {
      results = allLperson;
    } else {
      results = allLperson
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundLperson = results;
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

    Future<List<LendingPerson>> getCust() async {
      List<LendingPerson> units = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        units.add(chunks[_currentpagenum - 1][ss]);
      }
      return units;
    }

 

    void _onEditLendingPerson(LendingPerson cst) {
      // Navigator.of(context).pushNamed(
      //   editcustomerPageRoute,
      //   arguments: {
      //     'Customer': jsonEncode(cst),
      //   },
      // );
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
                      children: [
                        CustomText(
                          text: "Lending Persons List",
                          size: 30,
                          weight: FontWeight.bold,
                        ),
                        const Expanded(
                            child: SizedBox(
                          height: 1,
                        )),
                        Container(
                          width: _width / 7,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: TextField(
                            controller: search_benefit,
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
                        SizedBox(
                          height: 1,
                          width: _width / 25,
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
                                          allLperson.sort(
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
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 6),
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
                                              allLperson.sort((a, b) =>
                                                  a.name.compareTo(b.name));
                                              makechunks();
                                            } else {
                                              _nametop = false;
                                              _namebot = true;
                                              allLperson.sort((b, a) =>
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
                                  flex: 6,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Address",
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
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Phone",
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
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "National ID",
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
                                    margin: EdgeInsets.only(left: 5),
                                    child: Text(
                                      "Reference",
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
                                    margin: EdgeInsets.only(left: 5),
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
                                      child: Text("No Lending Person Data Available.."),
                                    );
                                  } else if (snapshot.hasData) {
                                    return MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          _click.add(false);
                                          return LendingPersonListItem(
                                            index: index,
                                            click: _click[index],
                                            onEditLendingPerson: _onEditLendingPerson,
                                            changeVal: changeVal,
                                            cst: snapshot.data[index],
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
