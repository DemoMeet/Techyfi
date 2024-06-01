import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../widgets/custom_text.dart';

class AttendanceListItem extends StatefulWidget {
  String name, emplid, intime, outtime, id, worktime;
  DateTime date;
  int sl;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  bool click, out;
  AttendanceListItem({super.key,
    required this.sl,
    required this.name,
    required this.emplid,
    required this.date,
    required this.intime,
    required this.outtime,
    required this.worktime,
    required this.id,
    required this.out,
    required this.click,
    required this.changeVal,
    required this.index,
    required this.fetchDocuments,
  });

  @override
  State<AttendanceListItem> createState() => _AttendanceListItemState();
}

class _AttendanceListItemState extends State<AttendanceListItem> {
  TimeOfDay selectedTime = TimeOfDay.now();

  // showDeleteDialog(BuildContext context) {
  //   Widget cancelButton = TextButton(
  //     child: Text("Cancel"),
  //     onPressed: () {
  //       Navigator.pop(context);
  //     },
  //   );
  //   Widget continueButton = TextButton(
  //     child: Text("Delete", style: TextStyle(color: Colors.red)),
  //     onPressed: () {
  //       FirebaseFirestore.instance
  //           .collection("Customer")
  //           .doc(widget.id)
  //           .delete()
  //           .then((value) {
  //         Navigator.pop(context);
  //         setState(() {
  //           widget.fetchDocuments();
  //         });
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content:
  //               Text("${widget.name} ${widget.name} is Deleted From The List"),
  //         ));
  //       });
  //     },
  //   );
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: AlertDialog(
  //           title: const Text(
  //             "Confirmation To Delete!!",
  //             style: TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //           content: Padding(
  //             padding: const EdgeInsets.only(left: 2.0),
  //             child: Text(
  //                 "Permanently Delete the item ${widget.name}  ${widget.name} from the list? "),
  //           ),
  //           actions: [
  //             cancelButton,
  //             continueButton,
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  _selectTime(BuildContext ctx) async {
    final TimeOfDay? picked = await showTimePicker(
      context: ctx,
      initialTime: selectedTime,
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: ColorScheme.light(
              primary: buttonbg,
              onPrimary: Colors.white,
              onSurface: buttonbg,
            ),
          ),
          child: Column(
            children: [
              child!,
            ],
          ),
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        signoutDialog(context, selectedTime);
      });
    }
  }

  signoutDialog(BuildContext context, TimeOfDay selectedTime) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Sign Out", style: TextStyle(color: Colors.red)),
      onPressed: () {
        var format = DateFormat("HH:mm");
        var one = format.parse(widget.intime);
        var two = format.parse(selectedTime.format(context).toString());
        String myString = two.difference(one).toString();
        FirebaseFirestore.instance.collection('Attendance').doc(widget.id).update({
          'Employee Name': widget.name,
          'Employee ID': widget.emplid,
          'Date': widget.date,
          'In Time': widget.intime,
          'Out Time': selectedTime
              .format(
                context,
              )
              .toString(),
          'Out': true,
          'Work Time': myString.replaceAll(RegExp(':00.000000'), ' Hours'),
        }).then((value) {
          Navigator.pop(context);
          widget.fetchDocuments();
        });
      },
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: AlertDialog(
                title:  const Text(
                  "Sign Out Employee",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Row(
                    children: [
                      CustomText(
                        text: widget.name,
                        weight: FontWeight.bold,
                        size: 16,
                      ),
                      const Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 1,
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _selectTime(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.shade200,
                            ),
                            child: CustomText(
                              text: selectedTime
                                  .format(
                                    context,
                                  )
                                  .toString(),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.sl + 1).toString(),
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
                    "${widget.name}",
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(
                    DateFormat.yMMMd().format(widget.date),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(
                    widget.intime,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: !widget.out
                    ? Container(
                        width: 40,
                        margin: const EdgeInsets.only(left: 7, bottom: 6, right: 7),
                        child: ElevatedButton(
                          onPressed: () {
                            signoutDialog(context, selectedTime);
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          child: const Text(
                            "Sign Out",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontFamily: 'inter'),
                          ),
                        ))
                    : Container(
                        margin: const EdgeInsets.only(left: 7),
                        child: Text(
                          widget.outtime,
                          style: TextStyle(
                              fontSize: 12,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(left: 7),
                  child: Text(
                    widget.worktime,
                    style: TextStyle(
                      fontSize: 12,
                      color: tabletitle,
                      fontFamily: 'inter',
                    ),
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
                                const InkWell(
                                    child: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                )),
                                InkWell(
                                    onTap: () {
                                      //showDeleteDialog(context);
                                    },
                                    child: const Icon(
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
            margin: EdgeInsets.only(top: 6),
            width: double.infinity,
            color: tabletitle,
          )
        ],
      ),
    );
  }
}
