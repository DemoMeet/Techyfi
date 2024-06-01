import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/BalanceTransfer.dart';
import '../../../model/issuedCheque.dart';

class ChequeTransactionListItem extends StatefulWidget {
  IssuedCheque cst;
  int index;
  final void Function(String) changeVal;
  final void Function(IssuedCheque, bool) onupdateIssuedCheque;
  bool click;
  ChequeTransactionListItem(
      {required this.cst,
      required this.onupdateIssuedCheque,
      required this.click,
      required this.changeVal,
      required this.index});

  @override
  State<ChequeTransactionListItem> createState() =>
      _ChequeTransactionListItemState();
}

class _ChequeTransactionListItemState extends State<ChequeTransactionListItem> {
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
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.name,
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
                    widget.cst.accountname,
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
                    widget.cst.chequeno,
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
                    DateFormat.yMMMd().format(widget.cst.date).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.payment ? "Debit" : "Credit",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.amount.toString(),
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
                    widget.cst.status,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: widget.click
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin:
                                EdgeInsets.only(right: _width / 35, left: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey.shade200,
                            ),
                            child: _width > 830
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      widget.cst.status == "Issued"
                                          ? InkWell(
                                              onTap: () {
                                                widget.onupdateIssuedCheque(widget.cst, true);
                                              },
                                              child: Icon(
                                                Icons.check,
                                                size: _width / 70,
                                              ))
                                          : SizedBox(),
                                      widget.cst.status == "Issued"
                                          ? InkWell(
                                              onTap: () {
                                                widget.onupdateIssuedCheque(widget.cst, false);},
                                              child: Icon(
                                                Icons.close,
                                                size: _width / 70,
                                              ))
                                          : SizedBox(),
                                      InkWell(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: _width / 70,
                                          )),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      widget.cst.status == "Issued"
                                          ? InkWell(
                                              onTap: () {
                                                widget.onupdateIssuedCheque(widget.cst, true);},
                                              child: Icon(
                                                Icons.check,
                                                size: _width / 55,
                                              ))
                                          : SizedBox(),
                                      widget.cst.status == "Issued"
                                          ? InkWell(
                                              onTap: () {
                                                widget.onupdateIssuedCheque(widget.cst, false);},
                                              child: Icon(
                                                Icons.close,
                                                size: _width / 55,
                                              ))
                                          : SizedBox(),
                                      InkWell(
                                          onTap: () {},
                                          child: Icon(
                                            Icons.delete_outline,
                                            size: _width / 55,
                                          )),
                                    ],
                                  ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(right: _width / 25),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey.shade200,
                            ),
                            child: InkWell(
                                onTap: () {
                                  widget.changeVal(widget.index.toString());
                                },
                                child: const Icon(
                                  Icons.more_vert,
                                  size: 18,
                                )),
                          ),
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
