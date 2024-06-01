import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../constants/stringConst.dart';
import '../model/purchaseListModel.dart';

class PdfPurchase {
  static Future<File> generate(List<PurchaseListModel> invoice) async {
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
      header: (context) => buildHeader(ttf, data, ttfbold),
      footer: (context) => buildFooter(ttf, ttfbold),
    ));
    return PdfApi.saveDocument(
        "Purchase_List${DateFormat('dd-MMM-yyyy-jms').format(DateTime.now())}.pdf",
        pdf);
  }

  static Future<Uint8List> yourBackgroundImageFunction() async {
    ByteData byteData = await rootBundle.load("assets/images/invoice_bg.jpg");
    return byteData.buffer.asUint8List();
  }

  static Widget buildInvoice(List<PurchaseListModel> invoice, final ttf, final ttfbold) {
    final headers = [
      '#',
      "Invoice No",
      "Purchase ID",
      "Supplier Name",
      "Purchase Date",
      "Total"
    ];

    final data = invoice.map((item) {
      return [
        (item.sl + 1).toString(),
        item.invoiceNo,
        item.purchaseID,
        item.supplierName,
        DateFormat('dd MMM, yyyy').format(item.purchaseDate),
        item.total
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
        2: Alignment.centerLeft,
        3: Alignment.centerLeft,
        4: Alignment.center,
        5: Alignment.centerRight,
      },
    );
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
  static Widget buildHeader(final ttf, Uint8List data, final ttfbold) =>
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
            child: Image(MemoryImage(data),
                width: PdfPageFormat.a4.width, height: 100, fit: BoxFit.fill),
            color: PdfColors.black),
        Text("Purchase List",
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
