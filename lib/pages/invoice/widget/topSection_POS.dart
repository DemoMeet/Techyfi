import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../../../model/Single.dart';
import '../../../widgets/custom_text.dart';

class POSTopSection extends StatefulWidget {
  TextEditingController search_customer;
  double width;
  var custmr = [];
  List<String> scustmr = [];
  Single selectedcustomerid;
  Future<void> Function(String, String) setcustpay;

  String selectedcustomer;
  final void Function(String) runFilter;
  POSTopSection(
      {required this.width,
      required this.runFilter,
      required this.custmr,
      required this.selectedcustomerid,
        required this.setcustpay,
      required this.scustmr,
      required this.selectedcustomer,
      required this.search_customer});

  @override
  State<POSTopSection> createState() => _POSTopSectionState();
}

class _POSTopSectionState extends State<POSTopSection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 50,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: "Invoice POS",
            size: 22,
            weight: FontWeight.bold,
          ),
          Expanded(flex: 1,
            child: SizedBox(
              height: 1,
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: TextField(
                controller: widget.search_customer,
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
                  hintText: 'Search By Name',
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (value) => widget.runFilter(value),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.only(left: widget.width / 70,),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.grey.shade500,
                ),
                borderRadius: BorderRadius.all(Radius.circular(10)),
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
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                  fit: FlexFit.loose,
                  showSelectedItems: false,
                  menuProps: const MenuProps(
                    backgroundColor: Colors.white,
                    elevation: 100,
                  ),
                  searchFieldProps: const TextFieldProps(
                    style: TextStyle(fontSize: 16),
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
                    style: TextStyle(fontSize: 16),
                  );
                },
                onChanged: (newValue) {
                  setState(() {
                    widget.selectedcustomer = newValue.toString();
                    if (newValue != "Walking Customer") {
                      widget.selectedcustomerid = widget.custmr[widget.scustmr.indexOf(newValue!)];
                      widget.setcustpay(widget.selectedcustomerid.id, widget.selectedcustomerid.name);
                    }
                  });
                  // print(newValue);
                  // setState(() {
                  //   widget.selectedcustomerid =
                  //   widget.custmr[widget.scustmr.indexOf(newValue)];
                  //   widget.selectedcustomer = newValue;
                  //   //widget.setcustpay();
                  // });
                },
                items: widget.scustmr,
                selectedItem: widget.custmr[0].name,
              )
              //   DropdownButton(
              //   underline: SizedBox(),
              //   isExpanded: true,
              //   hint: Text('Select Customer'),
              //   value: widget.selectedcustomer,
              //   onChanged: (newValue) {
              //     print(newValue);
              //     setState(() {
              //       widget.selectedcustomerid =
              //           widget.custmr[widget.scustmr.indexOf(newValue)];
              //       widget.selectedcustomer = newValue;
              //       //widget.setcustpay();
              //     });
              //   },
              //   items: widget.custmr.map((location) {
              //     return DropdownMenuItem(
              //       child: new Text(location.name),
              //       value: location.name,
              //     );
              //   }).toList(),
              // ),
            ),
          ),

          Expanded(flex: 4,
            child: SizedBox(
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
