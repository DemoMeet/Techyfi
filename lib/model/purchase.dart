import 'package:flutter/cupertino.dart';
import 'Single.dart';
import 'products.dart';

class Purchase {
  TextEditingController boxqtycontrollers;
  TextEditingController supplierpricecontrollers;
  TextEditingController boxmrpcontrollers;
  Product productId;
  late String pid;
  String selectedproduct;
  double stockquantity;
 // DateTime expiredate;
  TextEditingController totalPurpricecontroller;

  Purchase.withid({required this.boxqtycontrollers,
    required this.supplierpricecontrollers,
    required this.boxmrpcontrollers,
    required this.productId,
    required this.selectedproduct,
    required this.stockquantity,
  //  required this.expiredate,
    required this.totalPurpricecontroller,required this.pid});
  Purchase(
      {
        required this.boxqtycontrollers,
        required this.supplierpricecontrollers,
        required this.boxmrpcontrollers,
        required this.productId,
        required this.selectedproduct,
        required this.stockquantity,
 //       required this.expiredate,
        required this.totalPurpricecontroller});
}
