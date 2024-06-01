import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../constants/style.dart';
import '../../../model/Attendance.dart';
import '../../../model/Single.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/custom_text.dart';
import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../widgets/attendance_list_item_datewise.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';


class AttendanceListDateWise extends StatefulWidget {
  
  
  Navbools nn;
  AttendanceListDateWise({super.key, required  this.nn});


  @override
  State<AttendanceListDateWise> createState() => _AttendanceListDateWiseState();
}

class _AttendanceListDateWiseState extends State<AttendanceListDateWise> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  var employee = [], semployee = [];
  var _selectedemployee;
  late Single _selectedemployeeid;
  DateTime selectedstartDate = DateTime.now();
  DateTime selectedendDate = DateTime.now();
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
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;

  List<Attendance> allAttendances = [];
  List<Attendance> foundAttendances = [];
  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Employee')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        employee.add(Single(id:
            element.id, name: "${element["First Name"]} ${element["Last Name"]}"));
        semployee.add("${element["First Name"]} ${element["Last Name"]}");
        setState(() {});
      });
    });


  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  _selectstartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedstartDate,
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
    if (picked != null && picked != selectedstartDate)
      setState(() {
        selectedstartDate = picked;
      });
  }

  _selectendDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedendDate,
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
    if (picked != null && picked != selectedendDate) {
      setState(() {
        selectedendDate = picked;
      });
    }
  }



  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_attendance = true;
      widget.nn.hr_attendance_datewise_attendance= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments(DateTime startDate, DateTime endDate) async {
    int s = 0;
    allAttendances = [];
    await FirebaseFirestore.instance
        .collection('Attendance')
    .where("Date",isGreaterThan: startDate)
        .where("Date",isLessThan: endDate)
    .where("Employee ID", isEqualTo: _selectedemployeeid.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allAttendances.add(Attendance(
          name: element["Employee Name"],
          emplid: element["Employee ID"],
          date: element["Date"],
          intime: element["In Time"],
          outtime: element["Out Time"],user: element['User'],
          out: element["Out"],
          worktime: element["Work Time"],
          id: element.id,
          sl: s,
        ));
        s++;
      });
    }).catchError((error) => print("Failed to add user: $error"));
    foundAttendances = allAttendances;
    makechunks();
  }

  void _fetchDocument() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Attendance')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allAttendances.add(Attendance(
          name: element["Employee Name"],
          emplid: element["Employee ID"],
          date: element["Date"],user: element['User'],
          intime: element["In Time"],
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
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

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
                  margin: EdgeInsets.only(top: _height / 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: 30,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: "Attendance List Date Wise",
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
                                SizedBox(
                                  height: 1,
                                  width: _width / 25,
                                ),
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
                                              .format(selectedstartDate)
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
                                              .format(selectedendDate)
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
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: CustomText(
                                      text: "Employee",
                                      size: 16,
                                    ),
                                  ),
                                  flex: 3,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    margin: EdgeInsets.only(left: 20),
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: DropdownButton(
                                      underline: SizedBox(),
                                      isExpanded: true,
                                      hint: const Text('Select Employee'),
                                      value: _selectedemployee,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _selectedemployeeid =
                                          employee[semployee.indexOf(newValue)];
                                          _selectedemployee = newValue.toString();
                                        });
                                      },
                                      items: employee.map((location) {
                                        return DropdownMenuItem(
                                          value: location.name,
                                          child: new Text(location.name),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                Expanded(
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
                                        _fetchDocuments(selectedstartDate, selectedendDate);
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
                          SizedBox(
                            height: 20,
                          ),
                          Container(
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
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 4,
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
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 3,
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
                                                    transform: Matrix4.translationValues(
                                                        0.0, 8.0, 0.0),
                                                    child: Icon(
                                                      Icons.arrow_drop_up,
                                                      color: _datetop
                                                          ? Colors.black
                                                          : Colors.black45,
                                                    ),
                                                  ),
                                                  Container(
                                                    transform: Matrix4.translationValues(
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
                                            "In Time",
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
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 3,
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
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: _height / 2.40,
                                  child: FutureBuilder(
                                    builder: (ctx,AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Text("Select Dates And Employee Name.."),
                                          );
                                        } else if (snapshot.hasData) {
                                          return MediaQuery.removePadding(
                                            context: context,
                                            removeTop: true,
                                            child: ListView.builder(
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                var formattedDate = DateFormat.yMMMd().format(snapshot.data[index].date.toDate());
                                                return AttendanceListItemDatewise(
                                                  index: index,
                                                  sl: snapshot.data[index].sl,
                                                  name: snapshot.data[index].name,
                                                  outtime: snapshot.data[index].outtime,
                                                  intime: snapshot.data[index].intime,
                                                  date: formattedDate.toString(),
                                                  worktime: snapshot.data[index].worktime,
                                                  emplid: snapshot.data[index].emplid,
                                                  out: snapshot.data[index].out,
                                                  fetchDocuments: _fetchDocument,
                                                  id: snapshot.data[index].id,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return Center(
                                        child: Text("Select Correct Dates And Employee Name.."),
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
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        )));
  }
}
