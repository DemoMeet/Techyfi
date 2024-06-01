
import 'package:flutter/cupertino.dart';

class StockReturnItem {
  late  String productId, productName, id;
 // DateTime expireDate;
  late double qty, price,
      discount,
      buyingtotal, returningtotal, deductionval;
  int serial;
  bool check;

  TextEditingController returnqtycontrollers;
  TextEditingController deductioncontrollers;

  StockReturnItem({
    required this.id,
    required this.check,
    required this.returnqtycontrollers,
    required this.deductioncontrollers,
    required this.discount,
 //   required this.expireDate,
    required this.productId,
    required this.productName,
    required this.price,
    required this.qty,
    required this.serial,
    required this.buyingtotal,
    required this.returningtotal,
    required this.deductionval,
  });
}