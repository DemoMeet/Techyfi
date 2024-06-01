
class Closing {
  String remarks, user;
  DateTime date, lastclosingdate;
  double lastclosingamount, received, payment, balance;
  int sl, id;
  Closing(
      {required this.lastclosingamount,
      required this.lastclosingdate,
      required this.remarks,
      required this.received,
      required this.payment,
        required this.balance,
        required this.user,
        required this.id,
      required this.date,
      required this.sl});
}
