import 'package:flutter/cupertino.dart';

class Stock {
  late String productId, productName;
  late DateTime expireDate;
  late double
      productqty,
      manuPrice,
      price,
      discount,
      total,
      inqty,
      outqty;
  int serial;

  Stock.forInvoice({
    required this.discount,
    required this.expireDate,
    required this.productId,
    required this.productName,
    required this.price,
    required this.productqty,
    required this.serial,
    required this.total,
  });
  Stock(
      {
      required this.productId,
      required this.productName,
      required this.expireDate,
      required this.price,
      required this.manuPrice,
      required this.productqty,
      required this.serial,
      required this.total});

  Stock.withqty(
      {
      required this.outqty,
      required this.inqty,
      required this.productId,
      required this.productName,
      required this.expireDate,
      required this.price,
      required this.manuPrice,
      required this.productqty,
      required this.serial,
      required this.total});
}
