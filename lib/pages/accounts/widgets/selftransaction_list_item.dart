import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/BalanceTransfer.dart';

class SelfTransactionListItem extends StatefulWidget {
  BalanceTransfer cst;
  int index;
  final void Function(String) changeVal;
  final void Function(BalanceTransfer) editSelfTransactionVoucher;
  bool click;
  SelfTransactionListItem(
      {required this.cst,
      required this.click,
      required this.changeVal,
      required this.index,
      required this.editSelfTransactionVoucher});

  @override
  State<SelfTransactionListItem> createState() => _SelfTransactionListItemState();
}

class _SelfTransactionListItemState extends State<SelfTransactionListItem> {
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
                flex:1,
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
                  child: Text(widget.cst.faccount["Bank"]?"${widget.cst.faccount["Bank Name"]} (${widget.cst.faccount["Account Number"]})":widget.cst.faccount["Cash Name"],
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(widget.cst.taccount["Bank"]?"${widget.cst.taccount["Bank Name"]} (${widget.cst.taccount["Account Number"]})":widget.cst.taccount["Cash Name"],
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
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.amount.toString(),
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
                                      InkWell(
                                          onTap: () {
                                            widget.editSelfTransactionVoucher(widget.cst);
                                          },
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: _width / 70,
                                          )),
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
                                      InkWell(
                                          onTap: () {
                                            widget.editSelfTransactionVoucher(widget.cst);
                                          },
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: _width / 55,
                                          )),
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
