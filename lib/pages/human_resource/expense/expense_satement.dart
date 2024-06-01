import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../model/Expense.dart';
import '../../../model/Single.dart';
import '../../../widgets/custom_text.dart';
import '../widgets/Expense_list_item.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';


class ExpenseStatement extends StatefulWidget {

  
  
  Navbools nn;
  ExpenseStatement(
      {super.key,
        
        required this.nn,
        });
  @override
  State<ExpenseStatement> createState() => _ExpenseStatementState();
}

class _ExpenseStatementState extends State<ExpenseStatement> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  var _selectedexpense;
  var _selectedexpenseid;
  var expense = [], sexpense = [];
  double _totalamount = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
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
  List<Expense> allExpenses = [];
  List<Expense> foundExpenses = [];
  TextEditingController search_Expense = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_expense = true;
      widget.nn.hr_expense_expense_satement= true;
      controller.onChange(false);
      _first = true;
    }
  }

  Future<void> _fetchDatas() async {
    expense.add(Single(id: "000", name: "Others"));
    sexpense.add("Others");
    await FirebaseFirestore.instance
        .collection('ExpenseItem')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        expense.add(Single(id: element.id, name: element["Expense Item Name"]));
        sexpense.add(element["Expense Item Name"]);
        setState(() {});
      });
    });
  }

  void _onEditExpense(Expense cst) {
    // Navigator.of(context).pushNamed(
    //   editSalaryPageRoute,
    //   arguments: {
    //     'Salary': jsonEncode(cst),
    //   },
    // );
  }
  void _fetchDocuments(DateTime startDate, DateTime endDate) async {
    int s = 0;
    allExpenses = [];
    await FirebaseFirestore.instance
        .collection('Expense')
        .where("Date",isGreaterThan: startDate)
        .where("Date",isLessThan: endDate)
        .where("Expense ID", isEqualTo: _selectedexpenseid.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allExpenses.add(Expense(user: element['User'],
            sl: s, uid: element["UID"],amount: element["Amount"],date: element["Date"],expenseid: element["Expense ID"],expensename: element["Expense Name"],from: element["From"], others: element["Others"]
        ));
        s++;
      });
    });
    foundExpenses = allExpenses;
    makechunks();


  }

  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundExpenses.length; i += _items) {
      chunks.add(foundExpenses.sublist(
          i,
          i + _items > foundExpenses.length
              ? foundExpenses.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundExpenses.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDatas();
    listScrollController = ScrollController();
    super.initState();
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

    Future<List<Expense>> getCust() async {
      List<Expense> Expenses = [];
      _totalamount = 0;
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Expenses.add(chunks[_currentpagenum - 1][ss]);
        _totalamount = _totalamount + chunks[_currentpagenum - 1][ss].amount;
      }
      return Expenses;
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
                : SideMenuSmall(widget.nn,),
            Expanded(
                child:  MeasuredSize(
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
                            top: 15
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "Expense List Statement",
                                size: 22,
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
                              const Expanded(
                                  child: SizedBox(
                                    height: 1,
                                  )),
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
                                            .format(startDate)
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
                                            .format(endDate)
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
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: CustomText(
                                    text: "Expense Item Category",
                                    size: 16,
                                  ),
                                ),
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
                                    hint: const Text('Select Expense Category'),
                                    value: _selectedexpense,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _selectedexpenseid =
                                        expense[sexpense.indexOf(newValue)];
                                        _selectedexpense = newValue.toString();
                                      });
                                    },
                                    items: expense.map((location) {
                                      return DropdownMenuItem(
                                        value: location.name,
                                        child: Text(location.name),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              const Expanded(
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
                                      _fetchDocuments(startDate, endDate);
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
                                                _datetop = false;
                                                _datebot = false;
                                                allExpenses
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
                                                "Expense Name",
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
                                                    allExpenses.sort(
                                                            (a, b) => a.expensename.compareTo(b.expensename));
                                                    makechunks();
                                                  } else {
                                                    _nametop = false;
                                                    _namebot = true;
                                                    allExpenses.sort(
                                                            (b, a) => a.expensename.compareTo(b.expensename));
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
                                                    allExpenses.sort(
                                                            (a, b) => a.date.compareTo(b.date));
                                                    makechunks();
                                                  } else {
                                                    _datetop = false;
                                                    _datebot = true;
                                                    allExpenses.sort(
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
                                            "Amount",
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
                                  height: _height / 2.40,
                                  child: FutureBuilder(
                                    builder: (ctx,AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState == ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                          child: Text("Select Dates And Expense Category.."),
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
                                                return ExpenseListItem(
                                                  index: index,
                                                  cst: snapshot.data[index],
                                                  click: _click[index],
                                                  changeVal: changeVal, editExpense: _onEditExpense,);
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return Center(
                                        child: Text("Select Dates And Expense Category.."),
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
                                        flex: 36,
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
