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
import '../../model/Single.dart';
import '../../model/customer.dart';
import '../../model/invoiceListModel.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../model/purchaseListModel.dart';
import '../../routing/routes.dart';
import '../../widgets/topnavigationbaredit.dart';

class InvoiceDetails extends StatefulWidget {
  InvoiceListModel cst;
  Customer mn;
  final void Function() refreshdata;

  InvoiceDetails(this.cst, this.refreshdata, this.mn);
  @override
  State<InvoiceDetails> createState() => _InvoiceDetailsState();
}

class _InvoiceDetailsState extends State<InvoiceDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    double width = 750.6666666666667, height = 1061.4426666666668;

    Future<List<Stock>> getItem() async {
      List<Stock> InvoiceList = [];
      await FirebaseFirestore.instance
          .collection('InvoiceItem')
          .where("Invoice No", isEqualTo: widget.cst.invoiceNo)
          //.where("Invoice Date", isEqualTo: widget.cst.invoiceDate)
          //.orderBy("Serial")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          setState(() {
            InvoiceList.add(Stock.forInvoice(
              productId: element["Product ID"],
              productName: element["Product Name"],
            //  expireDate: element["Expire Date"].toDate(),
              price: element["Price"],
              productqty: element["Quantity"],
              serial: element["Serial"],
              total: element["Total"],
              discount: element["Discount"],));
          });
        });
      }).catchError((error) => print("Failed to add user: $error"));
      return InvoiceList;
    }

    return Scaffold(
      appBar: MyAppBarEdit(height: _height,width: _width),
      body: SingleChildScrollView(
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
                    text: "Invoice Details",
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
                                    text: "Invoice : ${widget.cst.invoiceNo}",
                                    color: buttonbg,
                                    font: 'opensans',
                                    size: width / 40,
                                    weight: FontWeight.bold,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        text: "Invoice Date: ",
                                        color: Colors.grey,
                                        size: width / 64,
                                        font: 'opensans',
                                      ),
                                      CustomText(
                                        text: DateFormat.yMd()
                                            .format(widget.cst.invoiceDate),
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
                                          padding: EdgeInsets.only(
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
                                          padding: EdgeInsets.only(
                                              left: 10, right: 3, bottom: 3),
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
                                          padding: EdgeInsets.only(
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
                                                text:
                                                widget.cst.customerName,
                                                color: Colors.black87,
                                                weight: FontWeight.bold,
                                                font: 'opensans',
                                                size: width / 64,
                                              ),
                                              CustomText(
                                                text: widget.mn.address,
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text:
                                                "${widget.mn.city} ${widget.mn.zip}",
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text:
                                                "${widget.mn.phone1}/${widget.mn.phone2}",
                                                color: Colors.grey,
                                                font: 'opensans',
                                                size: width / 69,
                                              ),
                                              CustomText(
                                                text: widget.mn.email,
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
                                          child: Container(
                                            child: Text(
                                              '#',
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
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              'Item & Description',
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
                                          flex: 9,
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
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
                                          flex: 2,
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              'Rate',
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
                                          flex: 2,
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Text(
                                              'Amount',
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                  fontSize: width / 64,
                                                  color: Colors.white),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: width / 75,
                                                vertical: height / 106.1),
                                            color: dark,
                                          ),
                                          flex: 4,
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
                                                Stock iii =
                                                    snapshot.data[index];
                                                return Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: Text(
                                                            iii.serial
                                                                .toString(),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                        ),
                                                        flex: 1,
                                                      ),
                                                      Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Text(
                                                            iii.productName,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width / 64,
                                                              color: buttonbg,
                                                            ),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                        ),
                                                        flex: 9,
                                                      ),
                                                      Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Text(
                                                            iii.productqty
                                                                .toString(),
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                        ),
                                                        flex: 2,
                                                      ),
                                                      Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          child: Text(
                                                            iii.price
                                                                .toString(),
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
                                                        ),
                                                        flex: 2,
                                                      ),
                                                      Text(
                                                        "|",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Expanded(
                                                        flex: 4,
                                                        child: Container(
                                                          child: Text(
                                                            "${iii.total}",
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
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 7,
                                                                  horizontal:
                                                                      10),
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
                                          flex: 2,
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "${widget.cst.total + widget.cst.discount}",
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
                                          flex: 2,
                                        ),
                                        Text(
                                          "|",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.cst.discount.toString(),
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
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.cst.total.toString(),
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
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'Paid',
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
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.cst.paid.toString(),
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
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              'Due',
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
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              widget.cst.due.toString(),
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
