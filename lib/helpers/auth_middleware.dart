import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../routing/routes.dart';
import 'auth_service.dart';


class AuthMiddleware extends GetMiddleware {
  @override
  int? priority = 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isAuthenticated.value) {
      return const RouteSettings(name: authenticationPageRoute);
    }
    return null;
  }
}
