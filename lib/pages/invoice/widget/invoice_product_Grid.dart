import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:groceyfi02/pages/invoice/widget/pos_invoice_item.dart';

import '../../../constants/style.dart';
import '../../../model/POSItem.dart';
import '../../../model/products.dart';
import '../../../widgets/custom_text.dart';

class InvoiceProductGrid extends StatefulWidget {
  bool column;
  double height, width, wit;
  Future<void> Function(int) addproducttoinvoice;
  Future<List<Product>> Function() getProduct;
  InvoiceProductGrid(
      {required this.column,
      required this.addproducttoinvoice,
      required this.height,
        required this.getProduct,
      required this.width,
      required this.wit});

  @override
  State<InvoiceProductGrid> createState() => _InvoiceProductGridState();
}

class _InvoiceProductGridState extends State<InvoiceProductGrid> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder(
        builder: (ctx,AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              if (snapshot.data.length == 0) {
                return Container(
                  alignment: Alignment.topLeft,
                  child: CustomText(
                    text: "No Product Available!!",
                    size: 22,
                    weight: FontWeight.bold,
                  ),
                );
              } else {
                return MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: GridView.builder(
                    itemCount: snapshot.data.length,
                    gridDelegate: widget.column
                        ? SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.9,
                          )
                        : SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: widget.wit > 1100
                                ? 4
                                : widget.wit > 870
                                    ? 3
                                    : 2,
                            childAspectRatio: widget.wit > 1100
                                ? 0.7
                                : widget.wit > 850
                                    ? 0.9
                                    : 1,
                          ),
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          widget.addproducttoinvoice(index);
                        },

                        hoverColor: Colors.grey[300],
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Colors.white,
                            border: Border.all(
                              width: 0.5,
                              color: Colors.white,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade400,
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(4, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: widget.height / 7,
                                child: snapshot.data[index].img
                                    ? Image.network(snapshot.data[index].imgurl,
                                        fit: BoxFit.cover)
                                    : Image.asset(
                                        "assets/images/def_product.jpg",
                                        fit: BoxFit.fill),
                              ),
                              const Expanded(
                                child: SizedBox(),
                                flex: 2,
                              ),
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: widget.column?const EdgeInsets.only(left: 10, right: 10):const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data[index].name +
                                          " (" +
                                          snapshot.data[index].strength +
                                          snapshot.data[index].unit +
                                          ")",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          fontFamily: 'inter',
                                          fontSize: widget.column?widget.width / 50: widget.width >
                                              1100
                                              ? widget.width /
                                              100
                                              : widget.width >
                                              850
                                              ? widget.width /
                                              90
                                              : widget.width /
                                              70,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "${snapshot.data[index].perprice} BDT",
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          fontFamily: 'inter',
                                          fontSize: widget.column?widget.width / 55: widget.width >
                                              1100
                                              ?  widget.width /
                                              110
                                              :  widget.width >
                                              850
                                              ?  widget.width /
                                              100
                                              :  widget.width /
                                              80,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SizedBox(),
                                flex: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        future: widget.getProduct(),
      ),
    );
  }
}
