import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/api/pdf_api.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../constants/stringConst.dart';
import '../model/Stock.dart';
import '../model/invoiceListModel.dart';

class PdfInvoicePOS {
  static Future<File> generate(InvoiceListModel cst, List<Stock> stock, double save) async {
    final pdf = Document();

    final Uint8List data = await yourBackgroundImageFunction();
    final fontData =
        await rootBundle.load("assets/fonts/opensans/OpenSans-Regular.ttf");
    final ttf = Font.ttf(fontData.buffer.asByteData());

    final fontData2 =
        await rootBundle.load("assets/fonts/opensans/OpenSans-Bold.ttf");
    final ttfbold = Font.ttf(fontData2.buffer.asByteData());

    pdf.addPage(Page(
      pageFormat: PdfPageFormat.roll80,
      margin: EdgeInsets.zero,
      build: (context) => Column(children: [
        SizedBox(
          height: 10,
        ),
        Text(pharmacyName,
            style: TextStyle(
              font: ttfbold,
              fontSize: 16,
              color: PdfColors.black,
            )),
        Text(pharmacyAddress,
            style: TextStyle(
              font: ttf,
              fontSize: 10,
              color: PdfColors.black,
            )),
        Text(pharmacyNumber,
            style: TextStyle(
              font: ttf,
              fontSize: 10,
              color: PdfColors.black,
            )),
        SizedBox(
          height: 5,
        ),
        Divider(color: PdfColor.fromHex("#808080")),
        SizedBox(
          height: 5,
        ),
        Text(cst.customerName,
            style: TextStyle(
              font: ttfbold,
              fontSize: 10,
              color: PdfColors.black,
            )),
        Text('Date: ${DateFormat('dd MMMM, yyyy').format(cst.invoiceDate)}',
            style: TextStyle(
              font: ttf,
              fontSize: 10,
              color: PdfColors.black,
            )),
        SizedBox(
          height: 5,
        ),
        Container(
          margin: EdgeInsets.only(left: 20),
          alignment: Alignment.centerLeft,
          child: Text("Invoice No: ${cst.invoiceNo}",
              style: TextStyle(
                font: ttfbold,
                fontSize: 10,
                color: PdfColors.black,
              )),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          margin: EdgeInsets.only(
              left: PdfPageFormat.roll80.marginLeft,
              right: PdfPageFormat.roll80.marginRight),
          child: buildInvoice(stock, ttf, ttfbold),
        ),
        SizedBox(
          height: 5,
        ),
        Divider(color: PdfColor.fromHex("#808080")),
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
                  style: TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "${cst.total + cst.discount}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColors.black,
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
                flex: 7,
                child: Text(
                  'Save : ',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: PdfColors.black,
                    font: ttfbold,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "${save - cst.total}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: PdfColors.black,
                    font: ttfbold,
                    fontSize: 10,
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
                flex: 7,
                child: Text(
                  'Grand Total : ',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: PdfColors.black,
                    font: ttfbold,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "${cst.total}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: PdfColors.black,
                    font: ttfbold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Container(
        //   margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       Expanded(
        //         child: Text(
        //           'Paid : ',
        //           textAlign: TextAlign.right,
        //           style: TextStyle(
        //             font: ttf,
        //             fontSize: 10,
        //             color: PdfColors.black,
        //           ),
        //         ),
        //         flex: 7,
        //       ),
        //       Expanded(
        //         child: Text(
        //           "${cst.paid}",
        //           textAlign: TextAlign.right,
        //           style: TextStyle(
        //             font: ttf,
        //             fontSize: 10,
        //             color: PdfColors.black,
        //           ),
        //         ),
        //         flex: 2,
        //       ),
        //     ],
        //   ),
        // ),
        // Container(
        //   margin: EdgeInsets.only(left: 20, right: 20, bottom: 5),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       Expanded(
        //         child: Text(
        //           'Due : ',
        //           textAlign: TextAlign.right,
        //           style: TextStyle(
        //             font: ttf,
        //             fontSize: 10,
        //             color: PdfColors.black,
        //           ),
        //         ),
        //         flex: 7,
        //       ),
        //       Expanded(
        //         child: Text(
        //           "${cst.due}",
        //           textAlign: TextAlign.right,
        //           style: TextStyle(
        //             font: ttf,
        //             fontSize: 10,
        //             color: PdfColors.black,
        //           ),
        //         ),
        //         flex: 2,
        //       ),
        //     ],
        //   ),
        // ),
        Divider(color: PdfColor.fromHex("#808080")),
        SizedBox(height: 5),
        Text(
          'Customer Copy',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PdfColors.black,
            font: ttf,
            fontSize: 10,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Image(MemoryImage(data), height: 15, width: 60, fit: BoxFit.fill),
        Container(
          margin: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Powered By : ',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: PdfColors.black,
                  font: ttf,
                  fontSize: 10,
                ),
              ),
              Text(
                "MeetTechLab",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: PdfColors.black,
                  font: ttfbold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ]),
    ));
    return PdfApi.saveDocument(
        "POS_INV_No:${cst.invoiceNo}${DateFormat('dd-MMM-yyyy-jms').format(DateTime.now())}.pdf",
        pdf);
  }

  static Future<Uint8List> yourBackgroundImageFunction() async {
    ByteData byteData = await rootBundle.load("assets/icons/llogo.png");
    return byteData.buffer.asUint8List();
  }

  static Widget buildInvoice(List<Stock> invoice, final ttf, final ttfbold) {
    final headers = [
      ' # ',
      ' Items ',
      ' Qty ',
      ' Rate ',
      ' Amount ',
    ];

    Alignment getCellAlignment(int index) {
      switch (index) {
        case 1:
          return Alignment.centerLeft;
        case 4:
          return Alignment.centerRight;
        default:
          return Alignment.center;
      }
    }

    final List<List<String>> data = invoice.map((item) {
      return [
        (item.serial).toString(),
        item.productName,
        item.productqty.toString(),
        item.price.toString(),
        item.total.toString(),
      ];
    }).toList();

    final List<TableRow> rows = [];
    rows.add(
      TableRow(
        children: headers
            .map((header) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  height: 25,
                  decoration: const BoxDecoration(
                    color: PdfColors.white,
                    // color: PdfColor.fromHex("#1C1F22"),
                  ),
                  child: Column(children: [Text(
                    header,
                    style: TextStyle(
                      font: ttfbold, color: PdfColor.fromHex("#1C1F22"),
                      //     color: PdfColors.white,
                      fontSize: 10,
                    ),
                  ),
                    Container(color: PdfColor.fromHex("#1C1F22"),height: 1,width: double.infinity)])
                ))
            .toList(),
      ),
    );

    rows.addAll(data.map((row) {
      return TableRow(
        children: row
            .asMap()
            .map((index, cell) => MapEntry(
                  index,
                  Container(
                    alignment: getCellAlignment(index),
                    child: Text(
                      cell,
                      style: TextStyle(
                        font: ttfbold,
                        color: PdfColor.fromHex("#1C1F22"),
                        fontSize: 8,
                      ),
                    ),
                  ),
                ))
            .values
            .toList(),
      );
    }));

    return Table(
      children: rows,
      border: TableBorder.all(color: PdfColors.white, width: 1),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const FlexColumnWidth(0.8),
        1: const FlexColumnWidth(3),
        2: const FlexColumnWidth(2),
        3: const FlexColumnWidth(2),
        4: const FlexColumnWidth(3),
      },
    );
  }

  static Widget buildTotal(List<Stock> invoice, double total, final ttfbold) {
    return Container(
        alignment: Alignment.centerRight,
        child: Row(children: [
          Spacer(flex: 6),
          Expanded(
              flex: 4,
              child: Row(children: [
                Expanded(
                  flex: 5,
                  child: Container(
                      color: PdfColor.fromHex("#1C1F22"),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Text("Total ",
                          style: TextStyle(
                              font: ttfbold,
                              color: PdfColors.white,
                              fontSize: 10))),
                ),
                Container(width: 2, height: 50, color: PdfColors.white),
                Expanded(
                  flex: 2,
                  child: Container(
                    color: PdfColor.fromHex("#1C1F22"),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    child: Text(total.toString(),
                        style: TextStyle(
                            font: ttfbold,
                            color: PdfColors.white,
                            fontSize: 10)),
                  ),
                ),
              ]))
        ]));
  }
}
