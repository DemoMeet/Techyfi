import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:measured_size/measured_size.dart';
import 'package:groceyfi02/model/Supplier.dart';
import 'package:groceyfi02/model/Stock.dart';
import 'package:groceyfi02/widgets/custom_text.dart';
import 'package:path/path.dart' as path;

import '../../constants/stringConst.dart';
import '../../constants/style.dart';
import '../../model/Return.dart';
import '../../model/Single.dart';
import '../../model/customer.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../model/purchaseListModel.dart';
import '../../routing/routes.dart';
import '../../widgets/topnavigationbaredit.dart';

class ReturnPurchaseDetails extends StatefulWidget {
  Return cst;
  Supplier? ct;

  ReturnPurchaseDetails(this.cst, this.ct);
  @override
  State<ReturnPurchaseDetails> createState() => _ReturnPurchaseDetailsState();
}

class _ReturnPurchaseDetailsState extends State<ReturnPurchaseDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    double width = 750.6666666666667, height = 1061.4426666666668;

    Future<List<dynamic>> getItem() async {

      return widget.cst.returns;
    }

    return Scaffold(
      appBar: MyAppBarEdit(height: _height,width: _width),
      body:SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(
              top: 20, left: _width / 6, right: _width / 6, bottom: 20),
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                child: CustomText(
                    text: "Purchase Details",
                    size: 32,
                    weight: FontWeight.bold),
              ),
              Container(
                margin: EdgeInsets.only(top: _height / 25, left: 80, right: 80),
                child: AspectRatio(
                  aspectRatio: 1 / 1.414,
                  child: MeasuredSize(
                    onChange: (Size size) {
                      setState(() {
                        width = size.width;
                        height = size.height;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/invoice_bg.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            margin:
                                EdgeInsets.symmetric(horizontal: width / 11),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: height / 7,
                                  ),
                                  CustomText(
                                    text: "Invoice : ${widget.cst.invoiceno}",
                                    color: buttonbg,
                                    font: 'opensans',
                                    size: width / 40,
                                    weight: FontWeight.bold,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        text: "Return Date: ",
                                        color: Colors.grey,
                                        size: width / 64,
                                        font: 'opensans',
                                      ),
                                      CustomText(
                                        text: DateFormat.yMd()
                                            .format(widget.cst.returndate.toDate()),
                                        color: Colors.black87,
                                        size: width / 64,
                                        font: 'opensans',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: height / 17,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          width: width / 4.5,
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 3,
                                              bottom: 3,
                                              top: 3),
                                          color: dark,
                                          child: CustomText(
                                            text: "Bill From",
                                            color: Colors.white,
                                            weight: FontWeight.bold,
                                            font: 'opensans',
                                            size: width / 64,
                                          ),
                                        ),
                                        Container(
                                          color: dark,
                                          width: width / 4.5,
                                          padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 3,
                                              bottom: 3,
                                              top: 3),
                                          child: CustomText(
                                            text: "Bill To",
                                            color: Colors.white,
                                            weight: FontWeight.bold,
                                            font: 'opensans',
                                            size: width / 64,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 5),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: width / 4.5,
                                          padding: const EdgeInsets.only(
                                            left: 10,
                                            right: 3,
                                            bottom: 3,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                text: pharmacyName,
                                                color: Colors.black87,
                                                weight: FontWeight.bold,
                                                font: 'opensans',
                                                size: width / 64,
                                              ),
                                              CustomText(
                                                text: pharmacyAddress,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text: pharmacyCity,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text: pharmacyNumber,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text: pharmacyEmail,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: width / 4.5,
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 3, bottom: 3),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CustomText(
                                                text:
                                                   widget.cst.customername,
                                                color: Colors.black87,
                                                weight: FontWeight.bold,
                                                font: 'opensans',
                                                size: width / 64,
                                              ),
                                              CustomText(
                                                text:widget.ct!.address,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text:
                                                "${widget.ct!.city} ${widget.ct!.zip}",
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text:
                                               "${widget.ct!.phone1}/${widget.ct!.phone2}",
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text: widget.ct!.email,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: height / 22,
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: height / 106.1),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                            child: Text(
                                              '#',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                            child: Text(
                                              'Item & Description',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            child: Text(
                                              'QTY',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                            child: Text(
                                              'Return Qty',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                            child: Text(
                                              'Price',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                            child: Text(
                                              'Deduction',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                            child: Text(
                                              'Amount',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: height / 3.3,
                                    child: FutureBuilder(
                                      builder: (ctx,AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          return MediaQuery.removePadding(
                                            context: context,
                                            removeTop: true,
                                            child: ListView.builder(
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            (snapshot.data.length - (snapshot.data.length -1)).toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            snapshot.data[index]["Product Name"],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical: 7,
                                                              horizontal:
                                                              10),
                                                          child: Text(
                                                            snapshot.data[index]["Quantity"].toString(),
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize:
                                                              width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical: 7,
                                                              horizontal:
                                                              10),
                                                          child: Text(
                                                            snapshot.data[index]["Price"].toString(),
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize:
                                                              width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            snapshot.data[index]["Return Qty"].toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical: 7,
                                                              horizontal:
                                                              10),
                                                          child: Text(
                                                            snapshot.data[index]["Deduction"].toString(),
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize:
                                                              width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                            ((snapshot.data[index]["Price"]* snapshot.data[index]["Return Qty"])-snapshot.data[index]["Deduction"]).toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign:
                                                                TextAlign.end,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      future: getItem(),
                                    ),
                                  ),
                                  SizedBox(
                                    height: height / 30,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: SizedBox(),
                                          flex: 3,
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'Sub Total',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                        ),
                                        const Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "${widget.cst.amount - widget.cst.dedamount}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                          flex: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: SizedBox(),
                                          flex: 3,
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'Discount',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.cst.dedamount.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: SizedBox(),
                                          flex: 3,
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'Grand Total',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                          flex: 2,
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.cst.amount.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
