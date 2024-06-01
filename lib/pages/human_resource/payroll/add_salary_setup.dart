import 'dart:collection';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/model/Benefit.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../helpers/auth_service.dart';
import '../../../model/Accounts.dart';
import '../../../model/Employee.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';

class AddSalarySetup extends StatefulWidget {
  
  
  Navbools nn;
  AddSalarySetup(
      {super.key,
      
      required this.nn,
      });

  @override
  State<AddSalarySetup> createState() => _AddSalarySetupState();
}

class _AddSalarySetupState extends State<AddSalarySetup> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  int _sts = 1;
  double totaldays = 0.0, totalhours = 0.0, totalminutes = 0.0;
  DateTime selectedDate =
      DateTime.utc(DateTime.now().year, DateTime.now().month - 1);
  double _totalsalary = 0.0;
  bool fetch = false;
  var _selectedemployee;
  late Employee _selectedemployeeid;
  var employee = [],
      semployee = [],
      benefits = [],
      payment = ["Bank Payment", "Cash Payment"],
      additionConrtroller = [],
      deductionController = [];
  List<Accounts> _bankaccounts = [];
  List<Accounts> _cashaccounts = [];
  List<String> sbankaccounts = [];
  List<String> scashaccounts = [];
  var _selectedaccount, _selectedpayment;
  var _selectedAccountid;
  DateTime selectedstartDate =
      DateTime.utc(DateTime.now().year, DateTime.now().month - 1);
  DateTime selectedendDate = DateTime.now();

  bool selectedpm = false, bankpayment = false;
  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Employee')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        employee.add(Employee(
          fname: element["First Name"],
          lname: element["Last Name"],
          phone: element["Phone"],
          email: element["Email"],
          address1: element["Address Line 1"],user: element['User'],
          address2: element["Address Line 2"],
          salary: element["Salary"],
          country: element["Country"],
          city: element["City"],
          zip: element["Zip"],
          status: element["status"] ? "Active" : "Deactivate",
          rate: element["Rate"],
          designationid: element["Designation ID"],
          designation: element["Designation Name"],
          blood: element["Blood Group"],
          id: element.id,
          sl: 0,
          img: element["Image"],
          imgurl: element["ImageURL"],
        ));
        semployee.add(element["First Name"] + " " + element["Last Name"]);
        setState(() {});
      });
    });

    await FirebaseFirestore.instance
        .collection('Benefit')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element["Benefit Type"] == "Add") {
          benefits.add(Benefit(
              title: element["Benefit Name"],
              benefitid: element.id,
              cntrl: TextEditingController(text: "0"),
              isadd: true));
        } else {
          benefits.add(Benefit(
              title: element["Benefit Name"],
              benefitid: element.id,
              cntrl: TextEditingController(text: "0"),
              isadd: false));
        }
        setState(() {});
      });
    });

    await FirebaseFirestore.instance
        .collection('Account')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        setState(() {
          if (element["Bank"]) {
            _bankaccounts.add(Accounts(
                uid: element["UID"],
                accountname: element["Account Name"],
                accountnum: element["Account Number"],
                cashdetails: element["Cash Details"],
                cashname: element["Cash Name"],
                bal: element["Balance"],
                sts: element["Status"],user: element['User'],
                bankname: element["Bank Name"],
                bank: element["Bank"],
                branch: element["Branch"],
                sl: 0));
            sbankaccounts.add(element["Account Number"]);
          } else {
            _cashaccounts.add(Accounts(
                uid: element["UID"],
                accountname: element["Account Name"],
                accountnum: element["Account Number"],
                cashdetails: element["Cash Details"],user: element['User'],
                cashname: element["Cash Name"],
                bal: element["Balance"],
                sts: element["Status"],
                bankname: element["Bank Name"],
                bank: element["Bank"],
                branch: element["Branch"],
                sl: 0));
            scashaccounts.add(element["Cash Name"].toString());
          }
        });
      });
    });
  }

  _addsalary(List<Benefit> add, List<Benefit> ded) async {
    List<Map<String, Object>> benn = [];
    for (Benefit ns in add) {
      Map<String, Object> stuff = {
        'Benefit Name': ns.title,
        'Amount': double.parse(ns.cntrl.text.toString()),
        'Benefit ID': ns.benefitid,
        'IsAdd': ns.isadd
      };
      benn.add(stuff);
    }
    for (Benefit ns in ded) {
      Map<String, Object> stuff = {
        'Benefit Name': ns.title,
        'Amount': double.parse(ns.cntrl.text.toString()),
        'Benefit ID': ns.benefitid,
        'IsAdd': ns.isadd
      };
      benn.add(stuff);
    }
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    String getRandomString(int length) =>
        String.fromCharCodes(Iterable.generate(
            length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
    String ss = getRandomString(20);

    if (!fetch ||
        _selectedpayment.toString() == "null" ||
        _selectedAccountid.toString() == "null") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Select Particular Employee to generate Salary"),
      ));
    } else {
      if (_selectedAccountid.bal > _totalsalary) {
        FirebaseFirestore.instance.collection('Transaction').add({
          'Name': "${_selectedemployeeid.fname} ${_selectedemployeeid.lname}",
          '2nd ID': _selectedemployeeid.id,
          'Remarks': "Employee Salary",
          'Submit Date': DateTime.now(),'User':AuthService.to.user?.name,
          'Date': selectedDate,
          'Type': 'Debit',
          'Payment Method': _selectedpayment,
          'ID': ss,
          'Account ID': _selectedAccountid.uid,
          'Account Details': _selectedAccountid.toJson(),
          'Amount': _totalsalary,
        });
        FirebaseFirestore.instance
            .collection('Account')
            .doc(_selectedAccountid.uid)
            .update({
          'Balance': _selectedAccountid.bal - _totalsalary,
        });
        FirebaseFirestore.instance.collection('Salary').doc(ss).set({
          'Employee Name':
              "${_selectedemployeeid.fname} ${_selectedemployeeid.lname}",
          'Employee ID': _selectedemployeeid.id,
          'Salary Type': _selectedemployeeid.rate,
          'UID': ss,
          'Basic Salary': _selectedemployeeid.salary,
          'Salary Month': selectedDate,'User':AuthService.to.user?.name,
          'From': _selectedAccountid.bank
              ? _selectedAccountid.bankname
              : _selectedAccountid.cashname,
          'Atte. Start Date': selectedstartDate,
          'Atte. End Date': selectedendDate,
          'Working Days': totaldays,
          'Total Days': selectedendDate.difference(selectedstartDate).inDays,
          'Working Hours': "$totalhours : $totalminutes Hours",
          'Gross Salary': _totalsalary,
          'Benefits': benn,
          'Date': DateTime.now()
        }).then((value) {
          
          widget.nn.setnavbool();
          widget.nn.human_resource =true;
          widget.nn.human_resource_payroll = true;
          widget.nn.hr_payroll_salary_setup_list = true;
          Get.offNamed(salarysetuplistPageRoute);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Salary Added Successfully!"),
          ));
        }).catchError((error) => print("Failed to add user: $error"));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Selected Account Doesn't Have Sufficient Balance, Change Account."),
        ));
      }
    }
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  bool _first = false;

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.human_resource = true;
      widget.nn.human_resource_payroll = true;
      widget.nn.hr_payroll_add_salary_setup= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments(DateTime startDate, DateTime endDate) async {
    await FirebaseFirestore.instance
        .collection('Attendance')
        .where("Date", isGreaterThan: startDate)
        .where("Date", isLessThan: endDate)
        .where("Employee ID", isEqualTo: _selectedemployeeid.id)
        .get()
        .then((querySnapshot) {
      int minutes = 0;
      totaldays = 0.0;
      totalhours = 0.0;
      totalminutes = 0.0;
      for (var element in querySnapshot.docs) {
        setState(() {
          if (element["Out"]) {
            totaldays = totaldays + 1;
            String s = element["Work Time"];
            int idx = s.indexOf(":");
            List parts = [
              s.substring(0, idx).trim(),
              s.substring(idx + 1).trim()
            ];
            totalhours = totalhours + int.parse(parts[0]);
            minutes = int.parse(parts[1].substring(0, 2));
            checkmin(minutes);
          }
        });
      }
      setState(() {});
    }).catchError((error) => print("Failed to add user: $error"));
  }

  checkmin(int minutes) {
    if ((totalminutes + minutes) >= 60) {
      minutes = minutes - 60;
      totalhours = totalhours + 1;
      checkmin(minutes);
    } else {
      setState(() {
        totalminutes = totalminutes + double.parse(minutes.toString());
      });
    }
  }

  _selectDate(BuildContext context) async {
    // showMonthPicker(
    //   context: context,
    //     firstDate: DateTime(2000),
    //     lastDate: DateTime(2025),
    //   initialDate: selectedDate,
    // ).then((DateTime? date) {
    //   if (date != null) {
    //     setState(() {
    //       selectedDate = date;
    //     });
    //   }});
  }

  _adddeducttosalary(List<Benefit> add, List<Benefit> ded) {
    _totalsalary = double.parse(_selectedemployeeid.salary);
    setState(() {
      for (var i = 0; i < add.length; i++) {
        if (add[i].cntrl.text.isEmpty) {
          add[i].cntrl.text = "0";
          _totalsalary = _totalsalary + 0;
        } else {
          _totalsalary =
              _totalsalary + double.parse(add[i].cntrl.text.toString());
        }
      }
      for (var i = 0; i < ded.length; i++) {
        if (ded[i].cntrl.text.isEmpty) {
          ded[i].cntrl.text = "0";
          _totalsalary = _totalsalary - 0;
        } else {
          _totalsalary =
              _totalsalary - double.parse(ded[i].cntrl.text.toString());
        }
      }
    });
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
    if (picked != null && picked != selectedstartDate) {
      setState(() {
        selectedstartDate = picked;
        _fetchDocuments(selectedstartDate, selectedendDate);
      });
    }
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
        _fetchDocuments(selectedstartDate, selectedendDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    List<Benefit> ded = [];
    List<Benefit> add = [];
    void getDed() async {
      for (Benefit b in benefits) {
        if (!b.isadd) {
          ded.add(b);
        } else {
          add.add(b);
        }
      }
      setState(() {});
    }

    Future.delayed(Duration.zero, () async {
      apply();
    });

 

    getDed();
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
              margin: EdgeInsets.only(
                top: _height / 8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 30),
                      child: CustomText(
                          text: "Add Salary Setup",
                          size: 26,
                          weight: FontWeight.bold),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Select Employee",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(left: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: SizedBox(),
                                isExpanded: true,
                                hint: Text('Select Employee'),
                                value: _selectedemployee,
                                onChanged: (Value) {
                                  setState(() {
                                    _selectedemployeeid =
                                        employee[semployee.indexOf(Value)];
                                    _selectedemployee = Value.toString();
                                    fetch = true;
                                    _fetchDocuments(
                                        selectedstartDate, selectedendDate);

                                    _totalsalary = double.parse(
                                        _selectedemployeeid.salary);
                                  });
                                },
                                items: semployee.map((location) {
                                  return DropdownMenuItem(
                                    child: Text(location),
                                    value: location,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Salary Type",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: fetch ? _selectedemployeeid.rate : "",
                                  size: 16,
                                ),
                              )),
                          const Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 1,
                            ),
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
                                  text: "Basic Salary",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: fetch ? _selectedemployeeid.salary : "",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "Select Month",
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: InkWell(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: CustomText(
                                    text: DateFormat.yMMMM()
                                        .format(selectedDate)
                                        .toString(),
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "Atte. Start Date",
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
                                  padding: const EdgeInsets.symmetric(
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
                            flex: 3,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "Atte. End Date",
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
                                  padding: const EdgeInsets.symmetric(
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
                            flex: 3,
                            child: SizedBox(
                              height: 1,
                            ),
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
                                  text: "Total Working Days",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                              flex: 5,
                              child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: "$totaldays Days",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                            flex: 3,
                            child: Container(
                              alignment: Alignment.centerRight,
                              child: CustomText(
                                text: "Total Working Hours",
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: EdgeInsets.only(left: 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: "$totalhours : $totalminutes Hours",
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 1,
                            ),
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
                                text: "Select Payment",
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              margin: const EdgeInsets.only(left: 20),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: const SizedBox(),
                                isExpanded: true,
                                hint: const Text('Select Payment'),
                                value: _selectedpayment,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue.toString() == payment[0]) {
                                      selectedpm = true;
                                      bankpayment = true;
                                      var vs;
                                      _selectedaccount = vs;
                                      _selectedAccountid = vs;
                                    } else {
                                      selectedpm = true;
                                      bankpayment = false;
                                      var vs;
                                      _selectedaccount = vs;
                                      _selectedAccountid = vs;
                                    }
                                    _selectedpayment = newValue.toString();
                                  });
                                },
                                items: payment.map((location) {
                                  return DropdownMenuItem(
                                    child: Text(location),
                                    value: location,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          selectedpm
                              ? bankpayment
                                  ? Expanded(
                                      flex: 3,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: CustomText(
                                          text: "Bank Payment",
                                          size: 16,
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      flex: 3,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: CustomText(
                                          text: "Cash Payment",
                                          size: 16,
                                        ),
                                      ),
                                    )
                              : const SizedBox(),
                          selectedpm
                              ? bankpayment
                                  ? Expanded(
                                      flex: 5,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: DropdownButton(
                                          underline: const SizedBox(),
                                          isExpanded: true,
                                          hint:
                                              const Text('Select Bank Account'),
                                          value: _selectedaccount,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedaccount =
                                                  newValue.toString();
                                              _selectedAccountid =
                                                  _bankaccounts[
                                                      sbankaccounts.indexOf(
                                                          newValue.toString())];
                                            });
                                          },
                                          items: _bankaccounts.map((location) {
                                            return DropdownMenuItem(
                                              value: location.accountnum,
                                              child: Text(
                                                  "${location.bankname} (${location.accountnum})"),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    )
                                  : Expanded(
                                      flex: 5,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 20),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: DropdownButton(
                                          underline: const SizedBox(),
                                          isExpanded: true,
                                          hint:
                                              const Text('Select Cash Counter'),
                                          value: _selectedaccount,
                                          onChanged: (newValue) {
                                            setState(() {
                                              _selectedaccount =
                                                  newValue.toString();
                                              _selectedAccountid =
                                                  _cashaccounts[
                                                      scashaccounts.indexOf(
                                                          newValue.toString())];
                                            });
                                          },
                                          items: _cashaccounts.map((location) {
                                            return DropdownMenuItem(
                                              value: location.cashname,
                                              child: Text(location.cashname),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    )
                              : const SizedBox(),
                          selectedpm
                              ? const Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                )
                              : const Expanded(
                                  flex: 11,
                                  child: SizedBox(
                                    height: 1,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const SizedBox(
                            width: 140,
                          ),
                          Text(
                            "Deduction",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                          SizedBox(
                            width: _width / 5,
                          ),
                          Text(
                            "Addition",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: tabletitle,
                                fontFamily: 'inter'),
                          ),
                          const SizedBox(
                            width: 140,
                          ),
                        ],
                      ),
                    ),
                    fetch
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: _width / 3 - 30,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView.builder(
                                      itemCount: ded.length,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              top: 10, right: 10),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                flex: 2,
                                                child: SizedBox(
                                                  height: 1,
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 3,
                                                  child: CustomText(
                                                    text: ded[index].title,
                                                    size: 16,
                                                  )),
                                              Expanded(
                                                flex: 4,
                                                child: TextFormField(
                                                  controller: ded[index].cntrl,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue),
                                                    ),
                                                    hintText: "0.00",
                                                    fillColor:
                                                        Colors.grey.shade200,
                                                    filled: true,
                                                  ),
                                                  onChanged: (val) {
                                                    _adddeducttosalary(
                                                        add, ded);
                                                  },
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 2,
                                                child: SizedBox(
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ),
                              Container(
                                width: 1,
                                color: Colors.black38,
                                height: 200,
                              ),
                              Container(
                                width: _width / 3,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: MediaQuery.removePadding(
                                  context: context,
                                  removeTop: true,
                                  child: ListView.builder(
                                      itemCount: add.length,
                                      shrinkWrap: true,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                              top: 10, right: 10),
                                          child: Row(
                                            children: [
                                              const Expanded(
                                                flex: 1,
                                                child: SizedBox(
                                                  height: 1,
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 4,
                                                  child: CustomText(
                                                    text: add[index].title,
                                                    size: 16,
                                                  )),
                                              Expanded(
                                                flex: 4,
                                                child: TextFormField(
                                                  controller: add[index].cntrl,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  inputFormatters: <TextInputFormatter>[
                                                    FilteringTextInputFormatter
                                                        .allow(
                                                            RegExp(r'[0-9]')),
                                                    FilteringTextInputFormatter
                                                        .digitsOnly
                                                  ],
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .transparent),
                                                    ),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                          color: Colors.blue),
                                                    ),
                                                    hintText: "0.00",
                                                    fillColor:
                                                        Colors.grey.shade200,
                                                    filled: true,
                                                  ),
                                                  onChanged: (val) {
                                                    _adddeducttosalary(
                                                        add, ded);
                                                  },
                                                ),
                                              ),
                                              const Expanded(
                                                flex: 3,
                                                child: SizedBox(
                                                  height: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                    Container(
                      width: double.infinity,
                      color: Colors.black38,
                      height: 1,
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(top: 10, left: _width / 3, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 4,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Gross Salary",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                              flex: 10,
                              child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: _totalsalary.toString(),
                                  size: 16,
                                ),
                              )),
                          const Expanded(
                            flex: 5,
                            child: SizedBox(),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 15, left: 10, right: 10, bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            flex: 15,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  _addsalary(add, ded);
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
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                        ],
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
