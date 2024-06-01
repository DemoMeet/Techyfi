import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AppBarController extends GetxController {
  RxString appBarTitle = "".obs;

  RxInt stoc = RxInt(0), expi =  RxInt(0), lending =  RxInt(0);
  Future<void> fetchData() async {
    await FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((medi) async {
        double totalmediqty = 0;
        await FirebaseFirestore.instance
            .collection('Stock')
            .where("Product ID", isEqualTo: medi.id)
            .get()
            .then((qury) {
          qury.docs.forEach((element) {
            totalmediqty = totalmediqty + element["Quantity"];
          });
          if (!(totalmediqty > 0)) {
            stoc++;
          }
        });
      });
    });
    await FirebaseFirestore.instance
        .collection('Stock')
        .where("Expire Date", isLessThanOrEqualTo: DateTime.now())
        .get()
        .then((qury) {
      qury.docs.forEach((element) {
        expi++;
      });
    });

    await FirebaseFirestore.instance
        .collection('Lending')
        .where("Status", isEqualTo: "Current")
        .where("Return Date", isLessThanOrEqualTo: DateTime.now())
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
        lending++;
      });
    });
  }
}