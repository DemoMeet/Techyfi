import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/style.dart';

class GeneralListItemWithDetails extends StatefulWidget {
  String name, details, status, sl, parent, id;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  bool click;
  GeneralListItemWithDetails(
      {required this.sl,
      required this.name,
      required this.status,
      required this.details,
      required this.click,
      required this.changeVal,
      required this.index,
      required this.parent,
      required this.id,
      required this.fetchDocuments});

  @override
  State<GeneralListItemWithDetails> createState() =>
      _GeneralListItemWithDetailsState();
}

class _GeneralListItemWithDetailsState
    extends State<GeneralListItemWithDetails> {

  showDeleteDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed: () {
        FirebaseFirestore.instance
            .collection(widget.parent)
            .doc(widget.id)
            .delete()
            .then((value) {
          Navigator.pop(context);
          setState(() {
            widget.fetchDocuments();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("${widget.name} is Deleted From The List"),
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
            title: Text(
              "Confirmation To Delete!!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text(
                  "Permanently Delete the item ${widget.name} from the list? "),
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
                    (int.parse(widget.sl) + 1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 25),
                  child: Text(
                    widget.name,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 5,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 25),
                  child: Text(
                    widget.details,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 8,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 25),
                  child: Text(
                    widget.status,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: widget.click
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width / 25,
                                left: 20),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.grey.shade200,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                    child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                )),
                                InkWell(
                                    onTap: () {
                                      showDeleteDialog(context);
                                    },
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                    )),
                              ],
                            ),
                          ),
                        )
                      : Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width / 25),
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
