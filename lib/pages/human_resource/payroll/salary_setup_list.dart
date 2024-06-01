import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../constants/style.dart';
import '../../../model/Salary.dart';
import '../../../widgets/custom_text.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../widgets/salarysetup_list_item.dart';
class SalarySetupList extends StatefulWidget {
  
  
  Navbools nn;
  SalarySetupList(
      {super.key,
        
        required this.nn,
        });
  @override
  State<SalarySetupList> createState() => _SalarySetupListState();
}

class _SalarySetupListState extends State<SalarySetupList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false, _nametop = false, _namebot = false;
  double _totalamount = 0;

  DateTime selectedDate =
  DateTime.utc(DateTime.now().year, DateTime.now().month - 1);
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Salary> allbenefit = [];
  List<Salary> foundbenefit = [];
  TextEditingController search_benefit = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_payroll = true;
      widget.nn.hr_payroll_salary_setup_list= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    allbenefit = [];
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Salary')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allbenefit.add(Salary(
            epnname: element["Employee Name"],
            from: element['From'],
            empid: element["Employee ID"],
            salarytype: element["Salary Type"],user: element['User'],
            uid: element.id,
            workinghours: element["Working Hours"],
            salarymonth: element["Salary Month"],
            attenstart: element["Atte Start Date"],
            attenend: element["Atte End Date"],
            date: element["Date"],
            basicsalary: element["Basic Salary"],
            grosssalary: element["Gross Salary"],
            workingdays: element["Working Days"],
            totaldays: element["Total Days"],
            benifits: element["Benefits"],
            sl: s)
        );

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

  _selectDate(BuildContext context) async {

    // showMonthPicker(
    //   context: context,
    //   firstDate: DateTime(2000),
    //   lastDate: DateTime(2025),
    //   initialDate: selectedDate,
    // ).then((DateTime? date) {
    //   if (date != null) {
    //     setState(() {
    //       selectedDate = date;
    //       _runDateFilter(selectedDate, true);
    //     });
    //   }else{
    //     _runDateFilter(selectedDate, false);
    //   }
    // });
  }
  void _runFilter(String enteredKeyword) {
    List<Salary> results = [];
    print(enteredKeyword);
    if (enteredKeyword.isEmpty) {
      results = allbenefit;
    } else {
      results = allbenefit
          .where((user) =>
          user.epnname.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundbenefit = results;
    });
    makechunks();
  }

  void _runDateFilter(DateTime dd, bool ss) {
    List<Salary> results = [];
    if (!ss) {
      results = allbenefit;
    } else {
      results = allbenefit
          .where((user) {
            if(user.salarymonth.toDate().year == dd.year && user.salarymonth.toDate().month == dd.month){
              return true;
            }else{
              return false;
            }
      }
      )
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

    void _onEditSalary(Salary cst) {
      // Navigator.of(context).pushNamed(
      //   editSalaryPageRoute,
      //   arguments: {
      //     'Salary': jsonEncode(cst),
      //   },
      // );
    }
    Future<List<Salary>> getCust() async {
      List<Salary> units = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        units.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].grosssalary;
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
                              text: "Salary List",
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
                                  hintText: "Search By Name",
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
                                      flex: 2,
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
                                    const Text("|"),
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 7),
                                            child: Text(
                                              "Employee Name",
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
                                                          (a, b) => a.epnname.compareTo(b.epnname));
                                                  makechunks();
                                                } else {
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allbenefit.sort(
                                                          (b, a) => a.epnname.compareTo(b.epnname));
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
                                      flex:3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            Text(
                                              "Salary Month",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),

                                            const Expanded(
                                              child: SizedBox(
                                                width: 1,
                                              ),
                                            ),
                                        InkWell(
                                          onTap: () => _selectDate(context),
                                          child: Icon(
                                            Icons.calendar_month_outlined,
                                            color: tabletitle,
                                            size: 18,
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
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Salary Type",
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
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Working Hours",
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
                                        alignment: Alignment.center,
                                        child: Text(
                                          "W. Days/T. Days",
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
                                        alignment: Alignment.center,
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
                                    Text("|"),
                                    Expanded(
                                      flex:3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        alignment: Alignment.center,
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
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Total Salary",
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
                                      flex:3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 25),
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
                                  builder: (ctx,AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text(
                                              "No Salary Setup Data Available.."),
                                        );
                                      } else if (snapshot.hasData) {
                                        return MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: ListView.builder(
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              _click.add(false);
                                              return SalarySetupListItem(
                                                index: index,
                                                cst: snapshot.data[index],
                                                click: _click[index],
                                                changeVal: changeVal,
                                                fetchDocuments: _fetchDocuments,
                                                 onEditSalarySetup: _onEditSalary,
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
