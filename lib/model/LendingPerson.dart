class LendingPerson {
  String name, phone, phone2, address, uid, nid, reference;
  String user;

  int sl;
  LendingPerson(
      {required this.name,
      required this.phone,
      required this.phone2,
      required this.address,
      required this.uid,
      required this.nid,
        required this.user,
        required this.sl,

      required this.reference});

  Map toJson() => {
    'Name': name,
    'Phone': phone,
    'Phone 2': phone2,
    'Address': address,
    'User':user,
    'National ID': nid,
    'UID':uid,
    'Reference': reference,
    'sl': sl
  };
}
