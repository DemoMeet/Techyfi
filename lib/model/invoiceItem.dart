import 'package:flutter/cupertino.dart';

class InvoiceItemModel {
   String  productId, productName, batch,customerName,customerID, batchid,invoiceno,id;
  // DateTime expireDate
     DateTime invoicedate;
   double boxqty,
      quantity,
      price,
      discount,
      total;
  int serial,sl;
   bool box;

  InvoiceItemModel(
      {required this.batch,
        required this.id,
        required this.price,
        required this.batchid,
        required this.productId,
        required this.productName,
 //       required this.expireDate,
        required this.customerName,
        required this.customerID,
        required this.box,
        required this.discount,
        required this.invoicedate,
        required this.boxqty,
        required this.quantity,
        required this.invoiceno,
        required this.sl,
        required this.serial,
        required this.total});

}
