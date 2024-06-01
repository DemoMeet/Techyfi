import 'package:flutter/foundation.dart';

class Accounts {
  String bankname;
  String accountnum;
  String accountname;
  String user;
  double bal;
  String branch;
  String cashname;
  String cashdetails;
  String uid;
  int sl;
  bool bank, sts;
  Accounts(
      {required this.bankname,
      required this.accountnum,
      required this.accountname,
      required this.bal,
      required this.branch,
      required this.cashname,
      required this.user,
      required this.cashdetails,
      required this.uid,
      required this.sts,
      required this.sl,
      required this.bank});
  Map toJson() => {
        'Bank Name': bankname,
        'Account Number': accountnum,
        'Account Name': accountname,
        'Branch': branch,
        'Cash Name': cashname,
        'UID': uid,
        'User': user,
        'Balance': bal,
        'Cash Details': cashdetails,
        'Status': sts,
        'Bank': bank,
        'sl': sl
      };

  List<dynamic> toCsvRow() {
    return [
      sl + 1,
      bankname,
      cashname,
      accountname,
      cashdetails,
      accountnum,
      branch,
      bank ? "Bank/Mobile Bank" : "Cash Counter",
      bal
    ];
  }

  static List<dynamic> parameterNames() {
    return [
      'SL',
      'Bank Name',
      'Cash Name',
      'Account Holder Name',
      'Cash Details',
      'Account Number',
      'Branch',
      'Type',
      'Balance'
    ];
  }

  factory Accounts.fromJson(dynamic json) {
    return Accounts(
        bankname: json['Bank Name'],
        accountnum: json['Account Number'],
        accountname: json['Account Name'],
        branch: json['Branch'],
        cashname: json['Cash Name'],
        uid: json['UID'],
        user: json['User'],
        bal: json['Balance'],
        cashdetails: json['Cash Details'],
        sts: json['Status'],
        bank: json['Bank'],
        sl: json['sl']);
  }
}
