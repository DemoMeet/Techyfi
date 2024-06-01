import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/general.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/general_list_item_with_details.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';



class DesignationList extends StatefulWidget {

  
  
  Navbools nn;
  DesignationList(
      {super.key,
        
        required this.nn,
        });


  @override
  State<DesignationList> createState() => _DesignationListState();
}

class _DesignationListState extends State<DesignationList> {
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
  List<General> allDesignation = [];
  List<General> foundDesignation = [];
  TextEditingController search_Designation = TextEditingController();



  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_employee = true;
      widget.nn.hr_employee_add_designation= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    allDesignation = [];
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Designation')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allDesignation.add(General.withDetails(
            element["Name"],
            element["Details"],
            element["status"]?"Active":"Deactivate",element.id,
            s));
        s++;
      });
    });
    foundDesignation = allDesignation;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundDesignation.length; i += _items) {
      chunks.add(foundDesignation.sublist(
          i, i + _items > foundDesignation.length ? foundDesignation.length : i + _items));
    }
    setState(() {
      _totalpagenum = (foundDesignation.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<General> results = [];
    print(enteredKeyword);
    if (enteredKeyword.isEmpty) {
      results = allDesignation;
    } else {

      results = allDesignation
          .where((user) =>
          user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();

    }
    setState(() {
      foundDesignation = results;
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

    Future<List<General>> getCust() async {
      List<General> units = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        units.add(chunks[_currentpagenum - 1][ss]);
      }
      return units;
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
                          left: 30,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                              text: "Designation List",
                              size: 30,
                              weight: FontWeight.bold,
                            ),

                            Expanded(
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
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: search_Designation,
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
                                              allDesignation.sort((a, b) => a.sl.compareTo(b.sl));
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
                                            margin: EdgeInsets.only(left: 25),
                                            child: Text(
                                              "Name",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
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
                                                if(!_nametop){
                                                  _nametop = true;
                                                  _namebot = false;
                                                  allDesignation.sort((a, b) => a.name.compareTo(b.name));
                                                  makechunks();
                                                }else{
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allDesignation.sort((b, a) => a.name.compareTo(b.name));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _nametop?Colors.black:Colors.black45,
                                                  ),
                                                  transform: Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                                ),
                                                Container(
                                                  child: Icon(Icons.arrow_drop_down,
                                                    color: _namebot?Colors.black:Colors.black45,),
                                                  transform: Matrix4.translationValues(
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
                                      flex: 8,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 25),
                                        child: Text(
                                          "Details",
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
                                        margin: EdgeInsets.only(left: 25),
                                        child: Text(
                                          "Status",
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
                                        margin: EdgeInsets.only(left: 30),
                                        child: Text(
                                          "ACTION",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: _height / 1.60,
                                child: FutureBuilder(
                                  builder: (ctx,AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text("No Designation Data Available.."),
                                        );
                                      } else if (snapshot.hasData) {
                                        return MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: ListView.builder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              _click.add(false);
                                              return
                                                GeneralListItemWithDetails(
                                                  index: index,
                                                  sl: snapshot.data[index].sl.toString(),
                                                  name: snapshot.data[index].name,
                                                  details: snapshot.data[index].details,
                                                  status: snapshot.data[index].status,
                                                  click: _click[index],
                                                  changeVal: changeVal,
                                                  parent: 'Designation', id: snapshot.data[index].id,fetchDocuments: _fetchDocuments,);
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
