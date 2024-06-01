import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groceyfi02/constants/style.dart';
import 'package:groceyfi02/routing/routes.dart';
import 'package:groceyfi02/widgets/side_menu_item.dart';
import 'package:groceyfi02/widgets/side_menu_sub_item.dart';
import 'package:get/get.dart';

import '../helpers/screen_size_controller.dart';
import '../model/nav_bools.dart';

class SideMenuSmall extends StatefulWidget {
  Navbools nn;
  SideMenuSmall(this.nn);

  @override
  State<SideMenuSmall> createState() => _SideMenuSmallState();
}

class _SideMenuSmallState extends State<SideMenuSmall> {
  final ScreenSizeController controller = Get.put(ScreenSizeController());

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Container(
      color: dark,
      height: _height,
      width: (_width / 60) + (_width / 105) + 33,
      padding: EdgeInsets.only(top: _height / 7.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: EdgeInsets.only(left: 20),
              child: SizedBox(
                height: 10,
              )),
          Container(
            height: _height / 1.4,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.dashboard) {
                          widget.nn.dashboard = true;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 3),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: widget.nn.dashboard
                          ? BoxDecoration(color: darkselect)
                          : BoxDecoration(),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 5,
                            height: 25,
                          ),
                          SizedBox(
                            width: _width / 60,
                          ),
                          Image.asset(
                            widget.nn.dashboard
                                ? "assets/icons/side_bar/dashboard_selected.png"
                                : "assets/icons/side_bar/dashboard.png",
                            width: 20,
                          ),
                          SizedBox(
                            width: _width / 80,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.customer) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = true;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.customer,
                        name: "Customer",
                        iname: "assets/icons/side_bar/customer.png",
                        inames: "assets/icons/side_bar/customer_selected.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.supplier) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = true;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.supplier,
                        name: "Supplier",
                        iname: "assets/icons/side_bar/supplier.png",
                        inames: "assets/icons/side_bar/supplier_selected.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.product) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = true;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.product,
                        name: "Product",
                        iname: "assets/icons/side_bar/product.png",
                        inames: "assets/icons/side_bar/product_selected.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.purchase) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = true;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.purchase,
                        name: "Purchase",
                        iname: "assets/icons/side_bar/purchase.png",
                        inames: "assets/icons/side_bar/purchase_selected.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.invoice) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = true;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.invoice,
                        name: "Invoice",
                        iname: "assets/icons/side_bar/invoice.png",
                        inames: "assets/icons/side_bar/invoice_selected.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.returnss) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = true;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        state: widget.nn.returnss,
                        small: true,
                        name: "Return",
                        inames: "assets/icons/side_bar/return_selected.png",
                        iname: "assets/icons/side_bar/return.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.stock) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = true;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.stock,
                        name: "Stock",
                        inames: "assets/icons/side_bar/stock_selected.png",
                        iname: "assets/icons/side_bar/stock.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.account) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = true;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.account,
                        name: "Account",
                        inames: "assets/icons/side_bar/account_selected.png",
                        iname: "assets/icons/side_bar/account.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.report) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = true;
                          widget.nn.search = false;
                          widget.nn.human_resource = false;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.report,
                        name: "Report",
                        inames: "assets/icons/side_bar/report_selected.png",
                        iname: "assets/icons/side_bar/report.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      setState(() {
                        if (!widget.nn.human_resource) {
                          widget.nn.dashboard = false;
                          widget.nn.customer = false;
                          widget.nn.supplier = false;
                          widget.nn.product = false;
                          widget.nn.purchase = false;
                          widget.nn.invoice = false;
                          widget.nn.returnss = false;
                          widget.nn.stock = false;
                          widget.nn.account = false;
                          widget.nn.report = false;
                          widget.nn.search = false;
                          widget.nn.human_resource = true;
                        }
                      });
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.human_resource,
                        name: "Human Resource",
                        inames:
                            "assets/icons/side_bar/human_resource_selected.png",
                        iname: "assets/icons/side_bar/human_resource.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      if (!widget.nn.search) {
                        widget.nn.dashboard = false;
                        widget.nn.customer = false;
                        widget.nn.supplier = false;
                        widget.nn.product = false;
                        widget.nn.purchase = false;
                        widget.nn.invoice = false;
                        widget.nn.returnss = false;
                        widget.nn.stock = false;
                        widget.nn.account = false;
                        widget.nn.report = false;
                        widget.nn.search = true;
                        widget.nn.human_resource = false;
                      }
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.search,
                        name: "Search",
                        inames: "assets/icons/side_bar/search_selected.png",
                        iname: "assets/icons/side_bar/search.png"),
                  ),
                  InkWell(
                    onTap: () {
                      controller.onChange(true);
                      if (!widget.nn.search) {
                        widget.nn.dashboard = false;
                        widget.nn.customer = false;
                        widget.nn.supplier = false;
                        widget.nn.product = false;
                        widget.nn.purchase = false;
                        widget.nn.invoice = false;
                        widget.nn.returnss = false;
                        widget.nn.stock = false;
                        widget.nn.account = false;
                        widget.nn.report = false;
                        widget.nn.search = true;
                        widget.nn.human_resource = false;
                      }
                    },
                    child: SideMenuItem(
                        small: true,
                        state: widget.nn.search,
                        name: "Settings",
                        inames: "assets/icons/side_bar/setting_selected.png",
                        iname: "assets/icons/side_bar/setting.png"),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: _width / 70, top: _height / 30),
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: 1,
                )),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: _width / 70),
            child: Row(
              children: [
                Expanded(
                    child: SizedBox(
                  height: 1,
                )),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
