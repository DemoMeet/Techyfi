import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/model/trashbin.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Return.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/purchaseListModel.dart';

class TrashbinReturnListItem extends StatefulWidget {
  Trashbin cst;
  TrashbinReturnListItem(
      {required this.cst,
      });

  @override
  State<TrashbinReturnListItem> createState() => _TrashbinReturnListItemState();
}

class _TrashbinReturnListItemState extends State<TrashbinReturnListItem> {

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    String ssss = '';
    for (dynamic item in widget.cst.products) {
      String itemName = item['Product Name'].toString();
      int itemQuantity = int.tryParse(item['Quantity'].toString()) ?? 0;
      ssss = '${ssss} $itemName($itemQuantity),';
    }
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.cst.sl+1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.suppliername,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.trash?"Trash":"Returned",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    ssss,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMd().format(widget.cst.returndate),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "৳${widget.cst.totaldeduction}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "৳${widget.cst.receivedamount}",
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
