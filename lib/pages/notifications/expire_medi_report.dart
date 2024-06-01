// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:groceyfi02/pages/customers/widgets/customer_list_item.dart';
// import 'package:groceyfi02/pages/product/edit_product.dart';
// import 'package:groceyfi02/pages/product/widgets/product_list_item.dart';
// import 'package:groceyfi02/pages/notifications/widgets/expire_medi_report_item.dart';
// import 'package:groceyfi02/pages/notifications/widgets/stock_out_report_item.dart';
// import 'package:groceyfi02/pages/stock/widget/stock_report_item.dart';
// import 'package:number_paginator/number_paginator.dart';

// import '../../constants/style.dart';
// import '../../model/Stock.dart';
// import '../../model/customer.dart';
// import '../../model/products.dart';
// import '../../model/productstock.dart';
// import '../../model/nav_bools.dart';
// import '../../widgets/custom_text.dart';
// import '../../widgets/side_menu_big.dart';
// import '../../widgets/side_menu_small.dart';
// import '../../widgets/topnavigationbaredit.dart';

// class ExpireMediReport extends StatefulWidget {
//   @override
//   State<ExpireMediReport> createState() => _ExpireMediReportState();
// }

// class _ExpireMediReportState extends State<ExpireMediReport> {
//   final NumberPaginatorController _controller = NumberPaginatorController();
//   late ScrollController listScrollController;
//   String dropdownvalue = 'Search By Name';
//   int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
//   bool _first = false,
//       _nametop = false,
//       _namebot = false,
//       _stocktop = false,
//       _stockbot = false;
//   var chunks = [];
//   var items = [
//     10,
//     25,
//     50,
//     100,
//     500,
//   ];
//   List<Stock> allProducts = [];
//   List<Stock> foundProducts = [];
//   TextEditingController search_Product = TextEditingController();

//   void apply() {
//     if (!_first) {
//       _first = true;
//     }
//   }

//   void _fetchDocuments() async {
//     int s = 0;
//     await FirebaseFirestore.instance
//         .collection('Stock')
//         .where("Expire Date", isLessThanOrEqualTo: DateTime.now())
//         .get()
//         .then((qury) {
//       qury.docs.forEach((element) {
//         allProducts.add(Stock(productId: element["Product ID"],
//             productName: element["Product Name"],
//             expireDate: element["Expire Date"].toDate(),
//             price: element["Price"],
//             manuPrice: element["Supplier Price"],
//             productqty: element["Quantity"],
//             serial: 0,
//             total: 0));
//         s++;
//       });
//       setState(() {
//         foundProducts = allProducts;
//         makechunks();
//       });
//     });
//   }

//   void makechunks() {
//     chunks = [];
//     print(foundProducts.length);
//     for (var i = 0; i < foundProducts.length; i += _items) {
//       chunks.add(foundProducts.sublist(
//           i,
//           i + _items > foundProducts.length
//               ? foundProducts.length
//               : i + _items));
//     }
//     setState(() {
//       _totalpagenum = (foundProducts.length / _items).floor() + 1;
//     });
//   }

//   @override
//   void initState() {
//     _fetchDocuments();
//     listScrollController = ScrollController();
//     super.initState();
//   }

//   void _runFilter(String enteredKeyword) {
//     List<Stock> results = [];
//     if (enteredKeyword.isEmpty) {
//       results = allProducts;
//     } else {
//       results = allProducts
//           .where((user) => user.productName
//               .toLowerCase()
//               .contains(enteredKeyword.toLowerCase()))
//           .toList();
//     }
//     setState(() {
//       foundProducts = results;
//     });
//     makechunks();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double _height = MediaQuery.of(context).size.height;
//     double _width = MediaQuery.of(context).size.width;

//     Future.delayed(Duration.zero, () async {
//       apply();
//     });

//     Future<List<Stock>> getCust() async {
//       List<Stock> Products = [];
//       for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
//         Products.add(chunks[_currentpagenum - 1][ss]);
//       }
//       return Products;
//     }

//     return Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: MyAppBarEdit(height: _height,width: _width),
//         body: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//                 child: Container(
//               margin: EdgeInsets.only(top: _height / 10),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     margin: EdgeInsets.only(
//                       left: _width / 45.6,
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             CustomText(
//                               text: "Expired Product Report",
//                               size: 22,
//                               weight: FontWeight.bold,
//                             ),
//                             Container(
//                               margin: EdgeInsets.only(left: 20, top: 5),
//                               child: InkWell(
//                                 child: Image.asset(
//                                   "assets/icons/download_csv.png",
//                                   width: 30,
//                                   height: 30,
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.only(left: 10, top: 5),
//                               child: InkWell(
//                                 child: Image.asset(
//                                   "assets/icons/download_pdf.png",
//                                   width: 30,
//                                   height: 30,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Container(
//                           width: _width / 5,
//                           margin: EdgeInsets.only(
//                               top: 10, bottom: 10, right: _width / 25),
//                           decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: Colors.white,
//                               ),
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(10))),
//                           child: TextField(
//                             controller: search_Product,
//                             decoration: const InputDecoration(
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(10)),
//                                 borderSide: BorderSide(color: Colors.grey),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(10)),
//                                 borderSide: BorderSide(color: Colors.grey),
//                               ),
//                               prefixIcon: Icon(Icons.search),
//                               hintText: "Search",
//                               fillColor: Colors.white,
//                               filled: true,
//                             ),
//                             onChanged: (value) => _runFilter(value),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: Container(
//                       child: Column(
//                         children: [
//                           Container(
//                             color: Colors.grey.shade200,
//                             padding: EdgeInsets.only(left: 15, right: 15),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 1,
//                                   child: Container(
//                                     margin: EdgeInsets.only(left: 30),
//                                     child: InkWell(
//                                       onTap: () {
//                                         setState(() {
//                                           _nametop = false;
//                                           _namebot = false;
//                                           allProducts.sort(
//                                               (a, b) => a.serial.compareTo(b.serial));
//                                           makechunks();
//                                         });
//                                       },
//                                       child: Text(
//                                         "SL",
//                                         style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: tabletitle,
//                                             fontFamily: 'inter'),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Text("|"),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Flexible(
//                                         child: Container(
//                                           margin: EdgeInsets.only(left: 7),
//                                           child: Text(
//                                             "Product Name",
//                                             overflow: TextOverflow.ellipsis,
//                                             style: TextStyle(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: tabletitle,
//                                                 fontFamily: 'inter'),
//                                           ),
//                                         ),
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           setState(() {
//                                             if (!_nametop) {
//                                               _nametop = true;
//                                               _namebot = false;
//                                               allProducts.sort((a, b) => a
//                                                   .productName
//                                                   .compareTo(b.productName));
//                                               makechunks();
//                                             } else {
//                                               _nametop = false;
//                                               _namebot = true;
//                                               allProducts.sort((b, a) => a
//                                                   .productName
//                                                   .compareTo(b.productName));
//                                               makechunks();
//                                             }
//                                           });
//                                         },
//                                         child: Column(
//                                           children: [
//                                             Container(
//                                               transform:
//                                                   Matrix4.translationValues(
//                                                       0.0, 8.0, 0.0),
//                                               child: Icon(
//                                                 Icons.arrow_drop_up,
//                                                 color: _nametop
//                                                     ? Colors.black
//                                                     : Colors.black45,
//                                               ),
//                                             ),
//                                             Container(
//                                               transform:
//                                                   Matrix4.translationValues(
//                                                       0.0, -8.0, 0.0),
//                                               child: Icon(
//                                                 Icons.arrow_drop_down,
//                                                 color: _namebot
//                                                     ? Colors.black
//                                                     : Colors.black45,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Text("|"),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Container(
//                                     margin: EdgeInsets.only(left: 7),
//                                     child: Text(
//                                       "Batch ID",
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: tabletitle,
//                                           fontFamily: 'inter'),
//                                     ),
//                                   ),
//                                 ),
//                                 Text("|"),
//                                 Expanded(
//                                   flex: 3,
//                                   child: Container(
//                                     margin: EdgeInsets.only(left: 7),
//                                     child: const Text(
//                                       "Expire Date",
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.red,
//                                           fontFamily: 'inter'),
//                                     ),
//                                   ),
//                                 ),
//                                 Text("|"),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Container(
//                                     margin: EdgeInsets.only(left: 7),
//                                     child: const Text(
//                                       "Stock",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.red,
//                                           fontFamily: 'inter'),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             height: _height / 1.60,
//                             child: FutureBuilder(
//                               builder: (ctx, AsyncSnapshot snapshot) {
//                                 if (snapshot.connectionState ==
//                                     ConnectionState.done) {
//                                   if (snapshot.hasError) {
//                                     return const Center(
//                                       child: Text(
//                                           "No Product Data Available.."),
//                                     );
//                                   } else if (snapshot.hasData) {
//                                     return MediaQuery.removePadding(
//                                       context: context,
//                                       removeTop: true,
//                                       child: ListView.builder(
//                                         // physics: NeverScrollableScrollPhysics(),
//                                         itemCount: snapshot.data.length,
//                                         itemBuilder: (context, index) {
//                                           return ExpireMediReportItem(
//                                             index: index,
//                                             mst: snapshot.data[index],
//                                             fetchDocuments: _fetchDocuments,
//                                           );
//                                         },
//                                       ),
//                                     );
//                                   }
//                                 }
//                                 return Center(
//                                   child: CircularProgressIndicator(),
//                                 );
//                               },
//                               future: getCust(),
//                             ),
//                           ),
//                           _width > 600
//                               ? Container(
//                                   child: Row(
//                                     children: [
//                                       Container(
//                                         margin: EdgeInsets.only(left: 45),
//                                         child: Row(
//                                           children: [
//                                             CustomText(
//                                               text: "Show entries",
//                                               size: 12,
//                                               color: tabletitle,
//                                             ),
//                                             SizedBox(
//                                               width: 10,
//                                             ),
//                                             Container(
//                                               decoration: BoxDecoration(
//                                                 color: Colors.white,
//                                               ),
//                                               child: DropdownButton<int>(
//                                                 value: _items,
//                                                 icon: const Icon(
//                                                     Icons.keyboard_arrow_down),
//                                                 items: items.map((int items) {
//                                                   return DropdownMenuItem(
//                                                     value: items,
//                                                     child: CustomText(
//                                                       text: items.toString(),
//                                                       size: 12,
//                                                       color: tabletitle,
//                                                     ),
//                                                   );
//                                                 }).toList(),
//                                                 onChanged: (int? Value) {
//                                                   setState(() {
//                                                     _items = Value!;
//                                                     makechunks();
//                                                   });
//                                                 },
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 1,
//                                         ),
//                                         flex: 10,
//                                       ),
//                                       Container(
//                                         width: _width / 3,
//                                         child: NumberPaginator(
//                                           controller: _controller,
//                                           numberPages: _totalpagenum,
//                                           onPageChange: (int index) {
//                                             setState(() {
//                                               _currentpagenum = index + 1;
//                                             });
//                                           },
//                                         ),
//                                       ),
//                                       Expanded(
//                                         child: SizedBox(
//                                           height: 1,
//                                         ),
//                                         flex: 15,
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               : SizedBox(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )),
//           ],
//         ));
//   }
// }
