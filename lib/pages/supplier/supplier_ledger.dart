import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/pages/supplier/widgets/supplier_ledger_item.dart';

import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../api/csv_ledger.dart';
import '../../api/pdf_customerledger.dart';
import '../../api/pdf_supplierledger.dart';
import '../../constants/style.dart';
import '../../model/Single.dart';
import '../../model/invoiceListModel.dart';
import '../../widgets/custom_text.dart';
import '../../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';

class SupplierLedger extends StatefulWidget {
  
  
  Navbools nn;
  SupplierLedger(
      {super.key,
      
      required this.nn,
      });
  @override
  State<SupplierLedger> createState() => _SupplierLedgerState();
}

class _SupplierLedgerState extends State<SupplierLedger> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  late ScrollController listScrollController;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  int val = 0;
  double previoubal = 0.0, currentbal = 0.0;
  bool _first = false, _fetch = false;
  var custmr = [],
      balancelist = [],
      descriptionlist = [],
      filterballist = [],
      filterdescriptionlist = [];

  List<String> scustmr = [];
  var _selectedSupplier;
  var _selectedSupplierid;

  List<InvoiceListModel> allInvoiceLists = [];
  List<InvoiceListModel> foundInvoiceLists = [];

  void apply() {
    if (!_first) {
      widget.nn.setnavbool();
      widget.nn.supplier = true;
      widget.nn.supplier_ledger= true;
      controller.onChange(false);
      _first = true;
    }
  }

  void _fetchDocuments() async {
    await FirebaseFirestore.instance
        .collection('Supplier')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        custmr.add(Single(name: element["Name"], id: element.id));
        scustmr.add(element["Name"].toString());
        setState(() {});
      });
    });
  }

  @override
  void initState() {
    _fetchDocuments();
    listScrollController = ScrollController();
    super.initState();
  }

  Future<void> _findData() async {
    if (startDate.compareTo(endDate) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Invalid Date! Start Date Has to Be Greater Then End Date."),
      ));
    } else {
      List<InvoiceListModel> results = [];
      var filterbal = [], filterdescription = [];
      for (int i = 0; i < allInvoiceLists.length; i++) {
        if ((allInvoiceLists[i].invoiceDate.compareTo(startDate) >= 0 &&
                allInvoiceLists[i].invoiceDate.compareTo(endDate) <= 0) ||
            (allInvoiceLists[i].invoiceDate.difference(startDate).inDays == 1 ||
                allInvoiceLists[i].invoiceDate.difference(endDate).inDays ==
                    1)) {
          results.add(allInvoiceLists[i]);
          filterbal.add(balancelist[i]);
          filterdescription.add(descriptionlist[i]);
        } else if (startDate.difference(endDate).inDays == 0) {
          if (allInvoiceLists[i].invoiceDate.compareTo(startDate) == 1) {
            results.add(allInvoiceLists[i]);
            filterbal.add(balancelist[i]);
            filterdescription.add(descriptionlist[i]);
          }
        }
      }
      foundInvoiceLists = [];
      setState(() {
        foundInvoiceLists = results;
        filterballist = filterbal;
        filterdescriptionlist = filterdescription;
        if (foundInvoiceLists.length == 0) {
          _fetch = false;
        } else {
          if (allInvoiceLists.indexOf(foundInvoiceLists[0]) != 0) {
            previoubal =
                balancelist[allInvoiceLists.indexOf(foundInvoiceLists[0]) - 1];
          } else {
            previoubal = 0;
          }
          currentbal = filterballist[filterballist.length - 1];
          _fetch = true;
        }
      });
    }
  }

  _selectSupplier() async {
    int s = 0;
    allInvoiceLists = [];
    foundInvoiceLists = [];
    balancelist = [];
    descriptionlist = [];
    await FirebaseFirestore.instance
        .collection('Purchase')
        .where("Supplier ID", isEqualTo: _selectedSupplierid.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        if (element["Due"] > 0) {
          if (element["Paid"] == 0) {
            descriptionlist
                .add("Debit for . ${_selectedSupplier}");
            allInvoiceLists.add(InvoiceListModel(
                discount: element["Discount"],
                total: element["Grand Total"],
                user: element['User'],profit: 0,
                due: element["Due"],
                paid: 0,accountID: element["Account ID"],retn: element["Return"],
                invoiceNo: element["Invoice No"],
                customerID: element["Supplier ID"],
                customerName: element["Supplier"],
                invoiceDate: element["Invoice Date"].toDate(),
                invoiceID: element.id,
                sl: s));

            if (balancelist.length == 0) {
              balancelist.add(element["Grand Total"]);
            } else {
              balancelist.add(
                  element["Grand Total"] + balancelist[balancelist.length - 1]);
            }
          } else {
            descriptionlist
                .add("Debits for . ${_selectedSupplier}");
            allInvoiceLists.add(InvoiceListModel(
                discount: element["Discount"],
                total: element["Grand Total"],
                due: element["Due"],
                paid: 0,
                invoiceNo: element["Invoice No"],retn: element["Return"],
                user: element['User'],profit: 0,
                customerID: element["Supplier ID"],
                customerName: element["Supplier"],accountID: element["Account ID"],
                invoiceDate: element["Invoice Date"].toDate(),
                invoiceID: element.id,
                sl: s));
            s++;
            if (balancelist.length == 0) {
              balancelist.add(element["Grand Total"]);
            } else {
              balancelist.add(
                  element["Grand Total"] + balancelist[balancelist.length - 1]);
            }
            descriptionlist
                .add("Credit for . ${_selectedSupplier}");
            allInvoiceLists.add( InvoiceListModel(
                discount: element["Discount"],
                total: element["Grand Total"],
                due: 0,
                paid: element["Paid"],
                invoiceNo: element["Invoice No"],accountID: element["Account ID"],
                user: element['User'],
                customerID: element["Supplier ID"],retn: element["Return"],
                customerName: element["Supplier"],profit: 0,
                invoiceDate: element["Invoice Date"].toDate(),
                invoiceID: element.id,
                sl: s));
            if (balancelist.length == 1) {
              balancelist.add(element["Grand Total"] - element["Paid"]);
            } else {
              balancelist
                  .add(balancelist[balancelist.length - 1] - element["Paid"]);
            }
          }
          s++;
        }
      });
    });


    await FirebaseFirestore.instance
        .collection('PaymentVoucher')
        .where("ID", isEqualTo: _selectedSupplierid.id)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        descriptionlist.add("Customer credit for . ${_selectedSupplier}");
        allInvoiceLists.add(InvoiceListModel(
            discount: 0,
            total: 0,
            due: 0,retn: false,
            paid: element["Amount"],accountID: "",
            invoiceNo: element["Voucher ID"],profit: 0,
            customerID: element["ID"],
            user: element['User'],
            customerName: element["Name"],
            invoiceDate: element["Date"].toDate(),
            invoiceID: element.id,
            sl: s));
        if (balancelist.length == 1) {
          balancelist.add(element["Amount"]);
        } else {
          balancelist
              .add(balancelist[balancelist.length - 1] - element["Amount"]);
        }
        s++;
      });
    });

    setState(() {
      foundInvoiceLists = allInvoiceLists;
    });
    // }
  }

  _selectstartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
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
    if (picked != null && picked != startDate)
      setState(() {
        startDate = picked;
      });
  }

  _selectendDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
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
    if (picked != null && picked != endDate)
      setState(() {
        endDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    Future.delayed(Duration.zero, () async {
      apply();
    });

    Future<List<InvoiceListModel>> getCust() async {
      return foundInvoiceLists;
    }

 

    List<InvoiceListModel> getlist() {
      return foundInvoiceLists;
    }

    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: MyAppBar(
            height: _height,
            width: _width,),
        body: Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            controller.screenSize.value
                ? SideMenuBig(widget.nn)
                : SideMenuSmall(widget.nn, ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: _height / 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: _width / 45, top: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "Supplier Ledger",
                          size: 22,
                          weight: FontWeight.bold,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        InkWell(
                          onTap: () {
                            if (foundInvoiceLists.isNotEmpty) {
                              CsvLedger.generateAndDownloadCsv(
                                  getlist(),
                                  balancelist,
                                  descriptionlist,
                                  false,
                                  'Supplier_List_Ledger.csv');
                            }
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
                            if (foundInvoiceLists.isNotEmpty) {
                              PdfSupplierLedger.generate(
                                  getlist(), balancelist, descriptionlist, _selectedSupplier,false);
                            }
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
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      left: 40,
                      right: (_width / 16) + 20,
                    ),
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Previous Balance : $previoubal",
                                style: TextStyle(
                                  fontSize: _width / 85,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Current Balance : $currentbal",
                                style: TextStyle(
                                  fontSize: _width / 85,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            margin: EdgeInsets.only(top: 10, bottom: 10),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Row(
                              children: [
                                _width > 950
                                    ? Container(
                                        alignment: Alignment.centerRight,
                                        child: CustomText(
                                          text: "Supplier",
                                          size: _width / 90,
                                        ),
                                      )
                                    : SizedBox(),
                                Container(
                                    width: _width / 6,
                                    margin: EdgeInsets.only(
                                        left: _width / 200, top: 5, bottom: 5),
                                    height: 40,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.grey.shade500,
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.white,
                                    ),
                                    child: DropdownSearch<String>(
                                      popupProps: PopupProps.menu(
                                        showSearchBox: true,
                                        itemBuilder: (BuildContext context,
                                                dynamic item,
                                                bool isSelected) =>
                                            Container(
                                          padding: EdgeInsets.all(15),
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              fontSize: _width / 100,
                                            ),
                                          ),
                                        ),
                                        fit: FlexFit.loose,
                                        showSelectedItems: false,
                                        menuProps: MenuProps(
                                          backgroundColor: Colors.white,
                                          elevation: 100,
                                        ),
                                        searchFieldProps: TextFieldProps(
                                          style: TextStyle(
                                            fontSize: _width / 100,
                                          ),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: "Search...",
                                          ),
                                        ),
                                      ),
                                      dropdownDecoratorProps:
                                          DropDownDecoratorProps(
                                        dropdownSearchDecoration:
                                            InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      dropdownBuilder: (context, selectedItem) {
                                        return Text(
                                          selectedItem ?? "Select Supplier",
                                          style: TextStyle(
                                            fontSize: _width / 100,
                                          ),
                                        );
                                      },
                                      onChanged: (Value) {
                                        setState(() {
                                          _selectedSupplier =
                                              Value.toString();
                                          _selectedSupplierid = custmr[
                                              scustmr.indexOf(Value!)];
                                          _selectSupplier();
                                        });
                                      },
                                      items: scustmr,
                                      selectedItem: _selectedSupplier,
                                    )),
                                _width > 950
                                    ? Container(
                                        margin:
                                            EdgeInsets.only(left: _width / 200),
                                        alignment: Alignment.centerRight,
                                        child: CustomText(
                                          text: "Start Date",
                                          size: _width / 90,
                                        ),
                                      )
                                    : SizedBox(),
                                _width > 660
                                    ? Container(
                                        margin:
                                            EdgeInsets.only(left: _width / 200),
                                        child: InkWell(
                                          onTap: () =>
                                              _selectstartDate(context),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                            ),
                                            child: CustomText(
                                              text: DateFormat.yMMMd()
                                                  .format(startDate)
                                                  .toString(),
                                              size: _width / 100,
                                            ),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                _width > 1000
                                    ? SizedBox(
                                        width: _width / 130,
                                      )
                                    : SizedBox(),
                                _width > 950
                                    ? Container(
                                        alignment: Alignment.centerRight,
                                        child: CustomText(
                                          text: "End Date",
                                          size: _width / 90,
                                        ),
                                      )
                                    : SizedBox(),
                                _width > 660
                                    ? Container(
                                        margin:
                                            EdgeInsets.only(left: _width / 200),
                                        child: InkWell(
                                          onTap: () => _selectendDate(context),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                            ),
                                            child: CustomText(
                                              text: DateFormat.yMMMd()
                                                  .format(endDate)
                                                  .toString(),
                                              size: _width / 100,
                                            ),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                SizedBox(
                                  width: _width / 120,
                                ),
                                _width > 660
                                    ? InkWell(
                                        onTap: () => _findData(),
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: CustomText(
                                            text: "Find",
                                            color: Colors.white,
                                            size: _width / 80,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: buttonbg,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      height: _height / 1.45,
                      margin: EdgeInsets.only(
                        left: (_width / 16) + 20,
                        right: (_width / 16) + 20,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey.shade500,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                !_fetch
                                    ? "Supplier Ledger - Supplier Receivable "
                                    : "Supplier Ledger - $_selectedSupplier ",
                                style: TextStyle(
                                  fontSize: _width / 70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                !_fetch
                                    ? " ( --/--/---- to ${DateFormat('--/--/----').format(DateTime.now())} ) "
                                    : " ( ${DateFormat('dd/MM/yyyy').format(startDate)} to ${DateFormat('dd/MM/yyyy').format(endDate)} ) ",
                                style: TextStyle(
                                  fontSize: _width / 70,
                                ),
                              )
                            ],
                          ),
                          Container(
                            color: Colors.grey.shade200,
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 10, bottom: 10),
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 30),
                                    child: Text(
                                      "SL",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tabletitle,
                                          fontFamily: 'inter'),
                                    ),
                                  ),
                                  flex: 1,
                                ),
                                Text("|"),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Date",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
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
                                      "Description",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: tabletitle,
                                          fontFamily: 'inter'),
                                    ),
                                  ),
                                  flex: 5,
                                ),
                                Text("|"),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 7),
                                    child: Text(
                                      "Debit",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
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
                                      "Credit",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
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
                                    margin: EdgeInsets.only(left: 7, right: 10),
                                    child: Text(
                                      "Balance",
                                      textAlign: TextAlign.right,
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
                          _fetch
                              ? Container(
                                  height: _height / 1.80,
                                  child: FutureBuilder(
                                    builder: (ctx, AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                                "No Supplier Ledger Data Available.."),
                                          );
                                        } else if (snapshot.hasData) {
                                          return MediaQuery.removePadding(
                                            context: context,
                                            removeTop: true,
                                            child: ListView.builder(
                                              // physics: NeverScrollableScrollPhysics(),
                                              itemCount: snapshot.data.length,
                                              itemBuilder: (context, index) {
                                                return SupplierLedgerItem(
                                                  index: index,
                                                  balancelist: filterballist,
                                                  cst: snapshot.data[index],
                                                  descriptionlist:
                                                      filterdescriptionlist,
                                                );
                                              },
                                            ),
                                          );
                                        }
                                      }
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    future: getCust(),
                                  ),
                                )
                              : CustomText(
                                  text: "No Record Found",
                                  size: 18,
                                  color: Colors.red,
                                  weight: FontWeight.bold,
                                ),
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
