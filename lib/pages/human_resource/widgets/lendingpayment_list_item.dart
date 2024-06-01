import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/model/LendingPayment.dart';

import '../../../constants/style.dart';
import '../../../model/Expense.dart';

class LendingPaymentListItem extends StatefulWidget {
  LendingPayment cst;
  int index;
  final void Function(String) changeVal;
  final void Function(LendingPayment) editLendingPayment;
  bool click;
  double balance;
  LendingPaymentListItem(
      {required this.cst,
      required this.click,
      required this.changeVal,required this.balance,
      required this.index,
      required this.editLendingPayment});

  @override
  State<LendingPaymentListItem> createState() => _LendingPaymentListItemState();
}

class _LendingPaymentListItemState extends State<LendingPaymentListItem> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height / 16,
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
                  child: Text( widget.cst.lendingpersonname,
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
                    DateFormat.yMMMd()
                        .format(widget.cst.date.toDate())
                        .toString(),
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
                    widget.cst.remarks,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.status=="Debit"?widget.cst.amount.toString():"0.00",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.status=="Credit"?widget.cst.amount.toString():"0.00",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.balance.toString(),
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
