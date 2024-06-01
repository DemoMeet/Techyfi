import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Attendance {
  String
  name,
      emplid,intime,outtime,
      id,worktime;
  int sl;
  Timestamp date;
  String user;
  bool out;

  Attendance({
      required this.name,
      required this.emplid,
    required
    this.date,
    required this.user,
    required
    this.intime,
    required
    this.outtime,
    required
    this.id,
    required
    this.worktime,
    required
    this.out,
    required
    this.sl});
}