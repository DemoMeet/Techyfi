import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/purchaseListModel.dart';

class InvoiceReportItem extends StatefulWidget {
  InvoiceListModel cst;
  int index;
  InvoiceReportItem(
      {required this.cst,
        required this.index,
      });

  @override
  State<InvoiceReportItem> createState() => _InvoiceReportItemState();
}

class _InvoiceReportItemState extends State<InvoiceReportItem> {

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.cst.sl+1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.invoiceNo,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.invoiceID,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.customerName,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMd().format(widget.cst.invoiceDate),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "৳${widget.cst.total}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.user,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: .2,
            margin: EdgeInsets.only(top: 10),
            width: double.infinity,
            color: tabletitle,
          )
        ],
      ),
    );
  }
}
