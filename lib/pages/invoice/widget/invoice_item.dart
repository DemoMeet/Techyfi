import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../model/Single.dart';
import '../../../model/Stock.dart';
import '../../../model/invoice.dart';
import '../../../model/products.dart';
import '../../../widgets/custom_text.dart';

class InvoiceItem extends StatefulWidget {
  List<Product> product = [];
  Function adddatase;
  bool enabled;
  Invoice listitem;
  Function(Invoice) deleteItem;
  InvoiceItem(
      {
      required this.enabled,
      required this.product,
      required this.listitem,
      required this.deleteItem,
      required this.adddatase});
  @override
  State<InvoiceItem> createState() => _InvoiceItemState();
}

class _InvoiceItemState extends State<InvoiceItem> {
  var outputFormat = DateFormat('dd/MM/yyyy');


  Future<void> _getStock() async {
    await FirebaseFirestore.instance
        .collection('Stock')
        .doc(widget.listitem.productId.code)
        .get()
        .then((element) {
      setState(() {
        widget.listitem.stock  = Stock(
            productId: element["Product ID"],
            productName: element["Product Name"],
     //       expireDate: element["Expire Date"].toDate(),
            price: element["Price"],
            manuPrice: element["Supplier Price"],
            productqty: element["Quantity"],
            serial: 0,
            total: 0);
          widget.listitem.pricecontrollers.text = widget.listitem.productId.perprice.toString();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: CustomText(
                      text: widget.listitem.productId.code
                          .toString(),
                      size: 12,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                flex: 10,
                child: Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    padding: EdgeInsets.symmetric(horizontal: _width / 136.6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: DropdownSearch<Product>(
                      key: UniqueKey(),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        itemBuilder: (BuildContext context, dynamic item,
                                bool isSelected) =>
                            Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        fit: FlexFit.loose,
                        showSelectedItems: false,
                        menuProps: const MenuProps(
                          backgroundColor: Colors.white,
                          elevation: 100,
                        ),
                        searchFieldProps: const TextFieldProps(
                          style: TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "Search...",
                          ),
                        ),
                      ),
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      dropdownBuilder: (context, selectedItem) {
                        return Text(
                          selectedItem?.name ?? "Select Product",
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                      onChanged: (Product? newValue) {
                        setState(() {
                          widget.listitem.productId = newValue!;
                          widget.listitem.selectedproduct = newValue.name.toString();
                          _getStock();
                          widget.listitem.quantitycontrollers.text = "0";
                          widget.listitem.discountcontrollers.text = "0";
                          widget.listitem.total.text = "0";
                          widget.adddatase();
                        });
                      },
                      itemAsString: (Product u) => u.name,
                      items: widget.product,
                      selectedItem: widget.listitem.selectedproduct.isEmpty
                          ? null
                          : widget.listitem.productId,
                    )),
              ),

              Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.only(right: 5),
                    alignment: Alignment.center,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: CustomText(
                        text: widget.listitem.productId.category.toString(),
                        size: 12,
                      ),
                    ),
                  )),
              Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    margin: EdgeInsets.only(right: 5),
                    alignment: Alignment.center,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      child: CustomText(
                        text: widget.listitem.productId.strength + widget.listitem.productId.unit,
                        size: 12,
                      ),
                    ),
                  )),
          //     Expanded(
          //       flex: 5,
          //       child: Container(
          //         decoration: BoxDecoration(
          //           color: Colors.grey[400],
          //           borderRadius: BorderRadius.circular(5),
          //         ),
          //         margin: EdgeInsets.only(left: 5, right: 5),
          //         alignment: Alignment.center,
          //         child: Container(
          //           padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          //           child: CustomText(
          //   //          text: outputFormat
          // //                    .format(widget.listitem.stock.expireDate),
          //             size: 12,
          //           ),
          //         ),
          //       ),
          //     ),
              
              Expanded(
                flex: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(5),
                  ),
                  margin: EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: CustomText(
                      text: widget.listitem.stock.productqty
                              .toString(),
                      size: 12,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: TextFormField(
                    controller: widget.listitem.quantitycontrollers,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'(^\d*\.?\d*)')),
                    ],
                    style: const TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (val) {
                      if(val.isEmpty){
                        widget.listitem.quantitycontrollers.text = "0";
                      }
                      setState(() {
                        final number = int.tryParse(val);

                          if (number != null) {
                            final text = number
                                .clamp(0,
                                    widget.listitem.stock!.productqty)
                                .toString();
                            final selection = TextSelection.collapsed(
                              offset: text.length,
                            );
                            widget.listitem.quantitycontrollers.value =
                                TextEditingValue(
                              text: text,
                              selection: selection,
                            );
                          }

                        widget.listitem.total.text = (double.parse(widget
                            .listitem.quantitycontrollers.text
                            .toString()) *
                            double.parse(widget.listitem.pricecontrollers.text)).toString();
                        widget.adddatase();
                      });
                    },
                  ),
                ),
              ),
              
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: TextFormField(
                    onChanged: (val) {
                      if(val.isEmpty){
                        widget.listitem.pricecontrollers.text = "0";
                      }
                      setState(() {
                        widget.listitem.total.text = (double.parse(widget
                            .listitem.quantitycontrollers.text
                            .toString()) *
                            double.parse(widget.listitem.pricecontrollers.text)).toString();
                        widget.adddatase();
                      });
                    },
                    controller: widget.listitem.pricecontrollers,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    style: TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 5, right: 5),
                  child: TextFormField(
                    controller: widget.listitem.discountcontrollers,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    onChanged: (val){
                      if(val.isEmpty){
                        widget.listitem.discountcontrollers.text = "0";
                        widget.listitem.total.text = (double.parse(widget
                            .listitem.quantitycontrollers.text
                            .toString()) *
                            double.parse(widget.listitem.pricecontrollers.text)).toString();
                      }else{setState(() {
                        final number = int.tryParse(val);

                        if (number != null) {
                          final text = number
                              .clamp(0,
                              (double.parse(widget
                                  .listitem.quantitycontrollers.text
                                  .toString()) *
                                  double.parse(widget.listitem.pricecontrollers.text)))
                              .toString();
                          final selection = TextSelection.collapsed(
                            offset: text.length,
                          );
                          widget.listitem.discountcontrollers.value =
                              TextEditingValue(
                                text: text,
                                selection: selection,
                              );
                        }
                        widget.listitem.total.text = ((double.parse(widget
                            .listitem.quantitycontrollers.text
                            .toString()) *
                            double.parse(widget.listitem.pricecontrollers.text)) -
                            double.parse(widget.listitem.discountcontrollers.text)).toString();
                        widget.adddatase();
                      });
                      }
                    },
                    style: TextStyle(fontSize: 12),
                    decoration: const InputDecoration(
                      isDense: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 7,
                child: Container(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(left: 5, right: 5),
                    child:  TextFormField(
                      controller: widget.listitem.total,
                      keyboardType: TextInputType.number,textAlign: TextAlign.center,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                      ],
                      onChanged: (val){
                        if(val.isEmpty){
                          widget.listitem.total.text = "0";
                        }
                          widget.adddatase();
                      },
                      style: TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        isDense: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex:4,
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      widget.deleteItem(widget.listitem);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.red[50],
                      ),
                      child: const Icon(Icons.delete, color: Colors.red, size: 20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Colors.grey,
          width: double.infinity,
          margin: EdgeInsets.only(top: 2),
          child: const SizedBox(
            height: 0.2,
          ),
        ),
      ],
    );
  }
}
