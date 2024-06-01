import 'package:flutter/material.dart';

import '../constants/style.dart';
import 'custom_text.dart';


class SideMenuItemss extends StatefulWidget {
  final bool state, small;
  final String name;

  const SideMenuItemss({ required this.small,required this.state,required this.name}) ;

  @override
  State<SideMenuItemss> createState() => _SideMenuItemssState();
}

class _SideMenuItemssState extends State<SideMenuItemss> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
      return  Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: widget.state
            ? BoxDecoration(color: darkselect)
            : BoxDecoration(),
        child: !widget.small?Row(
          children: [
            SizedBox(
              width: 5,
              height: 25,
              child: DecoratedBox(
                decoration: widget.state
                    ? BoxDecoration(
                  color: Color(0xFF56CCF2),
                )
                    : BoxDecoration(),
              ),
            ),
            SizedBox(
              width: _width / 60,
            ),
            SizedBox(
              width: 20,
            ),
            SizedBox(
              width: _width / 100,
            ),
            CustomText(
              text: widget.name,
              color: widget.state ? maincolor : lightGrey,
              size: 14,
            ),
            Expanded(child: SizedBox(height: 1,)),
            Image.asset(
              widget.state? "assets/icons/down_selected.png": "assets/icons/down.png",
              width: 12,
            ),
          SizedBox(width: 15,),
          ],
        ): Row(
          children: [
            SizedBox(
              width: 5,
              height: 25,
            ),
            SizedBox(
              width: _width / 60,
            ),

            SizedBox(
              width: _width / 20,
            ),
            SizedBox(
              width: _width / 80,
            ),
          ],
        ),
      );
  }
}