import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../constants/style.dart';
import '../../../model/Attendance.dart';
import '../../../widgets/custom_text.dart';
import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../widgets/attendance_list_item.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';


class AttendanceList extends StatefulWidget {

  
  
  Navbools nn;
  AttendanceList(
      {super.key,
        
        required this.nn,
        });
  @override
  State<AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends State<AttendanceList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false, _nametop = false, _namebot = false, _datetop = false, _datebot = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Attendance> allAttendances = [];
  List<Attendance> foundAttendances = [];
  TextEditingController search_Attendance = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_attendance = true;
      widget.nn.hr_attendance_attendance_list= true;
      controller.onChange(false);
      _first = true;
    }
  }
  void _fetchDocuments() async {
    int s = 0;
    allAttendances = [];
    foundAttendances = [];
    _click = [];
    await FirebaseFirestore.instance
        .collection('Attendance')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allAttendances.add(Attendance(
          name: element["Employee Name"],
          emplid: element["Employee ID"],
          date: element["Date"],
          intime: element["In Time"],user: element['User'],
          outtime: element["Out Time"],
          out: element["Out"],
          worktime: element["Work Time"],
          id: element.id,
          sl: s,
        ));

        s++;
      });
    });
    foundAttendances = allAttendances;
    makechunks();
  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundAttendances.length; i += _items) {
      chunks.add(foundAttendances.sublist(
          i,
          i + _items > foundAttendances.length
              ? foundAttendances.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundAttendances.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<Attendance> results = [];
    print(enteredKeyword);
    if (enteredKeyword.isEmpty) {
      results = allAttendances;
    } else {
      results = allAttendances
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundAttendances = results;
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

    Future<List<Attendance>> getCust() async {
      List<Attendance> Attendances = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Attendances.add(chunks[_currentpagenum - 1][ss]);
      }
      return Attendances;
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
                              text: "Attendance List",
                              size: 30,
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
                            Expanded(
                                child: SizedBox(
                                  height: 1,
                                )),
                            Container(
                              width: _width / 6,
                              margin: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  TextField(
                                    controller: search_Attendance,
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
                                  // InkWell(
                                  //   child: Container(
                                  //     margin: EdgeInsets.only(right: 5),
                                  //     child: Icon(
                                  //       Icons.arrow_drop_down,
                                  //       size: 22,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
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
                                      child: Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _nametop = false;
                                              _namebot = false;
                                              _datetop = false;
                                              _datebot = false;
                                              allAttendances
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
                                      flex: 1,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              "Employee",
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
                                                if (!_nametop) {
                                                  _nametop = true;
                                                  _namebot = false;
                                                  allAttendances.sort(
                                                          (a, b) => a.name.compareTo(b.name));
                                                  makechunks();
                                                } else {
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allAttendances.sort(
                                                          (b, a) => a.name.compareTo(b.name));
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
                                                  transform: Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                                ),
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: _namebot
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                  transform: Matrix4.translationValues(
                                                      0.0, -8.0, 0.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      flex: 4,
                                    ),
                                    Text("|"),
                                    Expanded(
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
                                          Expanded(
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
                                                  allAttendances.sort(
                                                          (a, b) => a.date.compareTo(b.date));
                                                  makechunks();
                                                } else {
                                                  _datetop = false;
                                                  _datebot = true;
                                                  allAttendances.sort(
                                                          (b, a) => a.date.compareTo(b.date));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _datetop
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                  transform: Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                                ),
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: _datebot
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                  transform: Matrix4.translationValues(
                                                      0.0, -8.0, 0.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      flex: 3,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "In Time",
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
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Out Time",
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
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Work Time",
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
                                          child: Text("No Attendance Data Available.."),
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
                                              return AttendanceListItem(
                                                index: index,
                                                sl: snapshot.data[index].sl,
                                                name: snapshot.data[index].name,
                                                outtime: snapshot.data[index].outtime,
                                                intime: snapshot.data[index].intime,
                                                date: snapshot.data[index].date.toDate(),
                                                worktime:  snapshot.data[index].worktime,
                                                emplid: snapshot.data[index].emplid,
                                                out: snapshot.data[index].out,
                                                click: _click[index],
                                                changeVal: changeVal,
                                                fetchDocuments: _fetchDocuments,
                                                id: snapshot.data[index].id,
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
