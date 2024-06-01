import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../model/products.dart';
import '../../../model/productstock.dart';

class StockReportItem extends StatefulWidget {

  ProductStock mst;
  int index;
  final void Function() fetchDocuments;
  StockReportItem({
    required this.mst,
    required this.index,
    required this.fetchDocuments,
  });

  @override
  State<StockReportItem> createState() => _StockReportItemState();
}

class _StockReportItemState extends State<StockReportItem> {


  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Text(
                      (widget.mst.sl + 1).toString(),
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 7),
                    child: Text(
                      "${widget.mst.product.name}(${widget.mst.product.strength}${widget.mst.product.unit})",
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      "${widget.mst.saleprice}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      "${widget.mst.purcahseprice}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      "${widget.mst.inqty}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      "${widget.mst.outqty}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      "${widget.mst.stock}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      "${widget.mst.stocksaleprice}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      "${widget.mst.stockpurprice}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: .2,
            width: double.infinity,
            color: tabletitle,
          )
        ],
      ),
    );
  }
}
