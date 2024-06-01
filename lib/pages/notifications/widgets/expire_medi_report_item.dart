import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Stock.dart';
import '../../../model/products.dart';
import '../../../model/productstock.dart';

class ExpireMediReportItem extends StatefulWidget {

  Stock mst;
  int index;
  final void Function() fetchDocuments;
  ExpireMediReportItem({
    required this.mst,
    required this.index,
    required this.fetchDocuments,
  });

  @override
  State<ExpireMediReportItem> createState() => _ExpireMediReportItemState();
}

class _ExpireMediReportItemState extends State<ExpireMediReportItem> {


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Text(
                      (widget.mst.serial + 1).toString(),
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                  flex: 1,
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 7),
                    child: Text(
                      "${widget.mst.productName}",
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 7),
                    child: Text(
                      widget.mst.productId,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                // SizedBox(width: 10,),
                // Expanded(
                //   flex: 3,
                //   child: Container(
                //     child: Text(
                //       DateFormat.yMMMd().format(widget.mst.expireDate)
                //       ,
                //       style: TextStyle(
                //           fontSize: 12, color: Colors.red,  fontFamily: 'inter'),
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      widget.mst.productqty.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: Colors.red, fontFamily: 'inter'),
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
