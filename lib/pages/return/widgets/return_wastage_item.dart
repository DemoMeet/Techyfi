import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/model/wastage.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Return.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/purchaseListModel.dart';

class ReturnWastageItem extends StatefulWidget {
  Wastage cst;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;

  bool click;
  ReturnWastageItem(
      {required this.cst,
        required this.click,
        required  this.changeVal,
        required  this.index,required  this.fetchDocuments,
      });

  @override
  State<ReturnWastageItem> createState() => _ReturnWastageItemState();
}

class _ReturnWastageItemState extends State<ReturnWastageItem> {

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
                    widget.cst.productid,
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
                    widget.cst.productname,
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
                    "৳${widget.cst.price}",
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
                    widget.cst.quantity.toString(),
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
                    "৳${widget.cst.totalbuying}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child:Container(
                  margin: EdgeInsets.only(right: 20),
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.blueAccent,
                    value: widget.cst.check,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.cst.check = value!;
                      });
                    },
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
