import 'package:flutter/material.dart';

import '../constants/style.dart';
import 'custom_text.dart';

class SideMenuItem extends StatefulWidget {
  final bool state, small;
  final String name, iname, inames;

  const SideMenuItem(
      {
      required this.small,
      required this.state,
      required this.name,
      required this.iname,
      required this.inames});

  @override
  State<SideMenuItem> createState() => _SideMenuItemState();
}

class _SideMenuItemState extends State<SideMenuItem> {
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5),
      decoration:
          widget.state ? BoxDecoration(color: darkselect) : BoxDecoration(),
      child: !widget.small
          ? Row(
              children: [
                SizedBox(
                  width: _width/273,
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
                Image.asset(
                  widget.state ? widget.inames : widget.iname,
                  width: 20,
                ),
                SizedBox(
                  width: _width / 100,
                ),
                Expanded(
                  child: CustomText(
                    text: widget.name,
                    color: widget.state ? maincolor : lightGrey,
                    size: 14,
                  ),
                ),
                Image.asset(
                  widget.state
                      ? "assets/icons/down_selected.png"
                      : "assets/icons/down.png",
                  width: 12,
                ),
                SizedBox(
                  width: _width/100,
                ),
              ],
            )
          : Row(
              children: [
                SizedBox(
                  width: 5,
                  height: 25,
                ),
                SizedBox(
                  width: _width / 60,
                ),
                Image.asset(
                  widget.state ? widget.inames : widget.iname,
                  width: 20,
                ),
                SizedBox(
                  width: _width / 80,
                ),
              ],
            ),
    );
  }
}
