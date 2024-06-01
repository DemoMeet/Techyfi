import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
   String text;
   double? size;
   Color? color;
   FontWeight? weight;
   String? font;
   CustomText(
      {required this.text, this.size, this.color, this.weight, this.font});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: size ?? 16,
          color: color ?? Colors.black,
          fontFamily: font ?? 'roboto',
          fontWeight: weight ?? FontWeight.normal),
    );
  }
}
