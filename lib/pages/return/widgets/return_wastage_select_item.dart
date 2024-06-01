import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/model/wastage.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Return.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/purchaseListModel.dart';

class ReturnWastageSelectItem extends StatefulWidget {
  Wastage cst;
  int index;
  TextEditingController quantitys;
  final void Function() changeVal;
  final void Function() fetchDocuments;

  bool click;
  ReturnWastageSelectItem(
      {required this.cst,
        required this.click,
        required this.quantitys,
        required  this.changeVal,
        required  this.index,required  this.fetchDocuments,
      });

  @override
  State<ReturnWastageSelectItem> createState() => _ReturnWastageSelectItemState();
}

class _ReturnWastageSelectItemState extends State<ReturnWastageSelectItem> {

  @override
  Widget build(BuildContext context) {

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
                    widget.cst.productname,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.quantity.toString(),

                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
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
                  alignment: Alignment.center,
                  child: Text(
                    "৳${widget.cst.totalbuying}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: widget.quantitys,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'(^\d*\.?\d*)')),
                    ],
                    style: TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      disabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabled: widget.cst.check,
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor:  widget.cst.check?Colors.white:light,
                      filled: true,
                    ),
                    onChanged: (val) {
                      setState(() {
                        if(val.isEmpty){
                          widget.quantitys.text = "0";
                        }
                        final number = int.tryParse(val);
                        if (number != null) {
                          final text = number
                              .clamp(0, widget.cst.quantity)
                              .toString();
                          final selection = TextSelection.collapsed(
                            offset: text.length,
                          );
                          widget.quantitys.value =
                              TextEditingValue(
                                text: text,
                                selection: selection,
                              );
                         widget.changeVal();
                        }
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.centerRight,
                  child: Text(
                    "৳${widget.cst.price * double.parse(widget.quantitys.text)}",
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
