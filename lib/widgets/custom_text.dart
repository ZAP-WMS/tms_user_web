import 'package:flutter/material.dart';
import 'package:tms_useweb_app/utils/colors.dart';

class CustomText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextStyle textStyle;
  final int maxLines;

  CustomText({
    required this.text,
    this.color = AppColors.textWhite, // Default color
    this.fontSize = 14.0, // Default font size
    this.fontWeight = FontWeight.normal, // Default font weight
    this.textAlign = TextAlign.start, // Default text alignment
    this.textStyle = const TextStyle(),
    this.maxLines = 1, // Default max lines
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis, // Add this to handle overflow
    );
  }
}
