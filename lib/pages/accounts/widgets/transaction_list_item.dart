import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Accounts.dart';
import '../../../model/Supplier.dart';
import '../../../model/Transaction.dart';
import '../../../model/customer.dart';

class TransactionListItem extends StatefulWidget {
  Transactionss cst;
  int index;
  final void Function() fetchDocuments;
  TransactionListItem(
      {required this.cst,
        required   this.index,required  this.fetchDocuments
      });

  @override
  State<TransactionListItem> createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem> {

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
                flex:1,
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
                flex: 6,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.account["Bank"]?"${widget.cst.account["Bank Name"]} (${widget.cst.account["Account Number"]})":widget.cst.account["Cash Name"],
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
                flex:2,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(widget.cst.type,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex:4,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(DateFormat('h:MMa dd-MM-yyyy').format(widget.cst.date.toDate()),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.amount.toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(
                    widget.cst.remarks,
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
