import 'package:flutter/foundation.dart';

class Employee {
  String fname,
      lname,
      phone,
      email,
      address1,
      address2,
      salary,
      country,
      city,
      zip,
      status,
      blood,
      designation,
      designationid,
      rate,
      id,
      imgurl;
  int sl;
  String user;
  bool img;

  Employee(
      {required this.fname,
      required this.lname,
      required this.phone,
      required this.email,
      required this.address1,
      required this.address2,
      required this.salary,
      required this.country,
      required this.city,
          required this.user,
      required this.zip,
      required this.status,
      required this.blood,
      required this.designation,
      required this.designationid,
      required this.rate,
      required this.id,
      required this.imgurl,
      required this.sl,
      required this.img});
}
