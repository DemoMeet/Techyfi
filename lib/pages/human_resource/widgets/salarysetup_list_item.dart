import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Salary.dart';

class SalarySetupListItem extends StatefulWidget {
  Salary cst;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  final void Function(Salary) onEditSalarySetup;
  bool click;
  SalarySetupListItem(
      {required this.cst,
        required  this.click,
        required  this.changeVal,
        required  this.index, required this.fetchDocuments,required  this.onEditSalarySetup,
      });

  @override
  State<SalarySetupListItem> createState() => _SalarySetupListItemState();
}

class _SalarySetupListItemState extends State<SalarySetupListItem> {

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      height: MediaQuery.of(context).size.height/16,
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
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
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.epnname,
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
                    DateFormat.yMMMM()
                        .format(widget.cst.salarymonth.toDate())
                        .toString()
                    ,
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
                  child: Text(widget.cst.salarytype
                    ,
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
                    widget.cst.workinghours,
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
                    "${widget.cst.workingdays}/${widget.cst.totaldays}",
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
                    widget.cst.from,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex:3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  alignment: Alignment.center,
                  child: Text(
                    widget.cst.grosssalary.toString(),
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
                            margin: EdgeInsets.only(right: _width/35, left: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey.shade200,
                            ),
                            child: _width>830?Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                    onTap: (){
                                      widget.onEditSalarySetup(widget.cst);
                                    },
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: _width/70,
                                    )),
                                InkWell(
                                    onTap: (){

                                    },
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: _width/70,
                                    )),
                              ],
                            ):Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: (){
                                    widget.onEditSalarySetup(widget.cst);
                                  },
                                    child: Icon(
                                      Icons.edit_outlined,
                                      size: _width/55,
                                    )),
                                InkWell(
                                    onTap: (){

                                    },
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: _width/55,
                                    )),
                              ],
                            ),
                          ),
                      )
                      : Align(
                    alignment: Alignment.center,
                        child: Container(
                            margin: EdgeInsets.only(right: _width/25),
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
