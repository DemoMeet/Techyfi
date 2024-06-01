import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/routing/routes.dart';

import 'package:get/get.dart';
import '../../../constants/style.dart';
import '../../../helpers/auth_service.dart';
import '../../../helpers/screen_size_controller.dart';
import '../../../model/Single.dart';
import '../../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';



class AddAttendance extends StatefulWidget {

  
  Navbools nn;
  AddAttendance({required  this.nn});
  @override
  State<AddAttendance> createState() => _AddAttendanceState();
}

class _AddAttendanceState extends State<AddAttendance> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  var _selectedemployee;
  var _selectedemployeeid;
  var employee = [], semployee = [];
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  int _sts = 1;
  _addunit() async {
    String ename = _selectedemployeeid.name;
    String eid = _selectedemployeeid.id;

    String date = DateFormat.yMMMd().format(selectedDate).toString();
    String time = selectedTime
        .format(
          context,
        )
        .toString();
    if (ename.isEmpty || date.isEmpty || time.isEmpty) {
         Get.snackbar("Invalid Format.",
                     "Employee, Date & Sign in is Required",
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.red,
                      margin: EdgeInsets.zero,
                      duration: const Duration(milliseconds: 2000),
                      boxShadows: [
                        BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                      ],
                      borderRadius: 0);
    } else {
      FirebaseFirestore.instance.collection('Attendance').add({
        'Employee Name': ename,
        'Employee ID': eid,
        'Date': selectedDate,'User':AuthService.to.user?.name,
        'In Time': time,
        'Out Time': "",
        'Out': false,
        'Work Time': "",
      }).then((value) {
        widget.nn.setnavbool();
        widget.nn.human_resource =true;
        widget.nn.human_resource_attendance = true;
        widget.nn.hr_attendance_attendance_list = true;
        Get.offNamed(attendacelistPageRoute);
               Get.snackbar("Attendance Added Successfully!",
                     "Redirecting to Attendance List.",
                      snackPosition: SnackPosition.BOTTOM,
                      colorText: Colors.white,
                      backgroundColor: Colors.green,
                      margin: EdgeInsets.zero,
                      duration: const Duration(milliseconds: 2000),
                      boxShadows: [
                        BoxShadow(color: Colors.grey,offset: Offset(-100,0),blurRadius: 20),
                      ],
                      borderRadius: 0);
      }).catchError((error) => print("Failed to add user: $error"));
    }
  }

  void _fetchDatas() async {
    await FirebaseFirestore.instance
        .collection('Employee')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        employee.add(Single(
            id: element.id,
            name: element["First Name"] + " " + element["Last Name"]));
        semployee.add(element["First Name"] + " " + element["Last Name"]);
        setState(() {});
      });
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
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
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {double _height = MediaQuery.of(context).size.height;
  double _width = MediaQuery.of(context).size.width;

  
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
                margin: EdgeInsets.only(top: _height / 8, left: 30, right: _width / 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(text: "Add Attendance", size: 32, weight: FontWeight.bold),
                    Container(
                      margin: EdgeInsets.only(top: _height / 5, left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 1,
                            ),
                            flex: 4,
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Employee",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: DropdownButton(
                                underline: SizedBox(),
                                isExpanded: true,
                                hint: Text('Select Employee'),
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
                                    child: new Text(location.name),
                                    value: location.name,
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 1,
                            ),
                            flex: 4,
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Date",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text:
                                  DateFormat.yMMMd().format(selectedDate).toString(),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 1,
                            ),
                            flex: 4,
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "In Time",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.grey.shade200,
                                ),
                                child: CustomText(
                                  text: selectedTime
                                      .format(
                                    context,
                                  )
                                      .toString(),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: _height / 25, left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 1,
                            ),
                            flex: 11,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  _addunit();
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
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      )));
  }
}
