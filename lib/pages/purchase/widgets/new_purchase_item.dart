import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../constants/style.dart';
import '../../../model/products.dart';
import '../../../model/purchase.dart';
import '../../../widgets/custom_text.dart';

class PurchaseItem extends StatefulWidget {
  List<String> sproduct = [];
  List<Product> product = [];
  int index;
  Function adddatase;
  Purchase listitem;
  Function(String,int)getStock;
  Function(Purchase) deleteItem;
  PurchaseItem(
      {
        required this.product,
        required this.index,
        required this.getStock,
        required this.sproduct,
        required  this.listitem,
        required  this.deleteItem,
        required  this.adddatase});
  @override
  State<PurchaseItem> createState() => _PurchaseItemState();
}

class _PurchaseItemState extends State<PurchaseItem> {

  void _selectedproduct() {
    setState(() {
      widget.listitem.supplierpricecontrollers.text =
          widget.listitem.productId.menuperprice.toString();
      widget.listitem.boxmrpcontrollers.text = widget.listitem.productId.perprice.toString();
     widget.getStock(widget.listitem.productId.id,widget.index);

      widget.listitem.boxqtycontrollers.text = "0";
      widget.listitem.totalPurpricecontroller.text = "0";
      widget.adddatase();

    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.listitem.expiredate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: buttonbg,
              onPrimary: Colors.white,
              onSurface: buttonbg,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != widget.listitem.expiredate) {
      setState(() {
        widget.listitem.expiredate = picked;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
          child: Row(
            children: [
              Expanded(
                flex: 7,
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
                      text: widget.listitem.productId.code.toString(),
                      size: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 13,
                child: Container(
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey.shade500,
                      ),
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        itemBuilder: (BuildContext context, dynamic item,
                                bool isSelected) =>
                            Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            item,
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
                          selectedItem ?? "sss",
                          style: TextStyle(fontSize: 12),
                        );
                      },
                      onChanged: (newValue) {
                        setState(() {
                          widget.listitem.productId = widget.product[widget.sproduct.indexOf(newValue!)];
                          widget.listitem.selectedproduct = newValue;
                          _selectedproduct();
                        });
                      },
                      items: widget.sproduct,
                      selectedItem: widget.listitem.selectedproduct.length == 0
                          ? "Product Name"
                          : widget.listitem.selectedproduct,
                    )
                    ),
              ),

              Expanded(
                  flex: 5,
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
                        text: widget.listitem.productId.strength +widget.listitem.productId.unit,
                        size: 12,
                      ),
                    ),
                  )),
              Expanded(
                flex: 6,
                child: Container(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade400,
                        ),
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: CustomText(
                        text: DateFormat.yMMMd()
                            .format(widget.listitem.expiredate)
                            .toString(),
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                  flex: 6,
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
                        text: widget.listitem.stockquantity.toString(),
                        size: 12,
                      ),
                    ),
                  )),


              Expanded(
                flex: 7,
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
                    controller: widget.listitem.boxqtycontrollers,
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
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      hintText: "0.0",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                    onChanged: (val) {
                      if(val.isEmpty){
                        widget.listitem.boxqtycontrollers.text = "0";
                      }
                      setState(() {
                        widget.listitem.totalPurpricecontroller.text = (double.parse(widget.listitem.boxqtycontrollers.text
                            .toString()) *
                            double.parse(widget
                                .listitem.supplierpricecontrollers.text)).toString();
                        widget.adddatase();
                      });
                    },
                  ),
                ),
              ),

              Expanded(
                flex: 7,
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
                        widget.listitem.supplierpricecontrollers.text = "0";
                      }
                      setState(() {
                        widget.listitem.totalPurpricecontroller.text = (double.parse(widget.listitem.boxqtycontrollers.text
                            .toString()) *
                            double.parse(widget
                                .listitem.supplierpricecontrollers.text)).toString();
                        widget.adddatase();
                      });
                    },
                    controller: widget.listitem.supplierpricecontrollers,
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
                    controller: widget.listitem.boxmrpcontrollers,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    style: TextStyle(fontSize: 12),onChanged: (val){

                    if(val.isEmpty){
                      widget.listitem.boxmrpcontrollers.text = "0";
                    }
                  },
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
                      hintText: "Box MRP",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),

              Expanded(
                flex: 12,
                child: Container(

                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.grey.shade500,
                    ),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.center,
                  child: TextFormField(
                    controller: widget.listitem.totalPurpricecontroller,
                    keyboardType: TextInputType.number,textAlign: TextAlign.center,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))
                    ],
                    style: TextStyle(fontSize: 12),
                    onChanged: (val){
                      if(val.isEmpty){
                        widget.listitem.totalPurpricecontroller.text = "0";
                      }
                      widget.adddatase();
                    },
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
                      hintText: "Box MRP",
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                flex: 5,
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
                      child: Icon(Icons.delete, color: Colors.red, size: 20),
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
          child: SizedBox(
            height: 0.2,
          ),
        ),
      ],
    );
  }
}
