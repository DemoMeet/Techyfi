import 'package:flutter/cupertino.dart';

class Supplier {
  String name, address, email, phone1, phone2, city, id,zip;
  int sl;
  double balance;
  String user;

  Supplier(
      {required this.name,
        required this.address,
        required this.email,
        required this.phone1,
        required this.user,
        required this.phone2,
        required this.city,
        required this.balance,
        required this.id,
        required this.zip,
        required this.sl});

  Map toJson() => {
    'Name': name,
    'Address': address,
    'Email': email,
    'Phone': phone1,
    'Phone2': phone2,
    'Balance': balance,
    'User': user,
    'UID': id,
    'Zip Code': zip,
    'City': city,
    'sl': sl
  };

  factory Supplier.fromJson(dynamic json) {
    return Supplier(
        name: json['Name'] as String,
        address: json['Address'] as String,
        email: json['Email'] as String,user: json['User'],
        id: json['UID'] as String,
        phone1: json['Phone'] as String,
        zip: json['Zip Code'] as String,
        phone2: json['Phone2'] as String,
        balance: json['Balance'] as double,
        city: json['City'] as String,
        sl: json['sl'] as int);
  }


  List<dynamic> toCsvRow() {
    return [
      sl,
      id,
      name,
      address,
      email,
      phone1,
      phone2,
      city,
      zip,
      balance,
    ];
  }
  static List<dynamic> parameterNames() {
    return [
      'SL',
      'UID',
      'Name',
      'Address',
      'Email',
      'Phone1',
      'Phone2',
      'City',
      'Zip',
      'Balance',
    ];
  }
}
