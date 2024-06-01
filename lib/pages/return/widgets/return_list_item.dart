import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Stock.dart';
import '../../../model/StockReturnItem.dart';
import '../../../model/invoiceListModel.dart';
import '../../../model/purchaseListModel.dart';

class ReturnListItem extends StatefulWidget {
  StockReturnItem cst;
  int index;
  Function() updatetotals;
  ReturnListItem({
    required  this.cst,
    required this.updatetotals,
    required this.index,
  });

  @override
  State<ReturnListItem> createState() => _ReturnListItemState();
}

class _ReturnListItemState extends State<ReturnListItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.blueAccent,
                    value: widget.cst.check,
                    onChanged: (bool? value) {
                      setState(() {
                        widget.cst.check = value!;
                        if(!value){
                          widget.cst.returningtotal= 0;
                          widget.cst.returnqtycontrollers = TextEditingController(text: "0");
                          widget.cst.deductioncontrollers = TextEditingController(text: "0");
                        }
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.productName,
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
                    widget.cst.qty.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
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
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: TextFormField(
                    controller: widget.cst.returnqtycontrollers,
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
                          widget.cst.returnqtycontrollers.text = "0";
                        }
                        final number = int.tryParse(val);
                        // if (widget.cst.box) {
                        //   if (number != null) {
                        //     final text =
                        //         number.clamp(0, widget.cst.boxqty).toString();
                        //     final selection = TextSelection.collapsed(
                        //       offset: text.length,
                        //     );
                        //     widget.cst.returnqtycontrollers.value =
                        //         TextEditingValue(
                        //       text: text,
                        //       selection: selection,
                        //     );
                        //   }
                        //
                        //   widget.cst.returningtotal = (double.parse(widget
                        //       .cst.returnqtycontrollers.text
                        //       .toString()) *
                        //       widget.cst.perPrice)-double.parse( widget.cst.deductioncontrollers.text);
                        // } else {
                          if (number != null) {
                            final text = number
                                .clamp(0, widget.cst.qty)
                                .toString();
                            final selection = TextSelection.collapsed(
                              offset: text.length,
                            );
                            widget.cst.returnqtycontrollers.value =
                                TextEditingValue(
                              text: text,
                              selection: selection,
                            );
                          }
                          widget.cst.returningtotal = (double.parse(widget
                              .cst.returnqtycontrollers.text
                              .toString()) *
                              widget.cst.price)-double.parse( widget.cst.deductioncontrollers.text);
                      //  }
                        widget.updatetotals();
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.price.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
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
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: TextFormField(
                    controller: widget.cst.deductioncontrollers,
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
                          widget.cst.deductioncontrollers.text = "0";
                        }
                        final number = int.tryParse(val);
                        if (number != null) {
                          final text =
                          number.clamp(0, (double.parse(widget
                              .cst.returnqtycontrollers.text
                              .toString()) *
                              widget.cst.price)).toString();
                          final selection = TextSelection.collapsed(
                            offset: text.length,
                          );
                          widget.cst.deductioncontrollers.value =
                              TextEditingValue(
                                text: text,
                                selection: selection,
                              );
                        }
                        widget.cst.returningtotal = (double.parse(widget
                            .cst.returnqtycontrollers.text
                            .toString()) *
                            widget.cst.price)-double.parse( widget.cst.deductioncontrollers.text);

                        widget.updatetotals();
                      });

                    },
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.returningtotal.toString(),
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
