import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/customer.dart';
import '../../../model/invoiceListModel.dart';

class CustomerLedgerItem extends StatefulWidget {
  InvoiceListModel cst;
  int index;
  var balancelist, descriptionlist;
  CustomerLedgerItem({
    required this.cst,
    required this.index,
    this.descriptionlist,
    this.balancelist,
  });

  @override
  State<CustomerLedgerItem> createState() => _CustomerLedgerItemState();
}

class _CustomerLedgerItemState extends State<CustomerLedgerItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 10, right: 10, top: 10, bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.cst.sl + 1).toString(),
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
                    DateFormat('dd/MM/yyyy').format(widget.cst.invoiceDate),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.descriptionlist[widget.index],
                    textAlign: TextAlign.center,
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
                    widget.cst.paid != 0 ? "0" : widget.cst.total.toString(),
                    textAlign: TextAlign.center,
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
                    widget.cst.paid.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 7, right: 10),
                  child: Text(
                    widget.balancelist[widget.index].toString(),
                    textAlign: TextAlign.right,
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
