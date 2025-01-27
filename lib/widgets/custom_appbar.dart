import 'package:flutter/material.dart';
import 'package:tms_useweb_app/service/auth_services.dart';
import '../utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  bool isCenter = false;

  CustomAppBar({
    required this.title,
    required this.isCenter,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    AuthService _authservice = AuthService();
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.backgroundColor,
          )),
      backgroundColor: AppColors.primaryColor,
      centerTitle: isCenter,
      leading: IconButton(
        onPressed: () {},
        icon: const Icon(
          Icons.home,
          color: AppColors.backgroundColor,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications,
            color: AppColors.backgroundColor,
          ),
        ),
        IconButton(
          onPressed: () {
            _authservice.logout(context);
          },
          icon: const Icon(
            Icons.logout,
            color: AppColors.backgroundColor,
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
