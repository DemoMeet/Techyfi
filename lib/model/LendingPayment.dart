import 'package:cloud_firestore/cloud_firestore.dart';

class LendingPayment {
  String lendingpersonname,lendingpersonid, lendingid, status, remarks, uid;
  String user;

  double amount;

  Timestamp date;
  int sl;
  LendingPayment(
      {required this.lendingpersonname,
      required this.lendingpersonid,
      required this.status,
      required this.uid,
        required this.user,
      required this.remarks,
      required this.sl,
      required this.amount,
      required this.date,
      required this.lendingid});
}
