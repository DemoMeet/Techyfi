import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';
import 'package:csv/csv.dart';

import '../model/Supplier.dart';

class CsvSupplier {
  static void generateAndDownloadCsv(
      List<Supplier> Suppliers, String fileName) {
    List<List<dynamic>> dataList = [Supplier.parameterNames()]..addAll(Suppliers.map((Supplier) => Supplier.toCsvRow()));


    // Save the CSV string to a file and initiate download
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
