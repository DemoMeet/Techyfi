import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:csv/csv.dart';

import '../model/invoiceListModel.dart';



class CsvLedger {
  static void generateAndDownloadCsv(
      List<InvoiceListModel> customers, balancelist, descriptionlist,bool ss, String fileName) {
      List<List<dynamic>> dataList = [InvoiceListModel.parameterNames(ss)]..addAll(customers.map((customer) => customer.toCsvRow(descriptionlist,balancelist)));

    saveAndDownloadCsv(dataList, fileName);
  }

  static void saveAndDownloadCsv(
      List<List<dynamic>> dataList, String fileName) {
    String csvString = const ListToCsvConverter().convert(dataList);

    final blob = html.Blob([csvString], 'application/csv');
    final  url= html.Url.createObjectUrlFromBlob(blob);
    html.window.open(url, "_blank");
    html.Url.revokeObjectUrl(url);
    final url2 = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
    html.document.createElement('a') as html.AnchorElement
      ..href = url2
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url2);


    final file = File(fileName);
  }



}
