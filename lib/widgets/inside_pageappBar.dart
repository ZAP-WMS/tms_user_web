import 'package:flutter/material.dart';
import '../utils/text_styles.dart'; // Replace with your actual file

// Common AppBar Widget
AppBar commonAppBar(
    {required String title, required VoidCallback onBackPressed}) {
  return AppBar(
    // leading: IconButton(
    //   onPressed: onBackPressed, // Custom onPress for the back button
    //   icon: const Icon(
    //     Icons.arrow_back,
    //     color: AppColors.primaryColor, // Your custom color
    //   ),
    // ),
    automaticallyImplyLeading: true,
    centerTitle: true,
    title: Text(
      title,
      style: AppTextStyles.bodyText1appColor, // Your custom text style
    ),
  );
}
