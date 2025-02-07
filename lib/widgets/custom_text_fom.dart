import 'package:flutter/material.dart';
import 'package:tms_useweb_app/utils/text_styles.dart';

import '../utils/app_dimensions.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final IconData? icon;
  final String? Function(String?)? validator;
  double? width;
  TextInputAction? textInputAction;

  CustomTextFormField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.obscureText = false,
    this.icon,
    this.validator,
    this.width,
    this.textInputAction
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.getPadding(context, percentage: 0.005),
      child: Center(
        child: SizedBox(
          width:
              // platformService.isWeb.value ? width * 0.6 :
              width,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: AppTextStyles.boldBlackColor,
              hintText: hintText,
              prefixIcon: icon != null ? Icon(icon) : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}
