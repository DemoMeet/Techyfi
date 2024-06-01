import 'package:flutter/cupertino.dart';
import 'Stock.dart';
import 'products.dart';

class Invoice {

  TextEditingController quantitycontrollers;
  TextEditingController pricecontrollers;
  TextEditingController discountcontrollers;
  Product productId;
  Stock stock;
  String selectedproduct;
  String selectedtype;
  double availqty;
  //DateTime expiredate;
  TextEditingController total;


  Invoice({
      required this.quantitycontrollers,
    required
    this.pricecontrollers,
    required
    this.discountcontrollers,
    required
    this.productId,
    required
    this.selectedproduct,
    required
    this.stock,
    required
    this.selectedtype,
    required
    this.availqty,
    // required
    // this.expiredate,
    required
    this.total});
}
