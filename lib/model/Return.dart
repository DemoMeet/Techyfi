import 'package:cloud_firestore/cloud_firestore.dart';

class Return {
  List<dynamic> returns;
  Timestamp date, returndate;
  String user;
  bool purchase, wastage;
  double amount, dedamount;
  int sl;
  String invoiceid,
      purchaseid,
      invoiceno,
      id,
      returnid,
      customername,
      suppliername,
      returntype;

  Return(
      {required this.returns,
      required this.user,
      required this.wastage,
      required this.date,
      required this.returndate,
      required this.purchase,
      required this.amount,
      required this.dedamount,
      required this.invoiceid,
      required this.purchaseid,
      required this.invoiceno,
      required this.id,
      required this.returnid,
      required this.customername,
      required this.suppliername,
      required this.returntype,
      required this.sl});
}
