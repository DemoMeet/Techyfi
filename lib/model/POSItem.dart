import 'package:flutter/cupertino.dart';

import 'Stock.dart';
import 'products.dart';

class POSItem {
  Product product;
  Stock selectedStock;
  double total = 0.0, totalstock;
  TextEditingController quantity;
  POSItem(
      {required this.product,
      required this.selectedStock,
      required this.quantity,
      required this.totalstock,
      required this.total});
}
