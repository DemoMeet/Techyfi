
import 'package:flutter/cupertino.dart';
import 'package:groceyfi02/model/products.dart';

import 'Stock.dart';

class ProductStock {
  Product product;
  List<Stock> stocks = [];
  int sl;
  double inqty, outqty,stockpurprice, stocksaleprice, stock, purcahseprice, saleprice;


  ProductStock({required this.product,required this.sl, required this.stocks, required this.purcahseprice, required this.saleprice, required this.inqty, required this.outqty,
    required this.stockpurprice, required this.stocksaleprice, required this.stock});

  List<dynamic> toCsvRow() {
    return [
      sl+1,
      product.code,
      product.name + "("+product.strength+product.unit+")",
      saleprice,
      purcahseprice,
      inqty,
      outqty,
      stock,
      saleprice,
      stockpurprice
    ];
  }
  static List<dynamic> parameterNames() {
    return [
      'SL',
      'Product Code',
      'Product Name',
      'Sale Price',
      'Pur Price',
      'In QTY',
      'Out QTY',
      'Stock',
      'Stock Price',
      'Stock Pur Price'
    ];
  }
}