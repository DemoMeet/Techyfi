import 'package:flutter/material.dart';

import '../../../constants/style.dart';
import '../../../model/Single.dart';
import '../../../model/products.dart';

class POSSupplierList extends StatefulWidget {

  double height;
  List<Single> manufact;
  final void Function(int) setManuFact;
  POSSupplierList({required this.height,required this.manufact, required this.setManuFact});


  @override
  State<POSSupplierList> createState() => _POSSupplierListState();
}

class _POSSupplierListState extends State<POSSupplierList> {
  @override
  Widget build(BuildContext context) {


    Future<List<Single>> getManu() async {
      return widget.manufact;
    }

    return Container(
      height: widget.height / 15,
      width: double.infinity,
      margin: EdgeInsets.only(left: 30),
      child: FutureBuilder(
        builder: (ctx,AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              return MediaQuery.removePadding(
                removeTop: true,
                context: ctx,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        widget.setManuFact(index);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: snapshot.data[index].selected
                              ? active
                              : Colors.white,
                          border: Border.all(
                              width: 0.5,
                              color: snapshot.data[index].selected
                                  ? active
                                  : dark),
                        ),
                        child: Text(
                          snapshot.data[index].name,
                          style: TextStyle(
                              fontFamily: 'inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: snapshot.data[index].selected
                                  ? Colors.white
                                  : dark),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        future: getManu(),
      ),
    );
  }
}
