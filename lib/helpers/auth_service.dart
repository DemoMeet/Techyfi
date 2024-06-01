import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:groceyfi02/model/UserImage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/User.dart';

class AuthService extends GetxController {
  static AuthService get to => Get.find();

  RxBool isAuthenticated = false.obs;
  RxBool admin = false.obs;
  User? _user;
  RxBool isfirsttime = true.obs;


  void setisfirsttime(){
    isfirsttime = false.obs;
  }


  User? get user => _user;
  @override
  void onInit() {
    super.onInit();
    loadAuthenticationStatus();
  }

  void updateAdminAuthenticationStatus(bool status1, bool status2, User usr,bool reme) {
    isAuthenticated.value = status1;
    admin.value = status2;
    if(reme){
      saveAuthenticationStatus(status1, status2, usr);
    }_user=usr;
  }

  bool isAdmin() {
    return admin.value;
  }

  Future<void> Logout() async {
    isAuthenticated.value = false;
    admin.value = false;
    if(_user?.id != "1111111111"){
      FirebaseFirestore.instance.collection('User').doc(_user?.id).update({'Last Logout':DateTime.now()});
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('Admin');
    await prefs.remove('dataee');
  }

  Future<void> loadAuthenticationStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedStatus = prefs.getBool('isAuthenticated') ?? false;
    bool adminStatus = prefs.getBool('Admin') ?? false;

    String jsonString = prefs.getString('dataee') ?? '';
    if (jsonString.isNotEmpty) {
      try {
        _user = User.fromJson(json.decode(jsonString));
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    }

    isAuthenticated.value = savedStatus;
    admin.value = adminStatus;
  }
  Future<void> saveAuthenticationStatus(bool status1, bool status2, User usr) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isAuthenticated', status1);
    await prefs.setBool('Admin', status2);
    await prefs.setString('dataee', json.encode(usr.toJson()));

  }
}