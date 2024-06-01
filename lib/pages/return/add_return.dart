import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:groceyfi02/pages/return/return_invoice.dart';
import 'package:groceyfi02/pages/return/return_purchase.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../constants/style.dart';
import '../../model/invoiceListModel.dart';
import '../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';
import 'supplier_return_list.dart';

class AddReturn extends StatefulWidget {
  
  Navbools nn;
  AddReturn({required this.nn});
  @override
  State<AddReturn> createState() => _AddReturnState();
}

class _AddReturnState extends State<AddReturn> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  final _conreturninvoiceid = TextEditingController();
  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
 

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
                child: Container(
              margin: EdgeInsets.only(top: _height / 8, left: 30, right: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      text: "Add Return", size: 26, weight: FontWeight.bold),
                  const Expanded(
                    child: SizedBox(),
                    flex: 9,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: _width / 2,
                        color: Colors.white,
                        padding: EdgeInsets.only(right: 60, bottom: 20),
                        child: Column(
                          children: [
                            Container(
                                margin: EdgeInsets.only(
                                    left: 60, top: 20, bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: CustomText(
                                    text: "Return Product",
                                    size: 18,
                                    weight: FontWeight.bold)),
                            Container(
                              margin:
                                  EdgeInsets.only(top: 5, left: 70, bottom: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: CustomText(
                                        text: "Invoice Number",
                                        size: 16,
                                      )),
                                  Expanded(
                                    flex: 10,
                                    child: Container(
                                      child: TextFormField(
                                        controller: _conreturninvoiceid,
                                        decoration: InputDecoration(
                                          enabledBorder: const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                            borderSide: BorderSide(
                                                color: Colors.transparent),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5.0)),
                                            borderSide:
                                                BorderSide(color: Colors.blue),
                                          ),
                                          hintText: "Invoice No",
                                          fillColor: Colors.grey.shade200,
                                          filled: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Expanded(child: SizedBox()),
                                Container(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      FirebaseFirestore.instance
                                          .collection('Return')
                                      .where('Purchase', isEqualTo: false)
                                          .where('Invoice No',
                                              isEqualTo:
                                                  _conreturninvoiceid.text)
                                          .get()
                                          .then((bb) async {
                                        if (bb.size == 0) {
                                          await FirebaseFirestore.instance
                                              .collection('Invoice')
                                              .where("Invoice No",
                                                  isEqualTo:
                                                      _conreturninvoiceid.text)
                                              .get()
                                              .then((querySnapshot) {
                                            if (querySnapshot.size != 0) {
                                              querySnapshot.docs
                                                  .forEach((element) {
                                                InvoiceListModel cst =
                                                    InvoiceListModel(
                                                        discount:
                                                            element["Discount"],accountID: element["Account ID"],
                                                        total: element[
                                                            "Grand Total"],retn: element["Return"],
                                                        due: element["Due"],user: element['User'],
                                                        paid: element["Paid"],profit: 0,
                                                        invoiceNo: element[
                                                            "Invoice No"],
                                                        customerID: element[
                                                            "Customer ID"],
                                                        customerName:
                                                            element["Customer"],
                                                        invoiceDate: element[
                                                                "Invoice Date"]
                                                            .toDate(),
                                                        invoiceID: element.id,
                                                        sl: 0);
                                                if(cst.retn){
                                                  Get.snackbar(
                                                      "Rerun Adding Failed.", "Invoice Was Already Returned Once!!",
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      colorText: Colors.white,
                                                      backgroundColor: Colors.red,
                                                      margin: EdgeInsets.zero,
                                                      duration: const Duration(milliseconds: 2000),
                                                      boxShadows: [
                                                        BoxShadow(
                                                            color: Colors.grey, offset: Offset(-100, 0), blurRadius: 20),
                                                      ],
                                                      borderRadius: 0);
                                                }else{
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReturnInvoice(
                                                              cst: cst,
                                                              nn: widget.nn),
                                                    ),
                                                  );
                                                }
                                              });
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                    "Invalid Invoice No, Not Found in Invoice List."),
                                              ));
                                            }
                                          });
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                                "Invoice Is Already in Return. One Invoice can only return once."),
                                          ));
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrangeAccent,
                                      elevation: 20,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 20, horizontal: 10),
                                    ),
                                    child: CustomText(
                                      size: 14,
                                      text: "Return By Customer",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection('Return')
                                        .where('Purchase', isEqualTo: true)
                                        .where('Invoice No',
                                        isEqualTo:
                                        _conreturninvoiceid.text)
                                        .get()
                                        .then((bb) async {
                                      if (bb.size == 0) {
                                        await FirebaseFirestore.instance
                                            .collection('Purchase')
                                            .where("Invoice No",
                                            isEqualTo:
                                            _conreturninvoiceid.text)
                                            .get()
                                            .then((querySnapshot) {
                                          if (querySnapshot.size != 0) {
                                            querySnapshot.docs.forEach((element) {
                                              InvoiceListModel cst =
                                              InvoiceListModel(
                                                  discount:
                                                  element["Discount"],retn: element["Return"],
                                                  total:
                                                  element["Grand Total"],accountID: element["Account ID"],
                                                  due: element["Due"],user: element['User'],
                                                  paid: element["Paid"],
                                                  invoiceNo:
                                                  element["Invoice No"],profit: 0,
                                                  customerID: element[
                                                  "Supplier ID"],
                                                  customerName:
                                                  element["Supplier"],
                                                  invoiceDate:
                                                  element["Invoice Date"]
                                                      .toDate(),
                                                  invoiceID: element.id,
                                                  sl: 0);
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReturnPurchase(
                                                          cst: cst,
                                                          nn: widget.nn),
                                                ),
                                              );
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Text(
                                                  "Invalid Invoice No, Not Found in Invoice List."),
                                            ));
                                          }
                                        });
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                              "Invoice Is Already in Return. One Invoice can only return once."),
                                        ));
                                      }
                                    });

                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    elevation: 20,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 10),
                                  ),
                                  child: CustomText(
                                    text: "Return By Supplier",
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Expanded(
                    child: SizedBox(),
                    flex: 15,
                  )
                ],
              ),
            )),
          ],
        )));
  }
}
