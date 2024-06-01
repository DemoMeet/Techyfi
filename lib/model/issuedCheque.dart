class IssuedCheque {
  String name,
      userid,
      uid,
      status,
      voucherid,
      chequeno,
      remarks,
      accountname,user,
      accountid;
  DateTime date, selecteddate;
  bool payment;
  double amount, due;
  Map<String, dynamic> account;
  int sl;

  IssuedCheque(
      {required this.name,
      required this.userid,
      required this.uid,
      required this.status,
      required this.voucherid,
        required this.due,
      required this.chequeno,
        required this.user,
      required this.remarks,
        required this.account,
      required this.accountname,
      required this.accountid,
        required this.sl,
      required this.date,
      required this.selecteddate,
      required this.payment,
      required this.amount});

  List<dynamic> toCsvRow() {
    return [
      sl+1,
      name,
      accountname,
      chequeno,
      date,
      payment,
      amount,
      status,
    ];
  }
  static List<dynamic> parameterNames() {
    return [
      '#',
      'Name',
      'Account Name',
      'Cheque No',
      'Date',
      'Type',
      'Amount',
      'Status'
    ];
  }
}
