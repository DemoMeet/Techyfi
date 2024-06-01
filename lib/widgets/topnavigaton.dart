import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/routing/routes.dart';

import '../constants/style.dart';
import '../helpers/app_bar_controller.dart';
import '../helpers/auth_service.dart';
import '../helpers/screen_size_controller.dart';
import '../model/Lending.dart';
import '../model/User.dart';
import 'custom_text.dart';
import 'package:get/get.dart';

class MyAppBar extends StatefulWidget implements PreferredSizeWidget {
  double height, width;

  MyAppBar({
    required this.height,
    required this.width,
  });
  @override
  _MyAppBarState createState() => _MyAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(70);
}

class _MyAppBarState extends State<MyAppBar> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  User? usr = AuthService.to.user;
  List<Lending> allLendings = [];

  _fetchDocuments() async {
    await FirebaseFirestore.instance
        .collection('Lending')
        .where("Status", isEqualTo: "Current")
        .where("Return Date", isLessThanOrEqualTo: DateTime.now())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allLendings.add(Lending(
            name: element["Lending Person Name"],
            phone: element["Lending Person Phone"],
            lendingpersonid: element["Lending Person ID"],
            status: element["Status"],
            uid: element["UID"],
            user: element['User'],
            remarks: element["Remarks"],
            sl: 0,
            amount: element["Amount"],
            returnedamount: element["Returned Amount"],
            date: element["Date"],
            returndate: element["Return Date"],
            lendingperson: element["Lending Person"],
            from: element["From"]));
      });
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    super.initState();
  }

  showPendingPayment() {
    Get.dialog(
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        Dialog(
          backgroundColor: Colors.white,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: widget.width / 3,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                        color: Colors.grey.shade200,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          CustomText(
                            text: "Lending Payment To Be Received",
                            size: 16,
                            weight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          const Expanded(child: SizedBox()),
                          GestureDetector(
                            child: Icon(Icons.close),
                            onTap: () {
                              Get.back();
                            },
                          ),
                        ],
                      )),
                ),
                Expanded(
                  flex: 9,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(children: [
                      Container(
                        color: Colors.grey.shade200,
                        padding: EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                margin: EdgeInsets.only(left: 7),
                                child: Text(
                                  "Person Name",
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
                              flex: 2,
                              child: Container(
                                margin: EdgeInsets.only(left: 7),
                                child: Text(
                                  "Lending Date",
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
                                  "Return Date",
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
                          ],
                        ),
                      ),
                      SizedBox(
                        height: widget.height / 2,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            //  physics: NeverScrollableScrollPhysics(),
                            itemCount: allLendings.length,
                            itemBuilder: (context, index) {
                              Lending cst = allLendings[index];
                              return Container(
                                height: MediaQuery.of(context).size.height / 16,
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              cst.name,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              cst.phone,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              DateFormat.yMMMd()
                                                  .format(cst.date.toDate())
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            child: Text(
                                              DateFormat.yMMMd()
                                                  .format(
                                                      cst.returndate.toDate())
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            margin: EdgeInsets.only(left: 7),
                                            alignment: Alignment.center,
                                            child: Text(
                                              cst.amount.toString(),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: tabletitle,
                                                  fontFamily: 'inter'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: .2,
                                      margin: EdgeInsets.only(top: 10),
                                      width: double.infinity,
                                      color: tabletitle,
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  showProfileDialog() {
    Get.dialog(
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        Dialog(
          insetPadding: EdgeInsets.only(right: 10, top: widget.height / 11),
          backgroundColor: Colors.white,
          elevation: 20,
          alignment: Alignment.topRight,
          child: Container(
            width: widget.width / 5.5,
            height: widget.height / 2.4,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(usr!.asset),
                ),
                const SizedBox(
                  height: 15,
                ),
                CustomText(
                  text: usr!.name,
                  size: 22,
                  weight: FontWeight.bold,
                  color: Colors.black87,
                ),
                CustomText(
                  text: "ID: ${usr?.id}",
                  size: 16,
                  color: Colors.black45,
                ),
                const Expanded(
                    child: SizedBox(
                  height: 0,
                )),
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      myprofilePageRoute,
                      arguments: {
                        'User': jsonEncode(usr),
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, color: Colors.black87),
                        const SizedBox(
                          width: 15,
                        ),
                        CustomText(
                          text: "My Profile",
                          size: 16,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                  onTap: () {
                    AuthService.to.Logout();
                    Get.offAllNamed(authenticationPageRoute);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.black87),
                        const SizedBox(
                          width: 15,
                        ),
                        CustomText(
                          text: "Logout",
                          size: 16,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppBarController>(
      builder: (vvv) {
        return AppBar(
          actions: <Widget>[Container()],
          toolbarHeight: widget.height / 10,
          elevation: 0,
          backgroundColor: dark,
          flexibleSpace: Container(
            child: Obx(() => Row(
              children: [
                Container(
                  padding: controller.screenSize.value
                      ? EdgeInsets.only(
                          left: widget.width / 50, right: widget.width / 17)
                      : EdgeInsets.only(
                          left: widget.width / 60, right: widget.width / 105),
                  child: controller.screenSize.value
                      ? Image.asset(
                          "assets/icons/logo.png",
                          width: widget.width / 10,
                          height: 30,
                        )
                      : Image.asset(
                          "assets/icons/logo_mini.png",
                          width: 30,
                          height: 30,
                        ),
                ),
                controller.screenSize.value
                    ? const SizedBox(
                        width: 3,
                      )
                    : const SizedBox(
                        width: 3,
                      ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 40),
                          child: InkWell(
                              onTap: () {
                                if (controller.screenSize.value) {
                                  controller.onChange(false);
                                } else {
                                  controller.onChange(true);
                                }
                              },
                              child: Image.asset(
                                "assets/icons/menu.png",
                                width: 20,
                              )),
                        ),
                        Expanded(child: Column()),
                        Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                if (vvv.lending.value == 0) {
                                  Get.snackbar("No Lending Payment Pending.",
                                      "All Payments For Lending is Clear",
                                      snackPosition: SnackPosition.BOTTOM,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.green,
                                      margin: EdgeInsets.zero,
                                      duration:
                                          const Duration(milliseconds: 2000),
                                      boxShadows: [
                                        BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(-100, 0),
                                            blurRadius: 20),
                                      ],
                                      borderRadius: 0);
                                } else {
                                  showPendingPayment();
                                }
                              },
                              child: Image.asset(
                                "assets/icons/lendingwarning.png",
                                width: 35,
                              ),
                            ),
                            vvv.lending.value != 0
                                ? Container(
                                    width: 15,
                                    height: 15,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(left: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: Colors.red, width: 2)),
                                    child: Text(
                                      vvv.lending.value > 99
                                          ? "99"
                                          : vvv.lending.value.toString(),
                                      style: TextStyle(
                                          fontSize: 8, color: Colors.white),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Stack(
                          children: [
                            InkWell(
                                onTap: () {
                                  Get.toNamed(stockoutreportPageRoute);
                                },
                                child: Image.asset(
                                  "assets/icons/stockwarning.png",
                                  width: 32,
                                )),
                            vvv.stoc.value != 0
                                ? Container(
                                    width: 15,
                                    height: 15,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(left: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: Colors.red, width: 2)),
                                    child: Text(
                                      vvv.stoc.value > 99
                                          ? "99"
                                          : vvv.stoc.value.toString(),
                                      style: TextStyle(
                                          fontSize: 8, color: Colors.white),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        // const SizedBox(
                        //   width: 7,
                        // ),
                        // Stack(
                        //   children: [
                        //     InkWell(
                        //         onTap: () {
                        //           Get.toNamed(expireproductPageRoute);
                        //         },
                        //         child: Image.asset(
                        //           "assets/icons/medexpire.png",
                        //           width: 35,
                        //         )),
                        //     vvv.expi.value != 0
                        //         ? Container(
                        //             width: 15,
                        //             height: 15,
                        //             alignment: Alignment.center,
                        //             margin: const EdgeInsets.only(left: 20),
                        //             decoration: BoxDecoration(
                        //                 color: Colors.red,
                        //                 borderRadius: BorderRadius.circular(30),
                        //                 border: Border.all(
                        //                     color: Colors.red, width: 2)),
                        //             child: Text(
                        //               vvv.expi.value > 99
                        //                   ? "99"
                        //                   : vvv.expi.value.toString(),
                        //               style: TextStyle(
                        //                   fontSize: 8, color: Colors.white),
                        //             ),
                        //           )
                        //         : SizedBox(),
                        //   ],
                        // ),
                        const SizedBox(
                          width: 20,
                        ),
                        InkWell(
                          onTap: () {
                            showProfileDialog();
                          },
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: AssetImage(usr!.asset),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                              text: "Welcome",
                              color: lightGrey,
                              size: 12,
                            ),
                            CustomText(
                              text: usr!.name,
                              color: Colors.lightBlueAccent,
                            ),
                          ],
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: dark,
                            ),
                            onPressed: () {
                              showProfileDialog();
                            }),
                        SizedBox(
                          width: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }
}
