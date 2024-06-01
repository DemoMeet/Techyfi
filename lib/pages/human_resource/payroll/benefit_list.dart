import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/widgets/general_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../constants/style.dart';
import '../../../model/general.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/general_list_item_with_details.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
class BenefitList extends StatefulWidget {
  
  
  Navbools nn;
  BenefitList(
      {super.key,
        
        required this.nn,
        });
  @override
  State<BenefitList> createState() => _BenefitListState();
}

class _BenefitListState extends State<BenefitList> {
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
  List<General> allbenefit = [];
  List<General> foundbenefit = [];
  TextEditingController search_benefit = TextEditingController();

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_payroll = true;
      widget.nn.hr_payroll_benefit_list= true;
      controller.onChange(false);
      _first = true;
    }
  }


  void _fetchDocuments() async {
    allbenefit = [];
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Benefit')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allbenefit.add(General.withDetails(
            element["Benefit Name"],
            element["Benefit Type"],
            element["status"] ? "Active" : "Deactivate",
            element.id,
            s));

        s++;
      });
    });
    foundbenefit = allbenefit;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundbenefit.length; i += _items) {
      chunks.add(foundbenefit.sublist(i,
          i + _items > foundbenefit.length ? foundbenefit.length : i + _items));
    }
    setState(() {
      _totalpagenum = (foundbenefit.length / _items).floor() + 1;
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
      results = allbenefit;
    } else {
      results = allbenefit
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundbenefit = results;
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
                        margin: const EdgeInsets.only(
                          left: 30,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CustomText(
                              text: "Benefit List",
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
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: search_benefit,
                                decoration: const InputDecoration(
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
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _nametop = false;
                                              _namebot = false;
                                              allbenefit
                                                  .sort((a, b) => a.sl.compareTo(b.sl));
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
                                              "Benefit Name",
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
                                                  allbenefit.sort(
                                                          (a, b) => a.name.compareTo(b.name));
                                                  makechunks();
                                                } else {
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allbenefit.sort(
                                                          (b, a) => a.name.compareTo(b.name));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  transform: Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _nametop
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                ),
                                                Container(
                                                  transform: Matrix4.translationValues(
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
                                      flex: 8,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 25),
                                        child: Text(
                                          "Benefit Type",
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
                                        margin: EdgeInsets.only(left: 30),
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
                                          child: Text(
                                              "No Benefit Data Available.."),
                                        );
                                      } else if (snapshot.hasData) {
                                        return MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: ListView.builder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              _click.add(false);
                                              return GeneralListItemWithDetails(
                                                index: index,
                                                details: snapshot.data[index].details,
                                                sl: snapshot.data[index].sl.toString(),
                                                name: snapshot.data[index].name,
                                                status: snapshot.data[index].status,
                                                click: _click[index],
                                                changeVal: changeVal,
                                                parent: 'benefit',
                                                id: snapshot.data[index].id,
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

                                //
                                // StreamBuilder(
                                //   stream: customer.snapshots(),
                                //   builder: (context, snapshot) {
                                //     if (snapshot.hasError) {
                                //       return Text('Something went wrong');
                                //     }
                                //     if (snapshot.connectionState ==
                                //         ConnectionState.waiting) {
                                //       return Text("Loading");
                                //     }
                                //     return MediaQuery.removePadding(
                                //       context: context,
                                //       removeTop: true,
                                //       child: ListView.builder(
                                //         controller: listScrollController,
                                //         itemCount: snapshot.data.docs.length,
                                //         itemBuilder: (context, index) {
                                //           _click.add(false);
                                //           return CustomerListItem(
                                //                 sl: index + 1,
                                //                 name: snapshot.data.docs[index]['Name'],
                                //                 address: snapshot.data.docs[index]['Address'],
                                //                 email: snapshot.data.docs[index]['Email'],
                                //                 phone1: snapshot.data.docs[index]['Phone'],
                                //                 phone2: snapshot.data.docs[index]['Phone2'],
                                //                 city: snapshot.data.docs[index]['City'],
                                //                 balance: snapshot.data.docs[index]
                                //                     ['Previous Balance'],click: _click[index], changeVal: changeVal);
                                //         },
                                //       ),
                                //     );
                                //   },
                                // ),
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
