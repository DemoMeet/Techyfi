import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/style.dart';

class EmployeeListItem extends StatefulWidget {
  String fname,
      lname,
      phone,
      email,
      address1,
      salary,
      blood,
      designation,
      id,
      imgurl;
  int sl;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  bool click, img;
  EmployeeListItem({
    required this.sl,
    required this.fname,
    required this.lname,
    required this.phone,
    required this.email,
    required this.address1,
    required this.salary,
    required this.blood,
    required this.designation,
    required this.id,
    required this.img,
    required this.imgurl,
    required this.click,
    required this.changeVal,
    required this.index,
    required this.fetchDocuments,
  });

  @override
  State<EmployeeListItem> createState() => _EmployeeListItemState();
}

class _EmployeeListItemState extends State<EmployeeListItem> {
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
            .collection("Customer")
            .doc(widget.id)
            .delete()
            .then((value) {
          Navigator.pop(context);
          setState(() {
            widget.fetchDocuments();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "${widget.fname} ${widget.lname} is Deleted From The List"),
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
                  "Permanently Delete the item ${widget.fname}  ${widget.lname} from the list? "),
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
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.sl + 1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "${widget.fname} ${widget.lname}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.designation,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.phone,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.email,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.blood,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter',),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.salary,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.address1,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex:2,
                child: Container(
                    margin: EdgeInsets.only(left: 7),
                    child: widget.img
                        ? Image.network(
                            widget.imgurl,
                      fit: BoxFit.fitHeight,
                      width: 50,
                      height: 70,
                          )
                        : Image.asset(
                            "assets/images/def_employee.jpg",
                            width: 70,
                            height: 70,
                          )),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: widget.click
                      ? Align(
                          alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width / 35,
                                left: 10),
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
            width: double.infinity,
            color: tabletitle,
          )
        ],
      ),
    );
  }
}
