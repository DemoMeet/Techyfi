import 'package:flutter/cupertino.dart';

class PurchaseListModel {
  String invoiceNo, purchaseID, supplierName, supplierID, accountID;
  late String details;
  int sl;
  String user;
  double total, discount, paid, due;
  late double vat;
  DateTime purchaseDate;
  var stocks = [];

  PurchaseListModel(
      {required this.invoiceNo,
      required this.details,
      required this.vat,
      required this.accountID,
      required this.user,
      required this.purchaseID,
      required this.paid,
      required this.due,
      required this.supplierName,
      required this.discount,
      required this.supplierID,
      required this.sl,
      required this.total,
      required this.purchaseDate});

  PurchaseListModel.withStocks(
      {required this.invoiceNo,
      required this.accountID,
      required this.user,
      required this.purchaseID,
      required this.paid,
      required this.due,
      required this.supplierName,
      required this.discount,
      required this.supplierID,
      required this.sl,
      required this.total,
      required this.purchaseDate,
      required this.stocks});

  List<dynamic> toCsvRow() {
    return [
      sl+1,
      invoiceNo,
      purchaseID,
      supplierName,
      purchaseDate,
      discount,
      total,
      paid,
      due
    ];
  }

  static List<dynamic> parameterNames() {
    return [
      'SL',
      "Invoice No",
      "Purchase ID",
      "Supplier Name",
      "Purchase Date",
      "Discount",
      "Total",
      "Paid",
      "Due"
    ];
  }
}
