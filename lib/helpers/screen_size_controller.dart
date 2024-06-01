import 'package:get/get.dart';

class ScreenSizeController extends GetxController {
  RxBool screenSize = true.obs; // Make sure to use .obs for observable.

  void onChange(bool value) {
    screenSize.value = value;
    update();
  }
}