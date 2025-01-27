import 'package:flutter/widgets.dart';

class AppDimensions {
  // Method to get the screen width as a percentage of the screen size
  static double getWidth(BuildContext context, {double percentage = 0.0}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * percentage;
  }

  // You can also define fixed dimensions if you want
  static const double smallWidth = 100.0;
  static const double mediumWidth = 200.0;
  static const double largeWidth = 300.0;

  // Heights can also be dynamic based on the screen size
  static double getHeight(BuildContext context, {double percentage = 0.0}) {
    double screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * percentage;
  }

  // For padding and margin, you can also create dynamic values based on screen width/height
  static EdgeInsetsGeometry getPadding(BuildContext context, {double percentage = 0.05}) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * percentage;  // Padding as a percentage of screen width
    return EdgeInsets.all(padding);
  }
}
