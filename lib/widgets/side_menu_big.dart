import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/constants/style.dart';
import 'package:groceyfi02/helpers/auth_service.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/custom_text.dart';
import 'package:groceyfi02/widgets/side_menu_item.dart';
import 'package:groceyfi02/widgets/side_menu_itemss.dart';
import 'package:groceyfi02/widgets/side_menu_sub_item.dart';

import '../model/nav_bools.dart';

class SideMenuBig extends StatefulWidget {
  Navbools nn;

  SideMenuBig(this.nn, {super.key});

  @override
  State<SideMenuBig> createState() => _SideMenuBigState();
}

class _SideMenuBigState extends State<SideMenuBig> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: dark,
      height: height,
      width: width / 5.53,
      padding: EdgeInsets.only(top: height / 7.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: CustomText(
                text: "MAIN MENU",
                color: lightGrey,
                size: 10,
              )),
          SizedBox(
            height: height / 1.4,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .pushReplacementNamed(dashboardPageRoute);
                      setState(() {
                        if (!widget.nn.dashboard) {
                          widget.nn.setnavbool();
                          widget.nn.dashboard = true;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      decoration: widget.nn.dashboard
                          ? BoxDecoration(color: darkselect)
                          : const BoxDecoration(),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                            height: 25,
                            child: DecoratedBox(
                              decoration: widget.nn.dashboard
                                  ? const BoxDecoration(
                                      color: Color(0xFF56CCF2),
                                    )
                                  : BoxDecoration(),
                            ),
                          ),
                          SizedBox(
                            width: width / 60,
                          ),
                          Image.asset(
                            widget.nn.dashboard
                                ? "assets/icons/side_bar/dashboard_selected.png"
                                : "assets/icons/side_bar/dashboard.png",
                            width: 20,
                          ),
                          SizedBox(
                            width: width / 100,
                          ),
                          Flexible(
                            child: CustomText(
                              text: "Dashboard",
                              color:
                                  widget.nn.dashboard ? maincolor : lightGrey,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AuthService.to.isAdmin()?InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.customer) {
                          widget.nn.setnavbool();
                          widget.nn.customer = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.customer = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.customer,
                        name: "Customer",
                        iname: "assets/icons/side_bar/customer.png",
                        inames: "assets/icons/side_bar/customer_selected.png"),
                  ):SizedBox(),
                  AuthService.to.isAdmin()?widget.nn.customer
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.customer_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.customer = true;
                                    widget.nn.customer_add = true;
                                  }
                                  Get.offNamed(addcustomerPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.customer_add,
                                  name: "Add Customer"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.customer_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.customer = true;
                                    widget.nn.customer_list = true;
                                  }
                                  Get.offNamed(customerlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.customer_list,
                                  name: "Customer List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.customer_credit) {
                                    widget.nn.setnavbool();
                                    widget.nn.customer = true;
                                    widget.nn.customer_credit = true;
                                  }

                                  Get.offNamed(customercreditPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.customer_credit,
                                  name: "Customer Credit"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.customer_paid) {
                                    widget.nn.setnavbool();
                                    widget.nn.customer = true;
                                    widget.nn.customer_paid = true;
                                  }

                                  Get.offNamed(customerpaidPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.customer_paid,
                                  name: "Paid Customer"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.customer_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.customer = true;
                                    widget.nn.customer_ledger = true;
                                  }

                                  Get.offNamed(customerledgerPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.customer_ledger,
                                  name: "Customer Ledger"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ):SizedBox(),
                  AuthService.to.isAdmin()?InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.supplier) {
                          widget.nn.setnavbool();
                          widget.nn.supplier = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.supplier = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.supplier,
                        name: "Supplier",
                        iname: "assets/icons/side_bar/supplier.png",
                        inames:
                            "assets/icons/side_bar/supplier_selected.png"),
                  ):SizedBox(),
                  AuthService.to.isAdmin()?widget.nn.supplier
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.supplier_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.supplier = true;
                                    widget.nn.supplier_add = true;
                                  }

                                  Get.offNamed(addsupplierPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.supplier_add,
                                  name: "Add Supplier"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.supplier_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.supplier = true;
                                    widget.nn.supplier_list = true;
                                  }

                                  Get.offNamed(supplierlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.supplier_list,
                                  name: "Supplier List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.supplier_ledger) {
                                    widget.nn.setnavbool();
                                    widget.nn.supplier = true;
                                    widget.nn.supplier_ledger = true;
                                  }

                                  Get.offNamed(supplierledgerPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.supplier_ledger,
                                  name: "Supplier Ledger"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ):SizedBox(),
                  AuthService.to.isAdmin()?InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.product) {
                          widget.nn.setnavbool();
                          widget.nn.product = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.product = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.product,
                        name: "Product",
                        iname: "assets/icons/side_bar/product.png",
                        inames: "assets/icons/side_bar/product_selected.png"),
                  ):SizedBox(),
                  AuthService.to.isAdmin()?widget.nn.product
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.category_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.category_add = true;
                                  }

                                  Get.offNamed(addcategoryPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.category_add,
                                  name: "Add Category"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.category_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.category_list = true;
                                  }

                                  Get.offNamed(categorylistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.category_list,
                                  name: "Category List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.unit_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.unit_add = true;
                                  }

                                  Navigator.of(context)
                                      .pushReplacementNamed(addunitPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.unit_add, name: "Add Unit"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.unit_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.unit_list = true;
                                  }

                                  Navigator.of(context)
                                      .pushReplacementNamed(unitlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.unit_list,
                                  name: "Unit List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.brand_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.brand_add = true;
                                  }

                                  Navigator.of(context)
                                      .pushReplacementNamed(addbrandPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.brand_add, name: "Add brand"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.brand_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.brand_list = true;
                                  }

                                  Navigator.of(context)
                                      .pushReplacementNamed(brandlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.brand_list,
                                  name: "brand List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.product_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.product_add = true;
                                  }

                                  Get.offNamed(addproductPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.product_add,
                                  name: "Add Product"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.product_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.product = true;
                                    widget.nn.product_list = true;
                                  }

                                  Get.offNamed(productlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.product_list,
                                  name: "Product List"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ):SizedBox(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.purchase) {
                          widget.nn.setnavbool();
                          widget.nn.purchase = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.purchase = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.purchase,
                        name: "Purchase",
                        iname: "assets/icons/side_bar/purchase.png",
                        inames: "assets/icons/side_bar/purchase_selected.png"),
                  ),
                  widget.nn.purchase
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.purchase_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.purchase = true;
                                    widget.nn.purchase_add = true;
                                  }

                                  Get.offNamed(addpurchasePageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.purchase_add,
                                  name: "Add Purchase"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.purchase_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.purchase = true;
                                    widget.nn.purchase_list = true;
                                  }

                                  Get.offNamed(purchaselistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.purchase_list,
                                  name: "Purchase List"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.invoice) {
                          widget.nn.setnavbool();
                          widget.nn.invoice = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.invoice = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.invoice,
                        name: "Invoice",
                        iname: "assets/icons/side_bar/invoice.png",
                        inames: "assets/icons/side_bar/invoice_selected.png"),
                  ),
                  widget.nn.invoice
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.invoice_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.invoice = true;
                                    widget.nn.invoice_add = true;
                                  }

                                  Get.offNamed(addinvoicePageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.invoice_add,
                                  name: "Add Invoice"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.invoice_pos) {
                                    widget.nn.setnavbool();
                                    widget.nn.invoice = true;
                                    widget.nn.invoice_pos = true;
                                  }

                                  Get.offNamed(posinvoicePageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.invoice_pos,
                                  name: "POS Invoice"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.invoice_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.invoice = true;
                                    widget.nn.invoice_list = true;
                                  }

                                  Get.offNamed(invoicelistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.invoice_list,
                                  name: "Invoice List"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.returnss) {
                          widget.nn.setnavbool();
                          widget.nn.returnss = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.returnss = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.returnss,
                        name: "Return",
                        inames: "assets/icons/side_bar/return_selected.png",
                        iname: "assets/icons/side_bar/return.png"),
                  ),
                  widget.nn.returnss
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.return_add) {
                                    widget.nn.setnavbool();
                                    widget.nn.returnss = true;
                                    widget.nn.return_add = true;
                                  }

                                  Navigator.of(context)
                                      .pushReplacementNamed(addreturnPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.return_add,
                                  name: "Add Return"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.return_invoice_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.returnss = true;
                                    widget.nn.return_invoice_list = true;
                                  }

                                  Get.offNamed(invoicereturnlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.return_invoice_list,
                                  name: "Invoice Return List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.return_supplier_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.returnss = true;
                                    widget.nn.return_supplier_list = true;
                                  }

                                  Get.offNamed(supplierreturnlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.return_supplier_list,
                                  name: "Supplier Return List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.return_wastage_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.returnss = true;
                                    widget.nn.return_wastage_list = true;
                                  }

                                  Get.offNamed(wasteagereturnlistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.return_wastage_list,
                                  name: "Wastage Return List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.return_wastage) {
                                    widget.nn.setnavbool();
                                    widget.nn.returnss = true;
                                    widget.nn.return_wastage = true;
                                  }
                                  Get.offNamed(returnwasteagePageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.return_wastage,
                                  name: "Return Wastage (Product)"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.return_trashbin) {
                                    widget.nn.setnavbool();
                                    widget.nn.returnss = true;
                                    widget.nn.return_trashbin = true;
                                  }
                                  Get.offNamed(trashbinPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.return_trashbin,
                                  name: "Exchange/Trash Bin"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.stock) {
                          widget.nn.setnavbool();
                          widget.nn.stock = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.stock = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.stock,
                        name: "Stock",
                        inames: "assets/icons/side_bar/stock_selected.png",
                        iname: "assets/icons/side_bar/stock.png"),
                  ),
                  widget.nn.stock
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.stock) {
                                    widget.nn.setnavbool();
                                    widget.nn.stock = true;
                                    widget.nn.stock_report = true;
                                  }

                                  Get.offNamed(stockreportPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.stock_report,
                                  name: "Stock Report"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.stock) {
                                    widget.nn.setnavbool();
                                    widget.nn.stock = true;
                                    widget.nn.stock_available = true;
                                  }

                                  Get.offNamed(availablestockPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.stock_available,
                                  name: "Available Stock"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                  AuthService.to.isAdmin()?InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.account) {
                          widget.nn.setnavbool();
                          widget.nn.account = true;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.account,
                        name: "Account",
                        inames: "assets/icons/side_bar/account_selected.png",
                        iname: "assets/icons/side_bar/account.png"),
                  ):SizedBox(),
                  AuthService.to.isAdmin()?widget.nn.account
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_add_account) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_add_account = true;
                                  }
                                  Get.offNamed(addaccount);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_add_account,
                                  name: "Add Account"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_list = true;
                                  }
                                  Get.offNamed(accountlist);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_list,
                                  name: "Accounts List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.transactions) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.transactions = true;
                                  }
                                  Get.offNamed(transactions);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.transactions,
                                  name: "Transactions"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_supplier_payment) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_supplier_payment = true;
                                  }
                                  Get.offNamed(supplierpayment);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_supplier_payment,
                                  name: "Supplier Payment"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_customer_receives) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_customer_receives = true;
                                  }
                                  Get.offNamed(customerpayment);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_customer_receives,
                                  name: "Customers Receives"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_supplier_cheque) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_supplier_cheque = true;
                                  }
                                  Get.offNamed(suppliercheque);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_supplier_cheque,
                                  name: "Supplier Cheque"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_customer_cheque) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_customer_cheque = true;
                                  }
                                  Get.offNamed(customercheque);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_customer_cheque,
                                  name: "Customers Cheque"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_cheque_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_cheque_list = true;
                                  }
                                  Get.offNamed(chequelist);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_cheque_list,
                                  name: "Issued Cheque List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_selftransaction) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_selftransaction = true;
                                  }
                                  Get.offNamed(selftransaction);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_selftransaction,
                                  name: "Balance Transfers"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_selftransactionlist) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_selftransactionlist = true;
                                  }
                                  Get.offNamed(selftransactionslist);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_selftransactionlist,
                                  name: "Balance Transfers List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.account_report) {
                                    widget.nn.setnavbool();
                                    widget.nn.account = true;
                                    widget.nn.account_report = true;
                                  }
                                  Get.offNamed(paymentreport);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.account_report,
                                  name: "Account Report"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ):SizedBox(),
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.report) {
                          widget.nn.setnavbool();
                          widget.nn.report = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.report = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.report,
                        name: "Report",
                        inames: "assets/icons/side_bar/report_selected.png",
                        iname: "assets/icons/side_bar/report.png"),
                  ),
                  widget.nn.report
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_add_closing = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_add_closing = false;
                                  }
                                  Get.offNamed(addclosingPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_add_closing,
                                  name: "Add Closing"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_closing_list = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_closing_list = false;
                                  }
                                  Get.offNamed(closinglistPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_closing_list,
                                  name: "Closing List"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_sales = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_sales = false;
                                  }
                                  Get.offNamed(invoicereportPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_sales,
                                  name: "Sales Report"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_sales_user = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_sales_user = false;
                                  }
                                  Get.offNamed(invoicereportuserPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_sales_user,
                                  name: "Sales Report (User)"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_sales_products = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_sales_products = false;
                                  }
                                  Get.offNamed(invoicereportproductPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_sales_products,
                                  name: "Sales Report (Product)"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_sales_category = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_sales_category = false;
                                  }
                                  Get.offNamed(invoicereportcategoryPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_sales_category,
                                  name: "Sales Report (Category)"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_purchase = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_purchase = false;
                                  }
                                  Get.offNamed(purchasereportPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_purchase,
                                  name: "Purchase Report"),
                            ),  InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_purchase_supplier = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_purchase_supplier = false;
                                  }
                                  Get.offNamed(purchasereportsupplierPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_purchase_supplier,
                                  name: "Purchase Report (User)"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.report) {
                                    widget.nn.setnavbool();
                                    widget.nn.report = true;
                                    widget.nn.report_purchase_category = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.report = false;
                                    widget.nn.report_purchase_category = false;
                                  }
                                  Get.offNamed(purchasereportcategoryPageRoute);
                                });
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.report_purchase_category,
                                  name: "Purchase Report (Category)"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ),
                  AuthService.to.isAdmin()?InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.human_resource) {
                          widget.nn.setnavbool();
                          widget.nn.human_resource = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.human_resource,
                        name: "Human Resource",
                        inames:
                            "assets/icons/side_bar/human_resource_selected.png",
                        iname: "assets/icons/side_bar/human_resource.png"),
                  ):SizedBox(),
                  AuthService.to.isAdmin()?widget.nn.human_resource
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.human_resource_employee) {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource = true;
                                    widget.nn.human_resource_employee = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource_employee = false;
                                  }
                                });
                              },
                              child: SideMenuItemss(
                                  small: false,
                                  state: widget.nn.human_resource_employee,
                                  name: "Employee"),
                            ),
                            widget.nn.human_resource_employee
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_employee =
                                                  true;
                                              widget.nn
                                                      .hr_employee_add_designation =
                                                  true;
                                              Get.offNamed(
                                                      addhrdesignationPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_employee_add_designation,
                                              name: "Add Designation"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_employee =
                                                  true;
                                              widget.nn
                                                      .hr_employee_designation_list =
                                                  true;
                                              Get.offNamed(
                                                      designationlistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_employee_designation_list,
                                              name: "Designation List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_employee =
                                                  true;
                                              widget.nn
                                                      .hr_employee_add_employee =
                                                  true;
                                              Get.offNamed(
                                                      addhremployeePageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.hr_employee_add_employee,
                                              name: "Add Employee"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_employee =
                                                  true;
                                              widget.nn
                                                      .hr_employee_employee_list =
                                                  true;
                                              Get.offNamed(
                                                      employeelistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.hr_employee_employee_list,
                                              name: "Employee List"),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    width: 1,
                                  ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.human_resource_attendance) {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource = true;
                                    widget.nn.human_resource_attendance = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource_attendance = false;
                                  }
                                });
                              },
                              child: SideMenuItemss(
                                  small: false,
                                  state: widget.nn.human_resource_attendance,
                                  name: "Attendance"),
                            ),
                            widget.nn.human_resource_attendance
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_attendance =
                                                  true;
                                              widget.nn
                                                      .hr_attendance_add_attendace =
                                                  true;
                                              Get.offNamed(
                                                      addhraddattendacePageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_attendance_add_attendace,
                                              name: "Add Attendance"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_attendance =
                                                  true;
                                              widget.nn
                                                      .hr_attendance_attendance_list =
                                                  true;
                                              Get.offNamed(
                                                      attendacelistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_attendance_attendance_list,
                                              name: "Attendance List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn
                                                      .human_resource_attendance =
                                                  true;
                                              widget.nn
                                                      .hr_attendance_datewise_attendance =
                                                  true;

                                              Get.offNamed(
                                                      attendacelistdatewisePageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_attendance_datewise_attendance,
                                              name:
                                                  "Date Wise Attendance List"),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    width: 1,
                                  ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.human_resource_payroll) {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource = true;
                                    widget.nn.human_resource_payroll = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource_payroll = false;
                                  }
                                });
                              },
                              child: SideMenuItemss(
                                  small: false,
                                  state: widget.nn.human_resource_payroll,
                                  name: "Payroll"),
                            ),
                            widget.nn.human_resource_payroll
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_payroll =
                                                  true;
                                              widget.nn.hr_payroll_add_benefit =
                                                  true;

                                              Get.offNamed(
                                                      addbenefitPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.hr_payroll_add_benefit,
                                              name: "Add Benefit"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_payroll =
                                                  true;
                                              widget.nn
                                                      .hr_payroll_benefit_list =
                                                  true;

                                              Get.offNamed(
                                                      benefitlistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.hr_payroll_benefit_list,
                                              name: "Benefit List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_payroll =
                                                  true;
                                              widget.nn
                                                      .hr_payroll_add_salary_setup =
                                                  true;

                                              Get.offNamed(
                                                      addsalarysetupPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_payroll_add_salary_setup,
                                              name: "Add Salary Setup"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_payroll =
                                                  true;
                                              widget.nn
                                                      .hr_payroll_salary_setup_list =
                                                  true;

                                              Get.offNamed(
                                                      salarysetuplistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_payroll_salary_setup_list,
                                              name: "Salary Setup List"),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    width: 1,
                                  ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.human_resource_expense) {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource = true;
                                    widget.nn.human_resource_expense = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource_expense = false;
                                  }
                                });
                              },
                              child: SideMenuItemss(
                                  small: false,
                                  state: widget.nn.human_resource_expense,
                                  name: "Expense"),
                            ),
                            widget.nn.human_resource_expense
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_expense =
                                                  true;
                                              widget.nn
                                                      .hr_expense_add_expense_item =
                                                  true;

                                              Get.offNamed(
                                                      addexpenseitemPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_expense_add_expense_item,
                                              name: "Add Expense Item"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_expense =
                                                  true;
                                              widget.nn
                                                      .hr_expense_expense_item_list =
                                                  true;

                                              Get.offNamed(
                                                      expenseitemlistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_expense_expense_item_list,
                                              name: "Expense Item List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_expense =
                                                  true;
                                              widget.nn.hr_expense_add_expense =
                                                  true;

                                              Get.offNamed(
                                                      addexpensePageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.hr_expense_add_expense,
                                              name: "Add Expense"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_expense =
                                                  true;
                                              widget.nn
                                                      .hr_expense_expense_list =
                                                  true;

                                              Get.offNamed(
                                                      expenselistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.hr_expense_expense_list,
                                              name: "Expense List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_expense =
                                                  true;
                                              widget.nn
                                                      .hr_expense_expense_satement =
                                                  true;

                                              Get.offNamed(
                                                      expensestatementPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .hr_expense_expense_satement,
                                              name: "Expense Statement"),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    width: 1,
                                  ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.human_resource_lending) {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource = true;
                                    widget.nn.human_resource_lending = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.human_resource_lending = false;
                                  }
                                });
                              },
                              child: SideMenuItemss(
                                  small: false,
                                  state: widget.nn.human_resource_lending,
                                  name: "Lending"),
                            ),
                            widget.nn.human_resource_lending
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_lending =
                                                  true;
                                              widget.nn
                                                      .human_resource_add_lendingperson =
                                                  true;

                                              Get.offNamed(
                                                      addlendingpersonPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .human_resource_add_lendingperson,
                                              name: "Add Lending Person"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_lending =
                                                  true;
                                              widget.nn
                                                      .human_resource_lendingpersonlist =
                                                  true;

                                              Get.offNamed(
                                                      lendingpersonlistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .human_resource_lendingpersonlist,
                                              name: "Lending Person List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_lending =
                                                  true;
                                              widget.nn
                                                      .human_resource_add_lending =
                                                  true;

                                              Get.offNamed(
                                                      addlendingPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.human_resource_add_lending,
                                              name: "Add Lending"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_lending =
                                                  true;
                                              widget.nn
                                                      .human_resource_lendinglist =
                                                  true;

                                              Get.offNamed(
                                                      lendinglistPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget
                                                  .nn.human_resource_lendinglist,
                                              name: "Lending List"),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              widget.nn.setnavbool();
                                              widget.nn.human_resource = true;
                                              widget.nn.human_resource_lending =
                                                  true;
                                              widget.nn
                                                      .human_resource_personledger =
                                                  true;

                                              Get.offNamed(
                                                      personledgerPageRoute);
                                            });
                                          },
                                          child: SideMenuSubItem(
                                              state: widget.nn
                                                  .human_resource_personledger,
                                              name: "Person Ledger"),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(
                                    width: 1,
                                  ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ):SizedBox(),
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       if (!widget.nn.search) {
                  //         widget.nn.setnavbool();
                  //         widget.nn.search = true;
                  //       } else {
                  //         widget.nn.setnavbool();
                  //         widget.nn.search = false;
                  //       }
                  //     });
                  //   },
                  //   child: SideMenuItem(
                  //       small: false,
                  //       state: widget.nn.search,
                  //       name: "Search",
                  //       inames: "assets/icons/side_bar/search_selected.png",
                  //       iname: "assets/icons/side_bar/search.png"),
                  // ),
                  // widget.nn.search
                  //     ? Column(
                  //         children: [
                  //           InkWell(
                  //             child: SideMenuSubItem(
                  //                 state: widget.nn.search_product,
                  //                 name: "Product"),
                  //           ),
                  //           InkWell(
                  //             child: SideMenuSubItem(
                  //                 state: widget.nn.search_invoice,
                  //                 name: "Invoice"),
                  //           ),
                  //           InkWell(
                  //             child: SideMenuSubItem(
                  //                 state: widget.nn.search_purchase,
                  //                 name: "Purchase"),
                  //           ),
                  //         ],
                  //       )
                  //     : const SizedBox(
                  //         width: 1,
                  //       ),
                  AuthService.to.isAdmin()?InkWell(
                    onTap: () {
                      setState(() {
                        if (!widget.nn.management) {
                          widget.nn.setnavbool();
                          widget.nn.management = true;
                        } else {
                          widget.nn.setnavbool();
                          widget.nn.management = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: false,
                        state: widget.nn.management,
                        name: "Settings",
                        inames: "assets/icons/side_bar/setting_selected.png",
                        iname: "assets/icons/side_bar/setting.png"),
                  ):SizedBox(),
                  AuthService.to.isAdmin()?widget.nn.management
                      ? Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.management_add_user) {
                                    widget.nn.setnavbool();
                                    widget.nn.management = true;
                                    widget.nn.management_add_user = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.management = false;
                                    widget.nn.management_add_user = false;
                                  }
                                });
                                Get.offNamed(addnewuserPageRoute);
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.management_add_user,
                                  name: "Add User"),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (!widget.nn.management_user_list) {
                                    widget.nn.setnavbool();
                                    widget.nn.management = true;
                                    widget.nn.management_user_list = true;
                                  } else {
                                    widget.nn.setnavbool();
                                    widget.nn.management = false;
                                    widget.nn.management_user_list = false;
                                  }
                                });
                                Get.offNamed(userlistPageRoute);
                              },
                              child: SideMenuSubItem(
                                  state: widget.nn.management_user_list,
                                  name: "User List"),
                            ),
                          ],
                        )
                      : const SizedBox(
                          width: 1,
                        ):SizedBox(),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: width / 70, top: height / 30),
            child: Row(
              children: [
                const Expanded(
                    child: SizedBox(
                  height: 1,
                )),
                Flexible(
                  child: CustomText(
                    text: "Version Name: Pharmaceutical",
                    color: lightGrey,
                    size: 10,
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: width / 70),
            child: Row(
              children: [
                const Expanded(
                    child: SizedBox(
                  height: 1,
                )),
                Flexible(
                  child: CustomText(
                    text: "Version Code: 1.0.0",
                    color: lightGrey,
                    size: 10,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
