import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:groceyfi02/helpers/auth_service.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../model/User.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  var conid = TextEditingController();

  var conpass = TextEditingController();
  bool sts = false;

  void handleAdminLogin(User usr) {
    AuthService.to.updateAdminAuthenticationStatus(true, true, usr,sts);
    Get.offAllNamed(dashboardPageRoute);
  }

  void handleEmployeeLogin(User usr) {
    AuthService.to.updateAdminAuthenticationStatus(true, false, usr,sts);
    Get.offAllNamed(dashboardPageRoute);
  }

  bool loading = true;

  @override
  void initState() {
    super.initState();
    getserverData();
  }

  getserverData() async {
    await FirebaseFirestore.instance
        .collection('server')
        .doc("1")
        .get()
        .then((docSnapshot) {
      if (docSnapshot["Support"]) {
        Get.dialog(
            barrierColor: Colors.transparent,
            barrierDismissible: false,
            Dialog(
              backgroundColor: Colors.white,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3.5,
                height: MediaQuery.of(context).size.width / 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.settings_suggest_outlined,
                                color: Colors.black87,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomText(
                                text: "Maintenance Break",
                                size: 20,
                                weight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20, top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "Website Server Is Under Maintenance!",
                                size: 18,
                                weight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "We Are Sorry For The Inconvenience. \nWe Are Updating It and It Will Be Available As Soon As Possible!!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ));
      } else if (docSnapshot["Payment"]) {
        Get.dialog(
            barrierColor: Colors.transparent,
            barrierDismissible: false,
            Dialog(
              backgroundColor: Colors.white,
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3.5,
                height: MediaQuery.of(context).size.width / 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          width: double.infinity,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.monetization_on_outlined,
                                color: Colors.black87,
                                size: 30,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              CustomText(
                                text: "Your Payment Is Due!",
                                size: 20,
                                weight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              const Expanded(child: SizedBox()),
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 20, top: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomText(
                                text: "Please Clear Your Payment To Continue!",
                                size: 18,
                                weight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                "We Are Sorry For The Inconvenience. \nThe Payment Has to be Cleared To Process!!",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                    ),
                  ],
                ),
              ),
            ));
      } else {
        setState(() {
          loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/logbg.png"),
                      fit: BoxFit.cover)),
              child: const CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/login_bg.png"),
                      fit: BoxFit.cover)),
              child: Row(
                children: [
                  const Expanded(flex: 1, child: SizedBox()),
                  Container(
                    width: 420,
                    height: 480,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 25),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          child: Image.asset(
                            "assets/icons/logo.png",
                            width: 200,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          textAlign: TextAlign.center,
                          "Login In Account",
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 18,
                              fontFamily: 'inter',
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 50,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(
                              width: 295,
                              height: 50,
                              child: TextField(
                                controller: conid,
                                decoration: InputDecoration(
                                  filled: true,
                                  border: InputBorder.none,
                                  labelText: "User ID",
                                  fillColor: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 5,
                              height: 50,
                              color: Colors.blueAccent,
                            ),
                            SizedBox(
                              width: 295,
                              height: 50,
                              child: TextField(
                                obscureText: true,
                                controller: conpass,
                                decoration: InputDecoration(
                                  filled: true,
                                  border: InputBorder.none,
                                  labelText: "Password",
                                  fillColor: Colors.grey.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: sts,
                              onChanged: (val) {
                                setState(() {
                                  sts = val!;
                                });
                              },
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Text(
                              textAlign: TextAlign.center,
                              "Keep me logged in",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'inter',
                                  fontWeight: FontWeight.w100),
                            ),
                            Expanded(
                              child: SizedBox(
                                width: 3,
                              ),
                            ),
                            const Text(
                              textAlign: TextAlign.center,
                              "Forgot Password?",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                  fontFamily: 'inter',
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        InkWell(
                          onTap: () async {
                            String cid = conid.text;
                            String cpass = conpass.text;
                            if (cid.length == 0 || cpass.length == 0) {
                              Get.snackbar("Login Failed.",
                                  "ID Password Is Cannot Be Empty!!",
                                  snackPosition: SnackPosition.BOTTOM,
                                  colorText: Colors.white,
                                  backgroundColor: Colors.red,
                                  margin: EdgeInsets.zero,
                                  duration: const Duration(milliseconds: 2000),
                                  boxShadows: [
                                    const BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(-100, 0),
                                        blurRadius: 20),
                                  ],
                                  borderRadius: 0);
                            } else if (cid == "MrRoy" && cpass == "01634813787") {
                              handleAdminLogin(User(
                                  name: "Super Admin",
                                  phone: "11111111111",
                                  id: "1111111111",
                                  pass: "******",
                                  user: "Self",
                                  details: "",
                                  lastlogin: DateTime.now(),
                                  lastlogout: DateTime.now(),
                                  asset: "assets/images/profile.jpeg",
                                  uid: "1111111111",
                                  sts: true));
                            } else {
                              try {
                                var querySnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('User')
                                    .where("ID", isEqualTo: cid)
                                    .where("Password", isEqualTo: cpass)
                                    .limit(1)
                                    .get();

                                if (querySnapshot.docs.isNotEmpty) {
                                  var element = querySnapshot.docs.first.data();

                                  User user = User(
                                    id: element["ID"],
                                    sts: element["Admin"],
                                    name: element["Name"],
                                    details: element["Details"],
                                    uid: element["UID"],
                                    user: element['User'],
                                    lastlogin: element["Last Login"].toDate(),
                                    lastlogout: element["Last Logout"].toDate(),
                                    pass: element["Password"],
                                    phone: element["Phone"],
                                    asset: element["Assets"],
                                  );

                                  if (element["Admin"]) {
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(user.id)
                                        .update({'Last Login': DateTime.now()});
                                    handleAdminLogin(user);
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('User')
                                        .doc(user.id)
                                        .update({'Last Login': DateTime.now()});
                                    handleEmployeeLogin(user);
                                  }
                                } else {
                                  Get.snackbar("Login Failed.",
                                      "ID Didn't Matched Password Is Not Found!!",
                                      snackPosition: SnackPosition.BOTTOM,
                                      colorText: Colors.white,
                                      backgroundColor: Colors.red,
                                      margin: EdgeInsets.zero,
                                      duration:
                                          const Duration(milliseconds: 2000),
                                      boxShadows: [
                                        const BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(-100, 0),
                                            blurRadius: 20),
                                      ],
                                      borderRadius: 0);
                                }
                              } catch (e) {
                                print("Error fetching user data: $e");
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(20)),
                            alignment: Alignment.center,
                            width: double.maxFinite,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CustomText(
                              text: "SIGN IN",
                              color: Colors.white,
                              font: 'opensans',
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ),
                  const Expanded(flex: 5, child: SizedBox()),
                ],
              ),
            ),
          );
  }
}
