import 'package:cloud_firestore/cloud_firestore.dart';

class BalanceTransfer {
  String faid,taid, uid, remarks;
  Timestamp date;
  String user;
  Map<String, dynamic> faccount;
  Map<String, dynamic> taccount;
  double amount;
  int sl;
  BalanceTransfer(
      {required this.uid,
      required this.faccount,
      required this.remarks,
      required this.taccount,
        required this.user,
      required this.faid,
        required this.taid,
      required this.date,
      required this.amount,
      required this.sl});
}
