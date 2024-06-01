import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/model/POSItem.dart';

import '../../../model/products.dart';
import '../../../widgets/custom_text.dart';
import 'package:get/get.dart';

class POSInvoiceItem extends StatefulWidget {
  POSItem posItem;
  void Function(POSItem) removeproductfrominvoice;
  Function adddatase;
  POSInvoiceItem(
      {required this.posItem,
      required this.removeproductfrominvoice,
      required this.adddatase});

  @override
  State<POSInvoiceItem> createState() => _POSInvoiceItemState();
}

class _POSInvoiceItemState extends State<POSInvoiceItem> {
  double width = 1200;
  var text;
  showProductDetailsDialog(POSItem posItem) {
    Get.dialog(
        barrierColor: Colors.transparent,
        barrierDismissible: true, Dialog(
          backgroundColor: Colors.white,
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width / 2.7,
            height: width / 4,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(width: 0.5, color: Colors.white),
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15)),
                        color: Colors.grey.shade200,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      width: double.infinity,
                      child: Row(
                        children: [
                          CustomText(
                            text: "Product Details",
                            size: 15,
                            weight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          Expanded(child: SizedBox()),
                          GestureDetector(
                            child: Icon(Icons.close),
                            onTap: () {
                              Get.back();
                            },
                          ),
                        ],
                      )),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Row(children: [
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(20),
                        child: widget.posItem.product.img
                            ? Image.network(widget.posItem.product.imgurl,
                                fit: BoxFit.cover)
                            : Image.asset("assets/images/def_product.jpg",
                                fit: BoxFit.fill),
                      )),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CustomText(
                                    text: "Product Name:  ",
                                    font: "opensans",
                                    size: 13,
                                    weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    text: widget.posItem.product.name,
                                    font: "inter",
                                    size: 12,
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  CustomText(
                                    text: "Strength:  ",
                                    font: "opensans",
                                    size: 13,
                                    weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    size: 13,
                                    text: widget.posItem.product.strength +
                                        " " +
                                        widget.posItem.product.unit,
                                    font: "inter",
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  CustomText(
                                    text: "Price:  ",
                                    font: "opensans",
                                    size: 13,
                                    weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    size: 13,
                                    text:
                                        "${widget.posItem.product.perprice}/=",
                                    font: "inter",
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  CustomText(
                                    text: "Stock:  ",
                                    font: "opensans",
                                    size: 13,
                                    weight: FontWeight.bold,
                                  ),
                                  CustomText(
                                    text: "${widget.posItem.totalstock}",
                                    font: "inter",
                                    size: 13,
                                  )
                                ],
                              ),
                              SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, right: 10, left: 5),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: CustomText(
                  text: widget.posItem.product.name,
                  size: 12,
                ),
              ),
            ),
          ),
          
          // Expanded(
          //   flex: 4,
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 2),
          //     decoration: BoxDecoration(
          //       color: Colors.grey.shade200,
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     alignment: Alignment.center,
          //     child: Container(
          //       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //       child: CustomText(
          //         text: DateFormat('dd-MM-yyyy')
          //             .format(widget.posItem.selectedStock.expireDate),
          //         size: 12,
          //       ),
          //     ),
          //   ),
          // ),
          
          Expanded(
            flex: 3,
            child: Container(
              height: 35,
              margin: EdgeInsets.symmetric(horizontal: 2),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: widget.posItem.totalstock == 0
                        ? Colors.red
                        : Colors.grey.shade300,
                    width: 0.5),
              ),
              child: widget.posItem.totalstock == 0
                  ? const Text(
                'Not Found',textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.red),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        controller: widget.posItem.quantity,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp(r'(^\d*\.?\d*)'))
                        ],
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(left: 2),
                          isDense: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        style: TextStyle(fontSize: 12),
                        onChanged: (val) {
                          if(val==null){
                            widget.posItem.quantity.text="0";
                          }
                          setState(() {
                              final number = int.tryParse(val);
                              if (number != null) {
                                final text = number
                                    .clamp(
                                        0,
                                        widget
                                            .posItem.selectedStock.productqty)
                                    .toString();
                                final selection = TextSelection.collapsed(
                                  offset: text.length,
                                );
                                widget.posItem.quantity.value =
                                    TextEditingValue(
                                  text: text,
                                  selection: selection,
                                );
                                widget.posItem.total =
                                    widget.posItem.product.perprice *
                                        double.parse(text);
                                widget.posItem.total = double.parse(
                                    widget.posItem.total.toStringAsFixed(2));
                              }
                            widget.adddatase();
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    color: Colors.grey[300],
                    child: Column(
                      children: [
                        GestureDetector(
                          child: Icon(
                            Icons.add,
                            size: width / 100,
                          ),
                          onTap: () {
                            setState(() {
                                if (widget.posItem.selectedStock.productqty >=
                                    double.parse(widget.posItem.quantity.text) +
                                        1) {
                                  widget.posItem.quantity.text =
                                      "${double.parse(widget.posItem.quantity.text) + 1}";
                                  widget.posItem.total =
                                      widget.posItem.product.perprice *
                                          double.parse(
                                              widget.posItem.quantity.text);
                                  widget.posItem.total = double.parse(
                                      widget.posItem.total.toStringAsFixed(2));
                                }

                              widget.adddatase();
                            });
                          },
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.remove,
                            size: width / 100,
                          ),
                          onTap: () {
                            setState(() {
                                if (!(double.parse(
                                        widget.posItem.quantity.text) <=
                                    0)) {
                                  widget.posItem.quantity.text =
                                      "${double.parse(widget.posItem.quantity.text) - 1}";
                                }
                                widget.posItem.total = widget
                                        .posItem.product.perprice *
                                    double.parse(widget.posItem.quantity.text);
                                widget.posItem.total = double.parse(
                                    widget.posItem.total.toStringAsFixed(2));

                              widget.adddatase();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: CustomText(
                  text: widget.posItem.product.perprice.toString(),
                  size: 12,
                ),
              ),
            ),
          ),
          
          Expanded(
            flex: 5,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: CustomText(
                  text: widget.posItem.total.toString(),
                  size: 12,
                ),
              ),
            ),
          ),
          
          Expanded(
            flex: 2,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(),
                  ),
                  GestureDetector(
                    onTap: () {
                      text = "";
                      widget.removeproductfrominvoice(widget.posItem);
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 2),
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        border: Border.all(width: 1, color: Colors.red),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: width / 120,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  GestureDetector(
                    onTap: () {
                      showProductDetailsDialog(widget.posItem);
                    },
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        border: Border.all(width: 1, color: Colors.green),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        Icons.remove_red_eye,
                        color: Colors.green,
                        size: width / 120,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
