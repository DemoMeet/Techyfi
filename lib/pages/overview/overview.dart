import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:groceyfi02/helpers/auth_service.dart';
import 'package:groceyfi02/pages/overview/widgets/barchart.dart';
import 'package:groceyfi02/pages/overview/widgets/hori_barchart.dart';
import 'package:groceyfi02/pages/overview/widgets/overview_widget.dart';
import 'package:groceyfi02/pages/overview/widgets/piechart.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

import '../../constants/style.dart';
import '../../model/Accounts.dart';
import '../../model/Expense.dart';
import '../../model/Lending.dart';
import '../../model/Stock.dart';
import '../../model/products.dart';
import '../../helpers/screen_size_controller.dart';
import 'package:get/get.dart';
import '../../model/productstock.dart';
import '../../model/nav_bools.dart';
import '../../widgets/side_menu_big.dart';
import '../../widgets/side_menu_small.dart';
import '../../widgets/topnavigaton.dart';
import 'package:get/get.dart';

class OverviewPage extends StatefulWidget {
  Navbools nn;
  OverviewPage({super.key, required this.nn});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());
  List<Lending> allLendings = [];
  var formatter = NumberFormat('#,##,000');
  var formatters = NumberFormat('#,##,#00');
  List<Accounts> accounts = [];
  List<Stock> allExpire = [];
  List<ProductStock> allStockout = [];
  bool loading = true;
  List<Stock> allsoldproduct = [];
  List<Expense> allExpenses = [];
  double dailysale = 0,
      customer = 0,
      product = 0,
      manufactur = 0,
      lending = 0,
      dailypurchase = 0,
      dailybank = 0,
      dailyprofit = 0,
      dailycash = 0,
      dailyexpense = 0;
  double sales = 0,
      expense = 0,
      expsal = 0,
      pur = 0,
      cjan = 0,
      cfeb = 0,
      cmar = 0,
      capr = 0,
      cmay = 0,
      cjun = 0,
      cjul = 0,
      caug = 0,
      csept = 0,
      coct = 0,
      cnov = 0,
      cdec = 0,
      ejan = 0,
      efeb = 0,
      emar = 0,
      eapr = 0,
      emay = 0,
      ejun = 0,
      ejul = 0,
      eaug = 0,
      esept = 0,
      eoct = 0,
      enov = 0,
      edec = 0;

  @override
  void initState() {
    super.initState();
    showdil();
  }

  void showdil() {
    getData();
  }

  getData() async {
    var results = await Future.wait([
      FirebaseFirestore.instance.collection('Customer').get(),
      FirebaseFirestore.instance.collection('Supplier').get(),
      FirebaseFirestore.instance.collection('Products').get(),
      FirebaseFirestore.instance.collection('Lending').get(),
      FirebaseFirestore.instance.collection('Stock').get(),
      FirebaseFirestore.instance.collection('Transaction').get(),
      FirebaseFirestore.instance.collection('Salary').get(),
      FirebaseFirestore.instance.collection('ExpenseItem').get(),
      FirebaseFirestore.instance.collection('Purchase').get(),
      FirebaseFirestore.instance.collection('Invoice').get(),
      FirebaseFirestore.instance.collection('InvoiceItem').get(),
      FirebaseFirestore.instance.collection('Expense').get(),
      FirebaseFirestore.instance.collection('Account').get(),
    ]);

    var customerQuery = results[0];
    var supplierQuery = results[1];
    var productsQuery = results[2];
    var lendingQuery = results[3];
    var expireStockQuery = results[4];
    var transactionQuery = results[5];
    var salaryQuery = results[6];
    var expenseItemQuery = results[7];
    var purchaseQuery = results[8];
    var invoiceQuery = results[9];
    var invoiceItemQuery = results[10];
    var expenseQuery = results[11];
    var accountQuery = results[12];

    customer = double.parse(customerQuery.docs.length.toString());
    manufactur = double.parse(supplierQuery.docs.length.toString());

    for (var medi in productsQuery.docs) {
      product++;
      double totalmediqty = 0;
      for (var element in expireStockQuery.docs) {
        if (element["Product ID"] == medi.id) {
          totalmediqty = totalmediqty + element["Quantity"];
        }
      }
      if (!(totalmediqty > 0)) {
        allStockout.add(ProductStock(
            product: Product(
              name: medi["Product Name"],
              category: medi["Category Name"],
              brand: medi["Brand Name"],
              user: medi['User'],
              id: medi.id,
              code: medi['Code'],bodyrate: medi["Body Rate"],
              sl: 0,
              details: medi["Product Details"],
              menuperprice: medi['Purchase Price'],
              perprice: medi["Product Price"],
              strength: medi["Strength"],
              unit: medi["Unit Name"],
              img: medi["Image"],
              imgurl: medi["ImageURL"],
            ),
            stocks: [],
            inqty: 0,
            outqty: 0,
            sl: 0,
            stockpurprice: 0,
            stocksaleprice: 0,
            stock: totalmediqty,
            purcahseprice: 0,
            saleprice: 0));
      }

      for (var element in invoiceItemQuery.docs) {
        if (element["Product ID"] == medi.id) {
          DateTime ss = element["Invoice Date"].toDate();
          if ((DateTime.now().month == ss.month) &&
              (DateTime.now().year == ss.year)) {
            allsoldproduct.add(Stock.forInvoice(
                productId: element["Product ID"],
                productName: element["Product Name"],
                expireDate: element["Expire Date"].toDate(),
                price: element["Price"],
                productqty: element["Quantity"],
                serial: element["Serial"],
                total: element["Total"],
                discount: element["Discount"]));
            if ((DateTime.now().day == ss.day)) {
              for (var elem in expireStockQuery.docs) {
                if (elem["Product ID"] == medi.id) {
                dailyprofit = dailyprofit +
                    ((element["Price"] - elem["Supplier Price"]) *
                        element["Quantity"]);}
            }
            }
          }
        }
      }
    }

    for (var element in lendingQuery.docs) {
      if (element["Status"] == "Current") {
        lending = lending + element["Amount"];
        DateTime ss = element["Return Date"].toDate();
        if (DateTime.now().isAfter(ss)) {
          allLendings.add(Lending(
              name: element["Lending Person Name"],
              phone: element["Lending Person Phone"],
              lendingpersonid: element["Lending Person ID"],
              status: element["Status"],
              uid: element["UID"],
              user: element['User'],
              remarks: element["Remarks"],
              sl: 0,
              amount: element["Amount"],
              returnedamount: element["Returned Amount"],
              date: element["Date"],
              returndate: element["Return Date"],
              lendingperson: element["Lending Person"],
              from: element["From"]));
        }
      }
    }

    for (var element in expireStockQuery.docs) {
      DateTime ss = element["Expire Date"].toDate();
      if (DateTime.now().isAfter(ss)) {
        allExpire.add(Stock(
            productId: element["Product ID"],
            productName: element["Product Name"],
            expireDate: element["Expire Date"].toDate(),
            price: element["Price"],
            manuPrice: element["Supplier Price"],
            productqty: element["Quantity"],
            serial: 0,
            total: 0));
      }
    }

    for (var element in transactionQuery.docs) {
      DateTime ss = element["Submit Date"].toDate();
      if ((DateTime.now().month == ss.month) &&
          (DateTime.now().day == ss.day) &&
          (DateTime.now().year == ss.year)) {
        if (element["Type"] == "Credit") {
          if (element["Account Details"]["Bank"]) {
            dailybank = dailybank + element["Amount"];
          } else {
            dailycash = dailycash + element["Amount"];
          }
        }
      }
    }

    for (var element in salaryQuery.docs) {
      DateTime ss = element["Date"].toDate();
      if ((DateTime.now().month == ss.month) &&
          (DateTime.now().year == ss.year)) {
        expsal = expsal + element["Gross Salary"];
        expense = expense + element["Gross Salary"];
      }
    }

    for (var element in expenseQuery.docs) {
      DateTime ss = element["Date"].toDate();
      if ((DateTime.now().month == ss.month) &&
          (DateTime.now().year == ss.year)) {
        allExpenses.add(Expense(
            sl: 0,
            uid: element["UID"],
            amount: element["Amount"],
            date: element["Date"],
            user: element['User'],
            expenseid: element["Expense ID"],
            expensename: element["Expense Name"],
            from: element["From"],
            others: element["Others"]));
        expense = expense + element["Amount"];
      }

      if ((DateTime.now().month == ss.month) &&
          (DateTime.now().day == ss.day) &&
          (DateTime.now().year == ss.year)) {
        dailyexpense = dailyexpense + element["Amount"];
      }
    }

    for (var element in purchaseQuery.docs) {
      DateTime ss = element["Invoice Date"].toDate();
      int year = DateTime.now().year;

      for (int i = 1; i <= 12; i++) {
        if (ss.month == i && ss.year == year) {
          switch (i) {
            case 1:
              ejan += element["Grand Total"];
              break;
            case 2:
              efeb += element["Grand Total"];
              break;
            case 3:
              emar += element["Grand Total"];
              break;
            case 4:
              eapr += element["Grand Total"];
              break;
            case 5:
              emay += element["Grand Total"];
              break;
            case 6:
              ejun += element["Grand Total"];
              break;
            case 7:
              ejul += element["Grand Total"];
              break;
            case 8:
              eaug += element["Grand Total"];
              break;
            case 9:
              esept += element["Grand Total"];
              break;
            case 10:
              eoct += element["Grand Total"];
              break;
            case 11:
              enov += element["Grand Total"];
              break;
            case 12:
              edec += element["Grand Total"];
              break;
          }
          pur += element["Grand Total"];
          break;
        }
      }

      if ((DateTime.now().month == ss.month) &&
          (DateTime.now().day == ss.day) &&
          (DateTime.now().year == ss.year)) {
        dailypurchase = dailypurchase + element["Grand Total"];
      }
    }

    for (var element in invoiceQuery.docs) {
      DateTime ss = element["Invoice Date"].toDate();
      int year = DateTime.now().year;

      for (int i = 1; i <= 12; i++) {
        if (ss.month == i && ss.year == year) {
          switch (i) {
            case 1:
              cjan += element["Grand Total"];
              break;
            case 2:
              cfeb += element["Grand Total"];
              break;
            case 3:
              cmar += element["Grand Total"];
              break;
            case 4:
              capr += element["Grand Total"];
              break;
            case 5:
              cmay += element["Grand Total"];
              break;
            case 6:
              cjun += element["Grand Total"];
              break;
            case 7:
              cjul += element["Grand Total"];
              break;
            case 8:
              caug += element["Grand Total"];
              break;
            case 9:
              csept += element["Grand Total"];
              break;
            case 10:
              coct += element["Grand Total"];
              break;
            case 11:
              cnov += element["Grand Total"];
              break;
            case 12:
              cdec += element["Grand Total"];
              break;
          }
          sales += element["Grand Total"];
          break;
        }
      }

      if ((DateTime.now().month == ss.month) &&
          (DateTime.now().day == ss.day) &&
          (DateTime.now().year == ss.year)) {
        dailysale = dailysale + element["Grand Total"];
      }
    }
    for (var element in accountQuery.docs) {
      accounts.add(Accounts(
          uid: element["UID"],
          accountname: element["Account Name"],
          accountnum: element["Account Number"],
          cashdetails: element["Cash Details"],
          cashname: element["Cash Name"],
          bal: element["Balance"],
          user: element['User'],
          sts: element["Status"],
          bankname: element["Bank Name"],
          bank: element["Bank"],
          branch: element["Branch"],
          sl: 0));
    }

    if (AuthService.to.isfirsttime.isTrue) {
      AuthService.to.setisfirsttime();
      showData();
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  List<Map<String, dynamic>> getTop10Products() {
    final Map<String, double> productQuantityMap = {};

    for (var stock in allsoldproduct) {
      final productName = stock.productName;
      final quantity = stock.productqty;

      if (!productQuantityMap.containsKey(productName)) {
        productQuantityMap[productName] = quantity;
      } else {
        productQuantityMap[productName] =
            (productQuantityMap[productName] ?? 0) + quantity;
      }
    }
    final sortedEntries = productQuantityMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top10Entries = sortedEntries.take(10);

    final List<Map<String, dynamic>> top10Products = top10Entries
        .map((entry) => {'productName': entry.key, 'quantity': entry.value})
        .toList();

    return top10Products;
  }

  List<Expense> getTop3Expenses(List<Expense> allExpenses) {
    Map<String, double> expenseSumMap = {};
    allExpenses.forEach((expense) {
      expenseSumMap.update(
        expense.expensename,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    });
    List<MapEntry<String, double>> sortedExpenses = expenseSumMap.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    List<String> top3Expenses =
        sortedExpenses.take(3).map((entry) => entry.key).toList();
    List<Expense> top3ExpenseObjects = allExpenses
        .where((expense) => top3Expenses.contains(expense.expensename))
        .toList();

    return top3ExpenseObjects;
  }

  showData() {
    if (allStockout.isEmpty && allExpire.isEmpty && allLendings.isEmpty) {
      setState(() {
        loading = false;
      });
    } else {
      Get.dialog(
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          Dialog(
            backgroundColor: Colors.white,
            elevation: 20,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
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
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.black87,
                              size: 26,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CustomText(
                              text: "Warnings",
                              size: 17,
                              weight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            const Expanded(child: SizedBox()),
                            GestureDetector(
                              child: Icon(Icons.close),
                              onTap: () {
                                Get.back();
                                setState(() {
                                  loading = false;
                                });
                              },
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 10),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          allExpire.length != 0
                              ? CustomText(
                                  text: "Date Expired Products",
                                  size: 16,
                                  weight: FontWeight.bold,
                                  color: Colors.black87,
                                )
                              : SizedBox(),
                          allExpire.length != 0
                              ? const SizedBox(
                                  height: 10,
                                )
                              : SizedBox(),
                          allExpire.length != 0
                              ? Container(
                                  color: Colors.grey.shade200,
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Product Name",
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
                                            "Batch ID",
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
                                          child: const Text(
                                            "Expire Date",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                      Text("|"),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: const Text(
                                            "Stock",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          allExpire.length != 0
                              ? SizedBox(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: allExpire.length,
                                      itemBuilder: (context, index) {
                                        Stock mst = allExpire[index];
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              16,
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15, top: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        mst.productName,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        mst.productId,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Text(
                                                        DateFormat.yMMMd()
                                                            .format(
                                                                mst.expireDate),
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.red,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      child: Text(
                                                        mst.productqty
                                                            .toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.red,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: .2,
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                width: double.infinity,
                                                color: tabletitle,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          allExpire.length != 0
                              ? const SizedBox(
                                  height: 10,
                                )
                              : SizedBox(),
                          allStockout.length != 0
                              ? CustomText(
                                  text: "Stocked Out Products",
                                  size: 16,
                                  weight: FontWeight.bold,
                                  color: Colors.black87,
                                )
                              : SizedBox(),
                          allStockout.length != 0
                              ? const SizedBox(
                                  height: 10,
                                )
                              : SizedBox(),
                          allStockout.length != 0
                              ? Container(
                                  color: Colors.grey.shade200,
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
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
                                      Text("|"),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Supplier Name",
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
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: const Text(
                                            "Stock",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontFamily: 'inter'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox(),
                          allStockout.length != 0
                              ? SizedBox(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: allStockout.length,
                                      itemBuilder: (context, index) {
                                        ProductStock mst = allStockout[index];
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              16,
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15, top: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        "${mst.product.name}(${mst.product.strength}${mst.product.unit})",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        mst.product.name,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      child: Text(
                                                        mst.stock.toString(),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.red,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: .2,
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                width: double.infinity,
                                                color: tabletitle,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          allStockout.isNotEmpty
                              ? const SizedBox(
                                  height: 10,
                                )
                              : SizedBox(),
                          allLendings.length != 0
                              ? CustomText(
                                  text: "Lending Payment To Be Received",
                                  size: 16,
                                  weight: FontWeight.bold,
                                  color: Colors.black87,
                                )
                              : SizedBox(),
                          allLendings.length != 0
                              ? const SizedBox(
                                  height: 10,
                                )
                              : SizedBox(),
                          allLendings.length != 0
                              ? Container(
                                  color: Colors.grey.shade200,
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 10, bottom: 10),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Person Name",
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
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Phone",
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
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Lending Date",
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
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          child: Text(
                                            "Return Date",
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
                                        child: Container(
                                          margin: EdgeInsets.only(left: 7),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Amount",
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
                                )
                              : SizedBox(),
                          allLendings.length != 0
                              ? SizedBox(
                                  child: MediaQuery.removePadding(
                                    context: context,
                                    removeTop: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: allLendings.length,
                                      itemBuilder: (context, index) {
                                        Lending cst = allLendings[index];
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              16,
                                          padding: EdgeInsets.only(
                                              left: 15, right: 15, top: 10),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        cst.name,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        cst.phone,
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        DateFormat.yMMMd()
                                                            .format(cst.date
                                                                .toDate())
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      child: Text(
                                                        DateFormat.yMMMd()
                                                            .format(cst
                                                                .returndate
                                                                .toDate())
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 7),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        cst.amount.toString(),
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: tabletitle,
                                                            fontFamily:
                                                                'inter'),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                height: .2,
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                width: double.infinity,
                                                color: tabletitle,
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : SizedBox(),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return loading
        ? SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/medbg.jpeg"),
                      fit: BoxFit.cover)),
              child: const CircularProgressIndicator(),
            ),
          )
        : Scaffold(
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
                        child: SingleChildScrollView(
                      child: Container(
                          margin: EdgeInsets.only(
                              top: _height / 6.5, left: 60, right: 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: CustomText(
                                    text: "Dashboard",
                                    size: 34,
                                    weight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  OverViewWidget(
                                    color: c1,
                                    text: "TOTAL CUSTOMER",
                                    icon: "assets/icons/side_bar/l1.png",
                                    number:
                                        formatters.format(customer).toString(),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  OverViewWidget(
                                    color: c2,
                                    text: "TOTAL PRODUCT",
                                    icon: "assets/icons/side_bar/l2.png",
                                    number:
                                        formatters.format(product).toString(),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  OverViewWidget(
                                    color: c3,
                                    text: "TOTAL SUPPLIER",
                                    icon: "assets/icons/side_bar/manu.png",
                                    number: formatters
                                        .format(manufactur)
                                        .toString(),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  OverViewWidget(
                                    color: c4,
                                    text: "TOTAL LENDING",
                                    icon: "assets/icons/side_bar/lending.png",
                                    number: formatters.format(lending).toString(),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              AuthService.to.isAdmin()
                                  ? Container(
                                      height: 150,
                                      child: MediaQuery.removePadding(
                                        removeTop: true,
                                        context: context,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: accounts.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              width: 200,
                                              decoration: BoxDecoration(
                                                color: accounts[index].bank
                                                    ? const Color(0xFF53A8AE)
                                                    : const Color(0xFF71357B),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      spreadRadius: 3,
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(2, 5)),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                              padding: const EdgeInsets.all(20),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          color: Colors
                                                              .grey.shade200,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        child: accounts[index]
                                                                .bank
                                                            ? Image.asset(
                                                                "assets/images/bank.png",
                                                                width: 30,
                                                                height: 30,
                                                                fit:
                                                                    BoxFit.fill)
                                                            : Image.asset(
                                                                "assets/images/cash.png",
                                                                width: 30,
                                                                height: 30,
                                                                fit: BoxFit
                                                                    .fill),
                                                      ),
                                                      Expanded(
                                                          child: SizedBox()),
                                                      CustomText(
                                                        text:
                                                            accounts[index].bank
                                                                ? "Bank"
                                                                : "Cash",
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                  CustomText(
                                                    text: formatters
                                                        .format(
                                                            accounts[index].bal)
                                                        .toString(),
                                                    color: Colors.white,
                                                    size: 32,
                                                    font: 'opensans',
                                                    weight: FontWeight.bold,
                                                  ),
                                                  CustomText(
                                                    text: accounts[index].bank
                                                        ? "${accounts[index].bankname} (${accounts[index].accountnum})"
                                                        : "${accounts[index].cashname} (${accounts[index].cashdetails})",
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : SizedBox(),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 3,
                                              blurRadius: 4,
                                              offset: const Offset(2, 5)),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: _width / 2 + 30,
                                            margin: EdgeInsets.only(right: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 20, left: 25),
                                                  child: CustomText(
                                                      text:
                                                          "Monthly Progress Report",
                                                      color:
                                                          Colors.grey.shade700,
                                                      size: 22,
                                                      font: 'inter',
                                                      weight: FontWeight.bold),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 20),
                                                      child: Text(
                                                        "Sales ${formatter.format(sales)}/-",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'opensans',
                                                          color: c2,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 2,
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 25),
                                                      child: Text(
                                                        "Purchase ${formatter.format(pur)}/-",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'opensans',
                                                          color: c1,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: _width / 2 + 50,
                                            height: 0.5,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25),
                                              width: _width / 2,
                                              height: _height / 2.3,
                                              child: BarrChart(
                                                  cjan: cjan,
                                                  cfeb: cfeb,
                                                  cmar: cmar,
                                                  capr: capr,
                                                  cmay: cmay,
                                                  cjun: cjun,
                                                  cjul: cjul,
                                                  caug: caug,
                                                  csept: csept,
                                                  coct: coct,
                                                  cnov: cnov,
                                                  cdec: cdec,
                                                  ejan: ejan,
                                                  efeb: efeb,
                                                  emar: emar,
                                                  eapr: eapr,
                                                  emay: emay,
                                                  ejun: ejun,
                                                  ejul: ejul,
                                                  eaug: eaug,
                                                  esept: esept,
                                                  eoct: eoct,
                                                  enov: enov,
                                                  edec: edec)),
                                        ],
                                      )),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 3,
                                              blurRadius: 4,
                                              offset: const Offset(2, 5)),
                                        ],
                                      ),
                                      margin: EdgeInsets.only(right: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 25, left: 25),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomText(
                                                    text: "Monthly Expense",
                                                    color: Colors.grey.shade700,
                                                    size: 12,
                                                    font: 'inter',
                                                    weight: FontWeight.w500),
                                                CustomText(
                                                    text:
                                                        " (${DateFormat('MMM').format(DateTime.now())})",
                                                    color: c1,
                                                    font: 'inter',
                                                    size: 12,
                                                    weight: FontWeight.w900),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 25),
                                            child: CustomText(
                                              text: formatter
                                                  .format(expense)
                                                  .toString(),
                                              font: 'opensans',
                                              color: Color(0xFF1A1E30),
                                              weight: FontWeight.bold,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: _width / 6 + 50,
                                            height: 0.5,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25),
                                              width: _width / 6,
                                              height: _height / 2.3,
                                              child: PieCharts(
                                                expensal: expsal,
                                                expense: expense,
                                                top3Expenses: getTop3Expenses(
                                                    allExpenses),
                                              )),
                                        ],
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 3,
                                              blurRadius: 4,
                                              offset: const Offset(2, 5)),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 25),
                                                child: CustomText(
                                                  text: "Daily Report",
                                                  font: 'opensans',
                                                  color: Colors.grey,
                                                  weight: FontWeight.bold,
                                                  size: 18,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                child: CustomText(
                                                  text:
                                                      " (${DateFormat('EEEE').format(DateTime.now())})",
                                                  font: 'opensans',
                                                  color: c1,
                                                  weight: FontWeight.bold,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            width: _width / 3.8 + 50,
                                            height: 0.5,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25),
                                              width: _width / 3.8,
                                              height: _height / 2,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        color: c1),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        const Expanded(
                                                          child: Text(
                                                              "Today's Report",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'inter',
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                        Container(
                                                          height: 50,
                                                          color: Colors.white,
                                                          width: 1,
                                                        ),
                                                        const Expanded(
                                                          child: Text("Amount",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'inter',
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Total Sales",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            formatter
                                                                .format(
                                                                    dailysale)
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: c1,
                                                    width: double.infinity,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Total Purchase",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            formatter
                                                                .format(
                                                                    dailypurchase)
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: c1,
                                                    width: double.infinity,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Cash Receives",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            formatter
                                                                .format(
                                                                    dailycash)
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: c1,
                                                    width: double.infinity,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Bank Receives",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            formatter
                                                                .format(
                                                                    dailybank)
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: c1,
                                                    width: double.infinity,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Total Expense",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            formatter
                                                                .format(
                                                                    dailyexpense)
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: c1,
                                                    width: double.infinity,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            "Total Profit",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                            formatter
                                                                .format(
                                                                    dailyprofit)
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'inter',
                                                              color: c1,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                      Container(
                                                        height: 50,
                                                        color: c1,
                                                        width: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 1,
                                                    color: c1,
                                                    width: double.infinity,
                                                  ),
                                                ],
                                              )),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      )),
                                  Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.3),
                                              spreadRadius: 3,
                                              blurRadius: 4,
                                              offset: const Offset(2, 5)),
                                        ],
                                      ),
                                      margin: const EdgeInsets.only(right: 15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 25,
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 25),
                                                child: CustomText(
                                                  text:
                                                      "Best Sales Of The Month",
                                                  font: 'opensans',
                                                  color: Colors.grey,
                                                  weight: FontWeight.bold,
                                                  size: 18,
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 5),
                                                child: CustomText(
                                                  text:
                                                      " (${DateFormat('MMM').format(DateTime.now())})",
                                                  font: 'opensans',
                                                  color: c1,
                                                  weight: FontWeight.bold,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            width: _width / 2.5 + 50,
                                            height: 0.5,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25),
                                              width: _width / 2.5,
                                              height: _height / 2,
                                              child: BarrChart2(
                                                top10product:
                                                    getTop10Products(),
                                              )),
                                        ],
                                      )),
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                            ],
                          )),
                    )),
                  ],
                )));
  }
}
