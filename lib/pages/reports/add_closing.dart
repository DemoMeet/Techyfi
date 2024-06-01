import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import 'package:groceyfi02/helpers/auth_service.dart';
import 'package:groceyfi02/routing/routes.dart';
import '../../../constants/style.dart';
import '../../../model/Accounts.dart';
import '../../../model/Supplier.dart';
import '../../../widgets/custom_text.dart';
import 'package:get/get.dart';
import '../../../model/nav_bools.dart';
import '../../../widgets/side_menu_big.dart';
import '../../../widgets/side_menu_small.dart';
import '../../../widgets/topnavigaton.dart';
import '../../model/Transaction.dart';

class AddClosing extends StatefulWidget {
  
  Navbools nn;
  AddClosing({super.key, required this.nn});
  @override
  State<AddClosing> createState() => _AddClosingState();
}

class _AddClosingState extends State<AddClosing> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conremarks = TextEditingController();
  double _lastdayclosing = 0, _received = 0, _payment = 0, _balance = 0;
  DateTime _lastdatetime = DateTime.utc(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  bool recivbool = false, paybool = false;
  int id = 0;
  List<Transactionss> debit = [];
  List<Transactionss> credit = [];

  _addunit() async {
    String _remarks = _conremarks.text;
    if(_lastdatetime.day == DateTime.now().day &&_lastdatetime.month == DateTime.now().month &&_lastdatetime.year == DateTime.now().year){
      Get.snackbar(
          "Adding Closing Failed", "Same Date Closing is Already Added",
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: Colors.red,
          margin: EdgeInsets.zero,
          duration: const Duration(milliseconds: 2000),
          boxShadows: [
            const BoxShadow(
                color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
          ],
          borderRadius: 0);

    }else{
      FirebaseFirestore.instance.collection('Closing').add({
        'id' : id,
        'Date': DateTime.now(),
        'Last Closing Date': _lastdatetime,
        'Last Closing Amount': _lastdayclosing,
        'Balance': _balance,
        'Payment': _payment,
        'Received': _received,'User':AuthService.to.user?.name,
        'Remarks': _conremarks.text,
      }).then((value) {
        widget.nn.setnavbool();
        widget.nn.report = true;
        widget.nn.report_closing_list = true;
        Get.offNamed(closinglistPageRoute);
        Get.snackbar(
            "Adding Closing Successful", "Redirecting To Closing List Page.",
            snackPosition: SnackPosition.BOTTOM,
            colorText: Colors.white,
            backgroundColor: Colors.green,
            margin: EdgeInsets.zero,
            duration: const Duration(milliseconds: 2000),
            boxShadows: [
              const BoxShadow(
                  color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
            ],
            borderRadius: 0);
      }).catchError((error) => print("Failed to add user: $error"));
    }


  }

  void _fetchDatas() async {
    // print("My"+DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day).toString());

    await FirebaseFirestore.instance
        .collection('Closing')
        .get()
        .then((querySnapshot) async {
          id = querySnapshot.size;
          await FirebaseFirestore.instance
              .collection('Closing').where('id',isEqualTo: id).limit(1)
              .get()
              .then((querySnapshot) {
            querySnapshot.docs.forEach((element) async {
              setState(() {
                _lastdayclosing =element["Balance"];
                _lastdatetime = element["Date"].toDate();
              });
            });
          });
    });

    await FirebaseFirestore.instance
        .collection('Transaction')
        .where("Submit Date",isGreaterThan:DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) async {
        print(element["Submit Date"].toDate());
        setState(() {
          if (element["Type"] == "Debit") {
            debit.add(Transactionss(
                name: element["Name"],
                type: element["Type"],
                id2: element["2nd ID"],
                remarks: element["Remarks"],user: element['User'],
                paymentmethod: element["Payment Method"],
                id1: element["ID"],
                accountid: element["Account ID"],
                date: element["Date"],
                submitdate: element["Submit Date"],
                account: element["Account Details"],
                amount: element["Amount"],
                sl: 0));
            _payment = _payment + element["Amount"];
          } else if (element["Type"] == "Credit") {
            credit.add(Transactionss(
                name: element["Name"],
                type: element["Type"],
                id2: element["2nd ID"],user: element['User'],
                remarks: element["Remarks"],
                paymentmethod: element["Payment Method"],
                id1: element["ID"],
                accountid: element["Account ID"],
                date: element["Date"],
                submitdate: element["Submit Date"],
                account: element["Account Details"],
                amount: element["Amount"],
                sl: 0));
            _received = _received + element["Amount"];
          }
        });
      });
      getbalance();
    });
  }

  void getbalance() {
    setState(() {
      _balance = _lastdayclosing + _received - _payment;
    });
  }

  @override
  void initState() {
    _fetchDatas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

 

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
                left: 30,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                        text: "Add Closing",
                        size: 32,
                        weight: FontWeight.bold),
                    Container(
                      margin: EdgeInsets.only(
                          top: _height / 12, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Last Day Closing",
                                size: 16,
                              )),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: _lastdayclosing.toString(),
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: CustomText(
                                  text: "Date  ",
                                  size: 16,
                                ),
                              )),
                          Expanded(
                            flex: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: DateFormat.yMMMd().format(_lastdatetime),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    recivbool
                        ? Container(
                            height: 60.0 * credit.length,
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: credit.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 10, left: 10, right: _width / 5),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          flex: 4,
                                          child: SizedBox(
                                            height: 1,
                                          ),
                                        ),
                                        Expanded(
                                            flex: 5,
                                            child: CustomText(
                                              text: credit[index].remarks,
                                              size: 16,
                                            )),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 15),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: CustomText(
                                              text: credit[index]
                                                  .amount
                                                  .toString(),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ))
                        : SizedBox(),
                    Container(
                      margin:
                          EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Total Received",
                                size: 16,
                              )),
                          Expanded(
                            flex: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: _received.toString(),
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (recivbool) {
                                      recivbool = false;
                                    } else {
                                      recivbool = true;
                                    }
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  child: CustomText(
                                    text: recivbool ? "Minimize" : "Expand",
                                    size: 14,
                                    color: Colors.blueAccent,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    paybool
                        ? Container(
                            height: 60.0 * debit.length,
                            child: MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: debit.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        top: 10, left: 10, right: _width / 5),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          flex: 4,
                                          child: SizedBox(
                                            height: 1,
                                          ),
                                        ),
                                        Expanded(
                                            flex: 5,
                                            child: CustomText(
                                              text: debit[index].remarks,
                                              size: 16,
                                            )),
                                        Expanded(
                                          flex: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 15),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.grey.shade200,
                                            ),
                                            child: CustomText(
                                              text: debit[index]
                                                  .amount
                                                  .toString(),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ))
                        : SizedBox(),
                    Container(
                      margin:
                          EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Total Payment",
                                size: 16,
                              )),
                          Expanded(
                            flex: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: _payment.toString(),
                                size: 16,
                              ),
                            ),
                          ),
                          Expanded(
                              flex: 2,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    if (paybool) {
                                      paybool = false;
                                    } else {
                                      paybool = true;
                                    }
                                  });
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  child: CustomText(
                                    text: paybool ? "Minimize" : "Expand",
                                    size: 14,
                                    color: Colors.blueAccent,
                                    weight: FontWeight.bold,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Balance",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade200,
                              ),
                              child: CustomText(
                                text: _balance.toString(),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin:
                          EdgeInsets.only(top: 10, left: 10, right: _width / 5),
                      child: Row(
                        children: [
                          const Expanded(
                            flex: 4,
                            child: SizedBox(
                              height: 1,
                            ),
                          ),
                          Expanded(
                              flex: 5,
                              child: CustomText(
                                text: "Remarks",
                                size: 16,
                              )),
                          Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: _conremarks,
                              decoration: InputDecoration(
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide:
                                      BorderSide(color: Colors.transparent),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                hintText: "Remarks",
                                fillColor: Colors.grey.shade200,
                                filled: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: _height / 25, left: 10, right: _width / 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            flex: 11,
                            child: SizedBox(
                              height: 1,
                            ),
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
              ),
            )),
          ],
        )));
  }
}
