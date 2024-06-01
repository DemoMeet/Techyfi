import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../model/Accounts.dart';
import '../../../model/Supplier.dart';
import '../../../model/customer.dart';

class AccountsListItem extends StatefulWidget {
  Accounts cst;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  final void Function(Accounts) onEditManufact;
  bool click;
  AccountsListItem(
      {required this.cst,
        required   this.click,
        required   this.changeVal,
        required   this.index,required  this.fetchDocuments,required this.onEditManufact
      });

  @override
  State<AccountsListItem> createState() => _AccountsListItemState();
}

class _AccountsListItemState extends State<AccountsListItem> {
 showDeleteDialog(BuildContext context) {
   Widget cancelButton = TextButton(
     child: Text("Cancel"),
     onPressed:  () {Navigator.pop(context);},
   );
   Widget continueButton = TextButton(
     child: Text("Delete", style: TextStyle(color: Colors.red)),
     onPressed:  () {
       // FirebaseFirestore.instance.collection("Accounts").doc(widget.cst.uid).delete().then((value) {
       //   Navigator.pop(context);
       //   setState(() {
       //     widget.fetchDocuments();
       //   });
       // });
     },
   );

   showDialog(
     context: context,
     builder: (BuildContext context) {
       return Padding(
         padding: const EdgeInsets.all(10.0),
         child: AlertDialog(
           title: const Text("Confirmation To Delete!!", style: TextStyle(fontWeight: FontWeight.bold),),
           content: Padding(
             padding: const EdgeInsets.only(left: 2.0),
             child: Text("Permanently Delete the item ${widget.cst.bankname} from the list? "),
           ),
           actions: [
             cancelButton,
             continueButton,
           ],
         ),
       );
     },
   );
 }

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
                flex: 3,
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
                flex: 7,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                   widget.cst.bank? widget.cst.bankname:widget.cst.cashname,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex:7,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.bank? widget.cst.accountname: widget.cst.cashdetails,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.accountnum,
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
                    widget.cst.branch,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex:5,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.bank?"Bank/Mobile Bank":"Cash Counter",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.cst.bal.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
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
                                  widget.onEditManufact(widget.cst);
                                },
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: _width/70,
                                  )),
                              InkWell(
                                  onTap: (){
                                    showDeleteDialog(context);
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
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: _width/55,
                                  )),
                              InkWell(
                                  onTap: (){
                                    showDeleteDialog(context);
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
