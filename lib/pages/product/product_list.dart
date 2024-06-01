import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:groceyfi02/pages/product/widgets/product_list_item.dart';
import 'package:number_paginator/number_paginator.dart';

import '../../helpers/screen_size_controller.dart';
import '../../api/csv_product.dart';
import '../../api/pdf_product.dart';
import '../../constants/style.dart';
import '../../model/products.dart';
import '../../model/nav_bools.dart';
import '../../routing/routes.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';
import 'edit_Product.dart';

class ProductList extends StatefulWidget {
  Navbools nn;
  ProductList({
    super.key,
    required this.nn,
  });

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final NumberPaginatorController _controller = NumberPaginatorController();
  late ScrollController listScrollController;
  String dropdownvalue = 'Search By Name';
  int val = 0, _totalpagenum = 1, _currentpagenum = 1, _items = 10;
  bool _first = false, _nametop = false, _namebot = false;
  var chunks = [];
  var items = [
    10,
    25,
    50,
    100,
    500,
  ];
  List<bool> _click = [];
  List<Product> allProducts = [];
  List<Product> foundProducts = [];
  TextEditingController search_Product = TextEditingController();

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.product = true;
      widget.nn.product_list = true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    int s = 0;
    _click = [];
    allProducts = [];
    foundProducts = [];
    await FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        allProducts.add(Product(
          name: element["Product Name"],
          category: element["Category Name"],
          brand: element["Brand Name"],
          user: element['User'],
          id: element.id,
          code: element['Code'],
          sl: s,
          details: element["Product Details"],
          bodyrate: element["Body Rate"],
          menuperprice: element['Purchase Price'],
          perprice: element["Product Price"],
          strength: element["Strength"],
          unit: element["Unit Name"],
          img: element["Image"],
          imgurl: element["ImageURL"],
        ));

        s++;
      });
    });
    foundProducts = allProducts;
    makechunks();
  }

  void _onEditProduct(Product cst) async {
    var result = await Get.toNamed(
      editproductPageRoute,
      arguments: {
        'Product': jsonEncode(cst),
      },
    );
    if (result == 'update') {
      _fetchDocuments();
    }
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
    List<Product> results = [];
    print(enteredKeyword);
    if (enteredKeyword.isEmpty) {
      results = allProducts;
    } else {
      results = allProducts
          .where((user) =>
              user.name.toLowerCase().contains(enteredKeyword.toLowerCase()))
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

    void changeVal(String i) {
      setState(() {
        _click[val] = false;
        _click[int.parse(i)] = true;
        val = int.parse(i);
      });
    }

    Future<List<Product>> getCust() async {
      List<Product> Products = [];
      if (chunks.isNotEmpty) {
        for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
          Products.add(chunks[_currentpagenum - 1][ss]);
        }
      }
      return Products;
    }

    List<Product> getlist() {
      List<Product> Products = [];
      for (int ss = 0; ss < chunks[_currentpagenum - 1].length; ss++) {
        Products.add(chunks[_currentpagenum - 1][ss]);
      }
      return Products;
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
          height: _height,
          width: _width,
        ),
        body: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.screenSize.value
                    ? SideMenuBig(widget.nn)
                    : SideMenuSmall(
                        widget.nn,
                      ),
                Expanded(
                    child: Container(
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
                                  text: "Product List",
                                  size: 22,
                                  weight: FontWeight.bold,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    CsvProduct.generateAndDownloadCsv(
                                        getlist(), 'Product_List.csv');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10, top: 5),
                                    child: InkWell(
                                      child: Image.asset(
                                        "assets/icons/download_csv.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    PdfProduct.generate(getlist());
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10, top: 5),
                                    child: InkWell(
                                      child: Image.asset(
                                        "assets/icons/download_pdf.png",
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: _width / 5,
                              margin: EdgeInsets.only(
                                  top: 10, bottom: 10, right: _width / 25),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: TextField(
                                controller: search_Product,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
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
                                      child: Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _nametop = false;
                                              _namebot = false;
                                              allProducts.sort((a, b) =>
                                                  a.sl.compareTo(b.sl));
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
                                      flex: 2,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Name",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: tabletitle,
                                                    fontFamily: 'inter'),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: SizedBox(
                                              width: 1,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if (!_nametop) {
                                                  _nametop = true;
                                                  _namebot = false;
                                                  allProducts.sort((a, b) =>
                                                      a.name.compareTo(b.name));
                                                  makechunks();
                                                } else {
                                                  _nametop = false;
                                                  _namebot = true;
                                                  allProducts.sort((b, a) =>
                                                      a.name.compareTo(b.name));
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
                                                  transform:
                                                      Matrix4.translationValues(
                                                          0.0, 8.0, 0.0),
                                                ),
                                                Container(
                                                  child: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: _namebot
                                                        ? Colors.black
                                                        : Colors.black45,
                                                  ),
                                                  transform:
                                                      Matrix4.translationValues(
                                                          0.0, -8.0, 0.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      flex: 5,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Brand Name",
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
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Category",
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
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Price",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: tabletitle,
                                                    fontFamily: 'inter'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Body Rate",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: tabletitle,
                                                    fontFamily: 'inter'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      flex: 4,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              margin: EdgeInsets.only(left: 7),
                                              child: Text(
                                                "Purchase Price",
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: tabletitle,
                                                    fontFamily: 'inter'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Strength",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 3,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "Image",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 2,
                                    ),
                                    Text("|"),
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 7),
                                        child: Text(
                                          "ACTION",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: tabletitle,
                                              fontFamily: 'inter'),
                                        ),
                                      ),
                                      flex: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                height: _height / 1.60,
                                child: FutureBuilder(
                                  builder: (ctx, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasError) {
                                        return const Center(
                                          child: Text(
                                              "No Product List Data Available.."),
                                        );
                                      } else if (snapshot.hasData) {
                                        return MediaQuery.removePadding(
                                          context: context,
                                          removeTop: true,
                                          child: ListView.builder(
                                            // physics: NeverScrollableScrollPhysics(),
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              _click.add(false);
                                              return ProductListItem(
                                                index: index,
                                                mst: snapshot.data[index],
                                                onEditProduct: _onEditProduct,
                                                click: _click[index],
                                                changeVal: changeVal,
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
                                                    icon: const Icon(Icons
                                                        .keyboard_arrow_down),
                                                    items:
                                                        items.map((int items) {
                                                      return DropdownMenuItem(
                                                        value: items,
                                                        child: CustomText(
                                                          text:
                                                              items.toString(),
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
                                                  _click = [];
                                                });
                                              },
                                            ),
                                          ),
                                          Expanded(
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
