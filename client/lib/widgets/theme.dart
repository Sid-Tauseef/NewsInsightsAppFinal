import 'package:flutter/material.dart';

class AppTheme {
  // Define primaryColor
  static const Color primaryColor =
      Color(0xFF6200EA); // You can adjust this color

  // Light theme data
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.purple,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor, // Use primaryColor here
      secondary: Colors.purpleAccent,
      surface: Colors.white,
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      color: primaryColor, // Use primaryColor here
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black54),
      headlineLarge: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor, // Use primaryColor here
      textTheme: ButtonTextTheme.primary,
    ),
    scaffoldBackgroundColor: Colors.white,
  );

  // Dark theme data
  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.purple,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor, // Use primaryColor here
      secondary: Colors.purpleAccent,
      surface: Colors.grey[850] ?? Colors.grey[800]!,
      error: Colors.red,
    ),
    appBarTheme: const AppBarTheme(
      color: primaryColor, // Use primaryColor here
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white54),
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      labelLarge: TextStyle(
        color: Colors.white,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: primaryColor, // Use primaryColor here
      textTheme: ButtonTextTheme.primary,
    ),
    scaffoldBackgroundColor: Colors.grey[850] ?? Colors.grey[800]!,
  );
}
