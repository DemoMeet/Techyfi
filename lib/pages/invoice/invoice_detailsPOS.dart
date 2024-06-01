import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/model/Stock.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../constants/stringConst.dart';
import '../../constants/style.dart';
import '../../model/customer.dart';
import '../../model/invoiceListModel.dart';
import '../../widgets/topnavigationbaredit.dart';

class InvoiceDetailsPOS extends StatefulWidget {
  InvoiceListModel cst;
  Customer mn;
  final void Function() refreshdata;

  InvoiceDetailsPOS(this.cst, this.refreshdata, this.mn);
  @override
  State<InvoiceDetailsPOS> createState() => _InvoiceDetailsPOSState();
}

class _InvoiceDetailsPOSState extends State<InvoiceDetailsPOS> {
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
                    text: "Invoice Details POS",
                    size: 32,
                    weight: FontWeight.bold),
              ),
              Container(
                margin: EdgeInsets.only(top: _height / 30, left: 80, right: 80),
                color: Colors.white,
                width: _width / 4.5,
                child: Column(
                  children: [
                    SizedBox(
                      height: _height / 15,
                    ),
                    Container(
                      child: Image.asset(
                        "assets/icons/logo.png",
                      ),
                      width: _width / 13,
                    ),
                    SizedBox(
                      height: _height / 80,
                    ),
                    CustomText(
                      text: pharmacyName,
                      color: Colors.black87,
                      weight: FontWeight.bold,
                      font: 'opensans',
                      size: width / 60,
                    ),
                    CustomText(
                      text: pharmacyAddress,
                      color: Colors.black87,
                      font: 'opensans',
                      size: width / 69,
                    ),
                    CustomText(
                      text: pharmacyNumber,
                      color: Colors.black87,
                      font: 'opensans',
                      size: width / 69,
                    ),
                    SizedBox(
                      height: _height / 80,
                    ),
                    Container(
                      height: 1,
                      color: Colors.black,
                      width: double.infinity,
                    ),
                    SizedBox(
                      height: _height / 100,
                    ),
                    CustomText(
                      text: widget.cst.customerName,
                      color: Colors.black87,
                      weight: FontWeight.bold,
                      font: 'opensans',
                      size: width / 64,
                    ),
                    CustomText(
                      text:
                          "Date: ${DateFormat.yMd().format(widget.cst.invoiceDate)}",
                      color: Colors.black87,
                      size: width / 64,
                      font: 'opensans',
                    ),
                    SizedBox(
                      height: _height / 100,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        text: "Invoice : ${widget.cst.invoiceNo}",
                        color: Colors.black,
                        font: 'opensans',
                        size: width / 60,
                        weight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: _height / 100,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              'SL',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 69,
                                  color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Items',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 69,
                                  color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'QTY',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 69,
                                  color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Rate',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 69,
                                  color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Amount',
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: width / 69,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    LimitedBox(
                      maxHeight: 200,
                      child: FutureBuilder(
                        builder: (ctx, AsyncSnapshot snapshot) {
                              
                          if (snapshot.hasData) {
                            return MediaQuery.removePadding(
                              context: context,
                              removeTop: true,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  Stock iii = snapshot.data[index];
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 20, right: 20, top: 5),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            iii.serial.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: width / 69,
                                                color: Colors.black87),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            iii.productName,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: width / 69,
                                                color: Colors.black87),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            iii.productqty.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: width / 69,
                                                color: Colors.black87),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            iii.price.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: width / 69,
                                                color: Colors.black87),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            "${iii.total}",
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                fontSize: width / 69,
                                                color: Colors.black87),
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
                    Container(
                      margin: EdgeInsets.only(top: 5, bottom: 5),
                      height: 1,
                      color: Colors.black87,
                      width: double.infinity,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              'Total : ',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width / 69, color: Colors.black87),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${widget.cst.total + widget.cst.discount}",
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width / 69, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              'Grand Total : ',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'opensans',
                                fontSize: width / 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "${widget.cst.total}",
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: 'opensans',
                                fontSize: width / 60,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Paid : ',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width / 69, color: Colors.black87),
                            ),
                            flex: 7,
                          ),
                          Expanded(
                            child: Text(
                              "${widget.cst.paid}",
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width / 69, color: Colors.black87),
                            ),
                            flex: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Due : ',
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width / 69, color: Colors.black87),
                            ),
                            flex: 7,
                          ),
                          Expanded(
                            child: Text(
                              "${widget.cst.due}",
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: width / 69, color: Colors.black87),
                            ),
                            flex: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.black87,
                      width: double.infinity,
                    ),

                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Powered By : ',
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'opensans',
                              fontSize: width / 60,
                            ),
                          ),Text(
                            "MeetTechLab",
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: buttonbg,
                              fontFamily: 'opensans',
                              fontSize: width / 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
