import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../constants/stringConst.dart';
import '../model/productstock.dart';

class PdfStock {
  static Future<File> generate(List<ProductStock> invoice, bool avai) async {
    final pdf = Document();

    final Uint8List data = await yourBackgroundImageFunction();
    final fontData =
        await rootBundle.load("assets/fonts/opensans/OpenSans-Regular.ttf");
    final ttf = Font.ttf(fontData.buffer.asByteData());

    final fontData2 =
        await rootBundle.load("assets/fonts/opensans/OpenSans-Bold.ttf");
    final ttfbold = Font.ttf(fontData2.buffer.asByteData());

    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: EdgeInsets.zero,
      build: (context) => [
        Container(
          margin: EdgeInsets.only(
              left: PdfPageFormat.a4.marginLeft,
              right: PdfPageFormat.a4.marginRight),
          child: buildInvoice(invoice, ttf, ttfbold),
        ),
      ],
      header: (context) => buildHeader(ttf, data, ttfbold,avai),
      footer: (context) => buildFooter(ttf, ttfbold),
    ));
    return PdfApi.saveDocument(
        "Stock_List${DateFormat('dd-MMM-yyyy-jms').format(DateTime.now())}.pdf",
        pdf);
  }

  static Future<Uint8List> yourBackgroundImageFunction() async {
    ByteData byteData = await rootBundle.load("assets/images/invoice_bg.jpg");
    return byteData.buffer.asUint8List();
  }

  static Widget buildInvoice(List<ProductStock> invoice, final ttf, final ttfbold) {
    final headers = [
      '#',
      'Product Name',
      'Sale Price',
      'Pur Price',
      'In QTY',
      'Out QTY',
      'Stock',
      'Stock Price',
      'Stock Pur Price'
    ];

    final data = invoice.map((item) {
      return [
        (item.sl + 1).toString(),
      item.product.name + "("+item.product.strength+item.product.unit+")",
        item.saleprice,
        item.purcahseprice,
        item.inqty,
        item.outqty,
        item.stock,
        item.saleprice,
        item.stockpurprice
      ];
    }).toList();

    return TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle:
          TextStyle(font: ttfbold, color: PdfColors.white, fontSize: 10),
      headerDecoration: BoxDecoration(color: PdfColor.fromHex("#1C1F22")),
      cellHeight: 20,
      border: TableBorder.all(color: PdfColors.white, width: 2),
      cellStyle: TextStyle(
          font: ttf, color: PdfColor.fromHex("#1C1F22"), fontSize: 10),
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerLeft,
        2: Alignment.center,
        3: Alignment.center,
        4: Alignment.center,
        5: Alignment.center,
        6: Alignment.center,
        7: Alignment.center,
        8: Alignment.center,
      },
    );
  }

  static Widget buildTotal(List<ProductStock> invoice, bool total,final ttfbold) {
    return Container(
        alignment: Alignment.centerRight,
        child: Row(children: [
          Spacer(flex: 6),
          Expanded(
              flex: 4,
              child: Row(children: [
                Expanded(
                  child: Container(
                      color: PdfColor.fromHex("#1C1F22"),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Text("Total ",
                          style: TextStyle(font: ttfbold, color: PdfColors.white, fontSize:10 ))),flex: 5,
                ),
                Container(width: 2, height: 50, color: PdfColors.white),
    Expanded(
    child: Container(
                  color: PdfColor.fromHex("#1C1F22"),
                  alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Text(total.toString(),
                      style: TextStyle(font: ttfbold, color: PdfColors.white, fontSize:10 )),),flex: 2,
                ),
              ]))
        ]));
  }

  static Widget buildFooter(final ttf, final ttfbold) => Container(
      margin: EdgeInsets.only(bottom: PdfPageFormat.a4.marginBottom - 40),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(height: 20),
        Divider(color: PdfColor.fromHex("#808080")),
        Text(pharmacyName,
            style: TextStyle(
                font: ttfbold,
                fontSize: 16,
                color: PdfColor.fromHex("#1E2772"))),
        Text(
            '$pharmacyAddress, $pharmacyCity | $pharmacyNumber | $pharmacyEmail',
            style: TextStyle(
                font: ttf, fontSize: 8, color: PdfColor.fromHex("#808080"))),
      ]));
  static Widget buildHeader(final ttf, Uint8List data, final ttfbold,bool total) =>
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            child: Image(MemoryImage(data),
                width: PdfPageFormat.a4.width, height: 100, fit: BoxFit.fill),
            color: PdfColors.black),
        Text(total?"Available Stock List":"Stock List",
            style: TextStyle(
                font: ttfbold,
                fontSize: 14,
                color: PdfColor.fromHex("#1E2772"))),
        Text('Date: ${DateFormat('dd MMMM, yyyy').format(DateTime.now())}',
            style: TextStyle(
                font: ttf, fontSize: 8, color: PdfColor.fromHex("#1E2772"))),
        SizedBox(height: 30),
      ]);
}
