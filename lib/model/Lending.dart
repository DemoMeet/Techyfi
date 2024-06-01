import 'package:cloud_firestore/cloud_firestore.dart';

class Lending {
  String name, phone, lendingpersonid, uid, status, remarks, from;
  String user;

  Map<String, dynamic> lendingperson;
  double amount, returnedamount;

  Timestamp date, returndate;
  int sl;
  Lending(
      {required this.name,
      required this.phone,
      required this.lendingpersonid,
      required this.status,
      required this.uid,
        required this.user,
      required this.remarks,
      required this.sl,
      required this.amount,
      required this.returnedamount,
      required this.date,
      required this.returndate,
      required this.lendingperson,
      required this.from});
}
