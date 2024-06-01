import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class InvoiceListModel {
  String invoiceNo, invoiceID, customerName, customerID;
  int sl;
  String user;
  late String accountID;
  double total, discount, paid, due;
  late double profit;
  DateTime invoiceDate;
  bool retn;
  var stocks = [];

  InvoiceListModel(
      {required this.invoiceNo,
      required this.paid,
      required this.due,
      required this.invoiceID,
        required this.accountID,
      required this.customerName,
        required this.retn,
      required this.discount,
        required this.user,
      required this.customerID,
      required this.sl,
        required this.profit,
      required this.total,
      required this.invoiceDate});

  InvoiceListModel.withStocks(
      {required this.invoiceNo,
      required this.paid,
      required this.due,
      required this.invoiceID,
      required this.customerName,
      required this.discount,
        required this.retn,
      required this.customerID,
        required this.user,
      required this.sl,
      required this.total,
      required this.invoiceDate,
      required this.stocks});


  static List<dynamic> parameterNames(bool ss) {
    return [
      'SL',
      ss?'Customer':'Supplier',
      'Date',
      'Description',
      'Debit',
      'Credit',
      'Balance',
    ];
  }

  List<dynamic> toCsvRow(var desc, bala) {
    return [
      sl+1,
      customerName,
      DateFormat('dd/MM/yyyy').format(invoiceDate),
      desc[sl],
      paid == 0 ? total : 0,
      paid,
      bala[sl]
    ];
  }


  List<dynamic> toCsvRowcc() {
    return [
      sl+1,
      invoiceNo,
      invoiceID,
      customerName,
      invoiceDate,
      total + discount,
      discount,
      total,
      paid,
      due
    ];
  }
  static List<dynamic> parameterNamescc() {
    return [
      'SL',
      "Invoice No",
      "Invoice ID",
      "Customer Name",
      "Invoice Date",
      "Sub Total",
      "Discount",
      "Total",
      "Paid",
      "Due"
    ];
  }
}
