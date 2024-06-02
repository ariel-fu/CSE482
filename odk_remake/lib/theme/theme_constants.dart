// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

// Define your primary color
const Color COLOR_PRIMARY_LIGHT = Colors.blue;
const Color COLOR_PRIMARY_DARK = Color.fromARGB(255, 71, 101, 155);

// Define the light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: COLOR_PRIMARY_LIGHT,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color?>(COLOR_PRIMARY_LIGHT),
      textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(color: Colors.white))
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: COLOR_PRIMARY_LIGHT,
    extendedTextStyle: TextStyle(color: Colors.white),
    foregroundColor: Colors.white,
  ),
);

// Define the dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: COLOR_PRIMARY_DARK,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all<Color?>(COLOR_PRIMARY_DARK),
      textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(color: Colors.white))
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: COLOR_PRIMARY_DARK,
    extendedTextStyle: TextStyle(color: Colors.white),
    foregroundColor: Colors.white,
  ),
  
);
