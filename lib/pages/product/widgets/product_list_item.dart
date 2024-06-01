import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../model/products.dart';

class ProductListItem extends StatefulWidget {

  Product mst;
  int index;
  final void Function(String) changeVal;
  final void Function() fetchDocuments;
  final void Function(Product) onEditProduct;
  bool click;
  ProductListItem({
    required this.mst,
    required this.click,
    required this.changeVal,
    required this.onEditProduct,
    required this.index,
    required this.fetchDocuments,
  });

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {

  showDeleteDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Delete", style: TextStyle(color: Colors.red)),
      onPressed: () {
        FirebaseFirestore.instance
            .collection("Customer")
            .doc(widget.mst.id)
            .delete()
            .then((value) {
          Navigator.pop(context);
          setState(() {
            widget.fetchDocuments();
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("${widget.mst.name} is Deleted From The List"),
          ));
        });
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: AlertDialog(
            title: Text(
              "Confirmation To Delete!!",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text("Permanently Delete the item ${widget.mst.name} from the list? "),
            ),
            actions: [
              cancelButton,
              continueButton,
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    (widget.mst.sl + 1).toString(),
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 2,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.mst.name,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 5,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.mst.brand,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.mst.category,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "\৳"+widget.mst.perprice.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "\৳"+widget.mst.bodyrate.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 3,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    "\৳"+widget.mst.menuperprice.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
                flex: 4,
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(left: 7),
                  child: Text(
                    widget.mst.strength + widget.mst.unit,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: tabletitle, fontFamily: 'inter'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                    margin: EdgeInsets.only(left: 7),
                    child: widget.mst.img
                        ? Image.network(
                      widget.mst.imgurl,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      "assets/images/def_product.jpg", width: 60,
                      height: 60,
                    )),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 5),
                  child: widget.click
                      ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(right: _width/35, left: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        borderRadius:
                        BorderRadius.all(Radius.circular(100)),
                        color: Colors.grey.shade200,
                      ),
                      child: _width>830?Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              onTap: (){
                                widget.onEditProduct(widget.mst);
                              },
                              child: Icon(
                                Icons.edit_outlined,
                                size: _width/70,
                              )),
                          InkWell(
                              onTap: (){
                                showDeleteDialog(context);
                              },
                              child: Icon(
                                Icons.delete_outline,
                                size: _width/70,
                              )),
                        ],
                      ):Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                              child: Icon(
                                Icons.edit_outlined,
                                size: _width/55,
                              )),
                          InkWell(
                              onTap: (){
                                showDeleteDialog(context);
                              },
                              child: Icon(
                                Icons.delete_outline,
                                size: _width/55,
                              )),
                        ],
                      ),
                    ),
                  )
                      : Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(
                          right: _width / 25),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        borderRadius:
                        BorderRadius.all(Radius.circular(100)),
                        color: Colors.grey.shade200,
                      ),
                      child: InkWell(
                          onTap: () {
                            widget.changeVal(widget.index.toString());
                          },
                          child: Icon(
                            Icons.more_vert,
                            size: 18,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: .2,
            width: double.infinity,
            color: tabletitle,
          )
        ],
      ),
    );
  }
}
