import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/style.dart';
import '../model/general.dart';

class GeneralListItem extends StatefulWidget {
  String parent;
  General gs;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  final void Function(General) onEditGeneral;
  bool click;
  GeneralListItem(
      {required this.gs,
        required this.click,
        required this.changeVal,
        required this.onEditGeneral,
        required this.index,
        required this.parent,required this.fetchDocuments
      });

  @override
  State<GeneralListItem> createState() => _GeneralListItemState(
  );
}

class _GeneralListItemState extends State<GeneralListItem> {


 showDeleteDialog(BuildContext context) {
   Widget cancelButton = TextButton(
     child: Text("Cancel"),
     onPressed:  () {Navigator.pop(context);},
   );
   Widget continueButton = TextButton(
     child: Text("Delete", style: TextStyle(color: Colors.red)),
     onPressed:  () {
       FirebaseFirestore.instance.collection(widget.parent).doc(widget.gs.id).delete().then((value) {
         Navigator.pop(context);
         setState(() {
           widget.fetchDocuments();
         });
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
           content: Text("${widget.gs.name} is Deleted From The List"),
         ));
       });
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
             child: Text("Permanently Delete the item ${widget.gs.name} from the list? "),
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
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.gs.sl+1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 25),
                  child: Text(
                    widget.gs.name,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 25),
                  child: Text(
                    widget.gs.status,
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
                          margin: EdgeInsets.only(right: _width/35, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:Colors.grey.shade200,
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
                                  widget.onEditGeneral(widget.gs);
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
                                onTap: (){
                                  widget.onEditGeneral(widget.gs);
                                },
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
                                child: Icon(
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
