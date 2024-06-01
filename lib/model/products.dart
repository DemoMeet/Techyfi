import 'package:flutter/foundation.dart';

class Product {
    late String  code, details;
    String user;
    String name,
        strength,
        unit,brand,
        category,
        id,
        imgurl;
    double perprice, menuperprice, bodyrate;
    int sl;

    Product(
        {required this.name,
            required this.brand,
            required this.code,
            required this.details,
            required this.strength,
            required this.unit,
            required this.user,
            required this.category,
            required this.id,required this.bodyrate,
            required this.imgurl,
            required this.perprice,
            required this.menuperprice,
            required this.sl,
            required this.img});

    bool img;


    Map toJson() => {
      'Name': name,
      'Brand': brand,
      'Code': code,
      'Details': details,
      'Strength': strength,
      'Unit': unit,
      'User': user,
      'Category': category,'Body Rate':bodyrate,
      'ID': id,
      'ImageURL': imgurl,
      'Price': perprice,
      'Menu Price': menuperprice,
      'Image': img,
      'sl': sl
    };

    factory Product.fromJson(dynamic json) {
      return Product(
          name: json['Name'],
           brand: json['Brand'],
           code: json['Code'],
           details: json['Details'],
           strength: json['Strength'],bodyrate: json['Body Rate'],
           unit: json['Unit'],
           user: json['User'],
           category: json['Category'],
           id: json['ID'],
           imgurl: json['ImageURL'],
           perprice: json['Price'],
           menuperprice: json['Menu Price'],
           img: json['Image'],
          sl: json['sl']);
    }


    List<dynamic> toCsvRow() {
        return [
            sl,
            code,
            name,
            category,
            brand,
            perprice,
            menuperprice,
            strength + unit,
        ];
    }
    static List<dynamic> parameterNames() {
        return [
            'SL',
            'Code',
            'Product Name',
            'Category',
            'Brand',
            'Price',
            'Purchase Price',
            'Strength',
        ];
    }
}
