import 'package:flutter/material.dart';

/// A widget that creates a sized box with a specific width and height
/// as a fraction of the screen dimensions.
Widget sizedWH(BuildContext context, double widthFactor, double heightFactor) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;

  return SizedBox(
    width: width * widthFactor,
    height: height * heightFactor,
  );
}

/// A widget that creates a sized box with a specific width
/// as a fraction of the screen width.
Widget sizedW(BuildContext context, double widthFactor) {
  final width = MediaQuery.of(context).size.width;

  return SizedBox(
    width: width * widthFactor,
  );
}

/// A widget that creates a sized box with a specific height
/// as a fraction of the screen height.
Widget sizedH(BuildContext context, double heightFactor) {
  final height = MediaQuery.of(context).size.height;

  return SizedBox(
    height: height * heightFactor,
  );
}
