import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Colors.blue),
    ),
  ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Color.fromARGB(40, 0, 0, 0),
  ),
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.grey.shade200,
    primary: Colors.grey.shade50,
    secondary: Colors.white,
    tertiary: const Color(0xff1E232C),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: Colors.blue[200],
    dayOverlayColor: const MaterialStatePropertyAll(Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  textButtonTheme: const TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(Colors.white),
    ),
  ),
  brightness: Brightness.dark,
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionColor: Color.fromARGB(116, 255, 255, 255),
  ),
  colorScheme: const ColorScheme.dark(
    background: Color(0xff0F172A),
    primary: Color(0xff0D2136),
    secondary: Color(0xff162C46),
    tertiary: Color(0xff162C46),
  ),
  datePickerTheme: DatePickerThemeData(
    backgroundColor: Colors.grey.shade700,
    headerBackgroundColor: Colors.grey.shade800,
    dayOverlayColor:
        const MaterialStatePropertyAll(Color.fromARGB(255, 200, 194, 194)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  ),
);
