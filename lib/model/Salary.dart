import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class Salary {
  String epnname, empid, salarytype, uid, workinghours, basicsalary, from;
  int sl;
  Timestamp salarymonth, attenstart, attenend, date;
  double grosssalary, workingdays, totaldays;
  String user;
  var benifits = [];

  Salary(
      {required this.epnname,
      required this.empid,
      required this.salarytype,
      required this.uid,
      required this.workinghours,
      required this.sl,
      required this.salarymonth,
      required this.from,
        required this.user,
      required this.attenstart,
      required this.attenend,
      required this.date,
      required this.basicsalary,
      required this.grosssalary,
      required this.workingdays,
      required this.totaldays,
      required this.benifits});

  Map toJson() => {
        'Employee Name': epnname,
        'Employee ID': empid,
        'Salary Type': salarytype,
        'UID': uid,
        'Basic Salary': basicsalary,
        'Salary Month': salarymonth,
        'Atte. Start Date': attenstart,
        'Atte. End Date': attenend,
        'Working Days': workingdays,
        'Total Days': totaldays,
        'From': from,
    'User':user,
        'Working Hours': workinghours,
        'Gross Salary': grosssalary,
        'Benefits': benifits,
        'Date': date,
        'sl': sl
      };

  factory Salary.fromJson(dynamic json) {
    return Salary(
        epnname: json['Employee Name'],
        empid: json['Employee ID'],
        salarytype: json['Salary Type'],
        uid: json['UID'],
        basicsalary: json['Basic Salary'],
        salarymonth: json['Salary Month'],
        from: json['From'],user: json['User'],
        attenstart: json['Atte. Start Date'],
        attenend: json['AtteEnd Date'],
        workingdays: json['Working Days'],
        totaldays: json['Total Days'],
        workinghours: json['Working Hours'],
        grosssalary: json['Gross Salary'],
        benifits: json['Benefits'],
        date: json['Date'],
        sl: json['sl']);
  }
}
