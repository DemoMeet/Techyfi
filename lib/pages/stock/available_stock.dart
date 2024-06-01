import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/pages/customers/widgets/customer_list_item.dart';
import 'package:groceyfi02/pages/product/edit_product.dart';
import 'package:groceyfi02/pages/product/widgets/product_list_item.dart';
import 'package:groceyfi02/pages/stock/widget/stock_report_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../api/csv_stock.dart';
import '../../api/pdf_stock.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/Stock.dart';
import '../../model/customer.dart';
import '../../model/products.dart';
import '../../model/productstock.dart';
import '../../model/nav_bools.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class AvailableStock extends StatefulWidget {

  
  
  Navbools nn;
  AvailableStock(
      { required this.nn});
  @override
  State<AvailableStock> createState() => _AvailableStockState();
}

class _AvailableStockState extends State<AvailableStock> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false, _nametop = false, _namebot = false, _stocktop = false, _stockbot =false, loading = true;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<ProductStock> allProducts = [];
  List<ProductStock> foundProducts = [];
  TextEditingController search_Product = TextEditingController();


  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.stock = true;
      widget.nn.stock_available= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    int s = 0;
    await FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((medi) async {
        List<Stock> stocks = [];
        double totalmediqty = 0,
            inqty = 0,
            outqty = 0,
            stockpurprice = 0,
            stocksaleprice = 0,
            purprice = 0,
            saleprice = 0;
        await FirebaseFirestore.instance
            .collection('Stock')
            .where("Product ID", isEqualTo: medi.id)
            .get()
            .then((qury) {
          qury.docs.forEach((element) {
            totalmediqty = totalmediqty + element["Quantity"];
            stocks.add(Stock(
                productId: element["Product ID"],
                productName: element["Product Name"],
       //         expireDate: element["Expire Date"].toDate(),
                price: element["Price"],
                manuPrice: element["Supplier Price"],
                productqty: element["Quantity"],
                serial: 0,
                total: 0));
          });
        });
        await FirebaseFirestore.instance
            .collection('PurchaseItem')
            .where("Product ID", isEqualTo: medi.id)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((element) {
              inqty = inqty + element["Quantity"];
              stockpurprice = stockpurprice + element["Total"];
              purprice = element["Supplier Price"];
          });
        });
        await FirebaseFirestore.instance
            .collection('InvoiceItem')
            .where("Product ID", isEqualTo: medi.id)
            .get()
            .then((querySnapshot) {
          querySnapshot.docs.forEach((element) {
              outqty = outqty + element["Quantity"];
              stocksaleprice = stocksaleprice + element["Total"];
              saleprice = element["Price"];
          });
        });
        if(totalmediqty>0){
          allProducts.add(ProductStock(
              product:  Product(
                name: medi["Product Name"],
                category: medi["Category Name"],
                brand: medi["Brand Name"],user: medi['User'],
                id: medi.id,code: medi['Code'],
                sl: 0,details:medi["Product Details"],
                menuperprice: medi['Purchase Price'],bodyrate: medi["Body Rate"],
                perprice: medi["Product Price"],
                strength: medi["Strength"],
                unit: medi["Unit Name"],
                img: medi["Image"],
                imgurl: medi["ImageURL"],
              ),
              stocks: stocks,
              inqty: inqty,
              outqty: outqty,
              sl: s,
              stockpurprice: stockpurprice,
              stocksaleprice: stocksaleprice,
              stock: totalmediqty,
              purcahseprice: purprice,
              saleprice: saleprice));
          runds();
          s++;
        }
      });
    });
  }

  void runds(){
    foundProducts = allProducts;
    loading = false;
    makechunks();
  }
  void makechunks() {
    chunks = [];
    for (var i = 0; i < foundProducts.length; i += _items) {
      chunks.add(foundProducts.sublist(
          i,
          i + _items > foundProducts.length
              ? foundProducts.length
              : i + _items));
    }
    setState(() {
      _totalpagenum = (foundProducts.length / _items).floor() + 1;
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    super.initState();
  }

  void _runFilter(String enteredKeyword) {
    List<ProductStock> results = [];
    if (enteredKeyword.isEmpty) {
      results = allProducts;
    } else {
      results = allProducts
          .where((user) => user.product.name
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      foundProducts = results;
    });
    makechunks();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    Future<List<ProductStock>> getCust() async {
      List<ProductStock> Products = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Products.add(chunks[_currentpagenum - 1][ss]);
      }
      return Products;
    }


    List<ProductStock> getlist() {
      List<ProductStock> customers = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        customers.add(chunks[_currentpagenum - 1][ss]);
      }
      return customers;
    }

 

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar:MyAppBar(height: _height,width:  _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn, ),
            Expanded(
                child: loading ? const Center(child: CircularProgressIndicator(),):Container(
                  margin: EdgeInsets.only(top: _height / 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          left: _width / 45.6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CustomText(
                                  text: "Available Stock Report",
                                  size: 22,
                                  weight: FontWeight.bold,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 20, top: 5),
                                  child: InkWell(
                                    onTap: () {
                                      CsvStock.generateAndDownloadCsv(
                                          getlist(), 'Available_Stock_List.csv');
                                    },
                                    child: Image.asset(
                                      "assets/icons/download_csv.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 10, top: 5),
                                  child: InkWell(onTap: () {
                                    PdfStock.generate(getlist(), true);
                                  },
                                    child: Image.asset(
                                      "assets/icons/download_pdf.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: _width / 5,
                              margin:
                              EdgeInsets.only(top: 10, bottom: 10, right: _width / 25),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: search_Product,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  prefixIcon: Icon(Icons.search),
                                  hintText: "Search",
                                  fillColor: Colors.white,
                                  filled: true,
                                ),
                                onChanged: (value) => _runFilter(value),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                color: Colors.grey.shade200,
                                padding: EdgeInsets.only(left: 15, right: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _nametop = false;
                                              _namebot = false;
                                              allProducts
                                                  .sort((a, b) => a.sl.compareTo(b.sl));
                                              makechunks();
                                            });
                                          },
                                          child: Text(
                                            "SL",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: tabletitle,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Product Name",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: tabletitle,
                                                    fontFamily: 'inter'),
                                              ),
                                            ),
                                          ),

                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (!_nametop) {
                                                  _nametop = true;
                                                  _namebot = false;
                                                  allProducts.sort((a, b) => a
                                                      .product.name
                                                      .compareTo(b.product.name));
                                                  makechunks();
                                                } else {
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allProducts.sort((b, a) => a
                                                      .product.name
                                                      .compareTo(b.product.name));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _nametop
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                  transform: Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                                ),
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: _namebot
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                  transform: Matrix4.translationValues(
                                                      0.0, -8.0, 0.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Sale Price",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Pur. Price",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "In Qty",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Out Qty",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                    ),
                                    Text("|"),

                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Stock",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: tabletitle,
                                                    fontFamily: 'inter'),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (!_stocktop) {
                                                  _stocktop = true;
                                                  _stockbot = false;
                                                  allProducts.sort((a, b) => a
                                                      .stock
                                                      .compareTo(b.stock));
                                                  makechunks();
                                                } else {
                                                  _stocktop = false;
                                                  _stockbot = true;
                                                  allProducts.sort((b, a) => a
                                                      .stock
                                                      .compareTo(b.stock));
                                                  makechunks();
                                                }
                                              });
                                            },
                                            child: Column(
                                              children: [
                                                Container(
                                                  transform: Matrix4.translationValues(
                                                      0.0, 8.0, 0.0),
                                                  child: Icon(
                                                    Icons.arrow_drop_up,
                                                    color: _stocktop
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                ),
                                                Container(
                                                  transform: Matrix4.translationValues(
                                                      0.0, -8.0, 0.0),
                                                  child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: _stockbot
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Stock Sale Price",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Stock Purchase Price",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: _height / 1.60,
                                child: FutureBuilder(
                                  builder: (ctx,AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text(
                                              "No Stock Data Available.."),
                                        );
                                      } else  if (snapshot.hasData) {
                                        return MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: ListView.builder(
                                            // physics: NeverScrollableScrollPhysics(),
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              return StockReportItem(
                                                index: index,
                                                mst: snapshot.data[index],
                                                fetchDocuments: _fetchDocuments,
                                              );
                                            },
                                          ),
                                        );
                                      }
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  future: getCust(),
                                ),
                              ),
                              _width > 600
                                  ? Container(
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 45),
                                      child: Row(
                                        children: [
                                          CustomText(
                                            text: "Show entries",
                                            size: 12,
                                            color: tabletitle,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            child: DropdownButton<int>(
                                              value: _items,
                                              icon: const Icon(
                                                  Icons.keyboard_arrow_down),
                                              items: items.map((int items) {
                                                return DropdownMenuItem(
                                                  value: items,
                                                  child: CustomText(
                                                    text: items.toString(),
                                                    size: 12,
                                                    color: tabletitle,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (int? newValue) {
                                                setState(() {
                                                  _items = newValue!;
                                                  makechunks();
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: 1,
                                      ),
                                      flex: 10,
                                    ),
                                    Container(
                                      width: _width / 3,
                                      child: NumberPaginator(
                                        controller: _controller,
                                        numberPages: _totalpagenum,
                                        onPageChange: (int index) {
                                          setState(() {
                                            _currentpagenum = index + 1;
                                          });
                                        },
                                      ),
                                    ),
                                    const Expanded(
                                      child: SizedBox(
                                        height: 1,
                                      ),
                                      flex: 15,
                                    ),
                                  ],
                                ),
                              )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        )));
  }
}
