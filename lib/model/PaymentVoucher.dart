import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentVoucher {
  String id, name, uid, voucherid, remarks, from,user;
  Timestamp date, selecteddate;
  double amount;
  bool payment;
  int sl;
  PaymentVoucher(
      {required this.uid,
      required this.name,
      required this.remarks,
      required this.payment,
      required this.id,
      required this.voucherid,
      required this.selecteddate,
      required this.from,
        required this.user,
      required this.date,
      required this.amount,
      required this.sl});
}
