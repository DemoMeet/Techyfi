import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  String uid, expensename, expenseid, others, from;
  String user;
  Timestamp date;
  double amount;
  int sl;
  Expense({required this.uid, required this.expensename, required this.expenseid, required this.others, required this.from,
    required this.user,
    required this.date, required this.amount, required this.sl});
}
