
class Trashbin {
  String supplierid, suppliername, returnid;
  double receivedamount, totalamount, totaldeduction;
  int sl;
  List<dynamic> products;
  DateTime returndate;
  bool trash;
  Trashbin(
      {required this.products,
      required this.trash,
      required this.supplierid,
        required this.suppliername,
        required this.returnid,
        required this.returndate,
      required this.receivedamount,
        required this.totalamount,
        required this.totaldeduction,
      required this.sl});
}
