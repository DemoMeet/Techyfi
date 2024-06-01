import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:groceyfi02/model/Accounts.dart';

class Transactionss {
  String name, id2, remarks, paymentmethod, id1, accountid, type;
  Timestamp date, submitdate;
  String user;
  Map<String, dynamic> account;
  double amount;
  int sl;

  Transactionss(
      {required this.name,
      required this.id2,
      required this.remarks,
      required this.paymentmethod,
        required this.user,
      required this.id1,
      required this.accountid,
      required this.date,
        required this.type,
      required this.submitdate,
      required this.account,
      required this.amount,
      required this.sl});


  List<dynamic> toCsvRow() {
    return [
      sl+1,
      "${account["Bank Name"]} (${account["Account Number"]})",
      account["Cash Name"],
      type,
      date.toDate(),
      amount,
      remarks
    ];
  }
  static List<dynamic> parameterNames() {
    return [
      'SL',
      'Bank Name',
      'Cash Name',
      'Bearer',
      'Type',
      'Date',
      'Amount',
      'Remarks'
    ];
  }
}
