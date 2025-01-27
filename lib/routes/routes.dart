// routes.dart
import 'package:get/get.dart';
import 'package:tms_useweb_app/view/LoginPage/login_page.dart';

class AppRoutes {
  static final routes = [
    GetPage(name: '/', page: () => const LoginPage()),
    GetPage(name: '/home', page: () => const LoginPage()),
  ];
}
