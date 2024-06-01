import 'package:flutter/material.dart';

import '../constants/style.dart';
import 'custom_text.dart';


class SideMenuSubItem extends StatefulWidget {
  final bool state;
  final String name;

  const SideMenuSubItem({required this.state,required this.name });

  @override
  State<SideMenuSubItem> createState() => _SideMenuSubItemState();
}

class _SideMenuSubItemState extends State<SideMenuSubItem> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
      return  Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: widget.state
            ? BoxDecoration(color: darkselect)
            : BoxDecoration(),
        child: Row(
          children: [
            SizedBox(
              width: _width / 60,
            ),
            SizedBox(
              width: 20,
            ),
            SizedBox(
              width: _width / 100,
            ),
            Expanded(
              child: CustomText(
                text: widget.name,
                color: widget.state
                    ? maincolor
                    : lightGrey,
                size: 14,
              ),
            ),
          ],
        ),
      );
  }
}