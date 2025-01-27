// text_styles.dart

import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Body Text Style
  static TextStyle bodyText1 = const TextStyle(
    fontSize: 18.0,
    color: AppColors.textWhite,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyText1whiteColor = TextStyle(
    fontSize: 16.0,
    color: AppColors.backgroundColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodyText1appColor = const TextStyle(
    fontSize: 20.0,
    color: AppColors.primaryColor,
    fontWeight: FontWeight.bold,
  );

  static TextStyle bodyText2appColor = const TextStyle(
      fontSize: 16.0,
      color: AppColors.primaryColor,
      fontWeight: FontWeight.bold);

  static TextStyle boldBlackColor = const TextStyle(
    fontSize: 18.0,
    color: AppColors.appBlackColor,
    fontWeight: FontWeight.bold,
  );
}
