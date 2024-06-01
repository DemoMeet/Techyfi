class User {
  String name, phone, id, pass, details, asset;
  String uid;
  bool sts;
  DateTime lastlogin, lastlogout;
  String user;

  User({
    required this.name,
    required this.phone,
    required this.id,
    required this.pass,
    required this.details,
    required this.asset,
    required this.user,
    required this.lastlogin,
    required this.lastlogout,
    required this.uid,
    required this.sts,
  });

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Phone': phone,
    'ID': id,
    'Password': pass,
    'Details': details,
    'User':user,
    'Assets': asset,
    'Last Login': lastlogin.toIso8601String(),
    'Last Logout': lastlogout.toIso8601String(),
    'UID': uid,
    'Admin': sts,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['Name'],
      phone: json['Phone'],
      id: json['ID'],
      pass: json['Password'],
      details: json['Details'],
      asset: json['Assets'],user: json['User'],
      lastlogin: DateTime.parse(json['Last Login']),
      lastlogout: DateTime.parse(json['Last Logout']),
      uid: json['UID'],
      sts: json['Admin'],
    );
  }
}