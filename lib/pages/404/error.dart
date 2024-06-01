import 'package:flutter/material.dart';
import 'package:groceyfi02/widgets/custom_text.dart';

class PageNotFound extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/images/error.jpg",
            width: 350,
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Page Not Found",
                font: 'opensans',
                size: 24,
                weight: FontWeight.bold,
              ),
            ],
          )
        ],
      ),
    );
  }
}
