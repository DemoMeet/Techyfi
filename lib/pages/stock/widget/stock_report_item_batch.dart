import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/Stock.dart';
import '../../../model/products.dart';
import '../../../model/productstock.dart';
import '../../../model/nav_bools.dart';
import '../../../routing/routes.dart';

class StockReportItemBatch extends StatefulWidget {
  Stock mst;
  int index;
  Navbools nn;
  final void Function() fetchDocuments;
  StockReportItemBatch({
    required this.mst,
    required this.index,
    required this.nn,
    required this.fetchDocuments,
  });

  @override
  State<StockReportItemBatch> createState() => _StockReportItemBatchState();
}

class _StockReportItemBatchState extends State<StockReportItemBatch> {
  String strength = "", unit = "";
  @override
  void initState() {
    getData();
    // TODO: implement initState
    super.initState();
  }

  getData() async {
    await FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.mst.productId)
        .get()
        .then((medi) {
      strength = medi["Strength"];
      unit = medi["Unit Name"];
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    var outputFormat = DateFormat('dd/MM/yyyy');
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Text(
                      (widget.mst.serial + 1).toString(),
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 7),
                        child: Text(
                          "${widget.mst.productName}(${strength}${unit})",
                          style: TextStyle(
                              fontSize: 12,
                              color: tabletitle,
                              fontFamily: 'inter'),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                      widget.mst.productqty == 0
                          ? InkWell(
                              onTap: () async {
                                await FirebaseFirestore.instance.collection('Stock').doc(widget.mst.productId).delete();
                                widget.fetchDocuments();
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5)),
                                child: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ))
                          : const SizedBox(),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ),
                // Expanded(
                //   flex: 2,
                //   child: Container(
                //     child: Text(
                //       outputFormat.format(widget.mst.expireDate),
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //           fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                //     ),
                //   ),
                // ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      "${widget.mst.inqty}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: Text(
                      "${widget.mst.outqty}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Text(
                      "${widget.mst.productqty}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                    ),
                  ),
                ),
              ],
            ),
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
