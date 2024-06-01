import 'package:flutter/material.dart';

import '../../../widgets/custom_text.dart';

class OverViewWidget extends StatelessWidget {
  String icon, text, number;
  Color color;

  OverViewWidget({required this.icon,required  this.color, required this.text,required this.number});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: MediaQuery.of(context).size.width / 5.5,
        height: 160,
        padding: const EdgeInsets.all(35),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 4,
              offset: const Offset(2,5)
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  icon,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                const Expanded(child: SizedBox(width: 3,)),
                Row(
                  children: [
                    CustomText(
                      text: "Show Details",
                      color: Colors.lightBlue,
                      size: 10,
                    ),
                    const SizedBox(width: 3,),
                    const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.lightBlue,
                      size: 10,
                    )
                  ],
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomText(
                  text: text,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(height: 5,),
                CustomText(
                  text: number,
                  color: Colors.white,
                  weight: FontWeight.bold,
                  size: 46,
                ),
              ],
            )
          ],
        ),
      );
  }
}
