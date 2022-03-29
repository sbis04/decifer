import 'package:flutter/material.dart';

class CustomColors {
  static const Color yellow = Color(0xFFFFC15E);
  static const Color brown = Color(0xFF352208);
  static const Color black = Color(0xFF2F2F2F);
  static const Color green = Color(0xFFCBEF43);
}

const MaterialColor primaryBlack = MaterialColor(
  _blackPrimaryValue,
  <int, Color>{
    50: Color(0xFF000000),
    100: Color(0xFF000000),
    200: Color(0xFF000000),
    300: Color(0xFF000000),
    400: Color(0xFF000000),
    500: Color(_blackPrimaryValue),
    600: Color(0xFF000000),
    700: Color(0xFF000000),
    800: Color(0xFF000000),
    900: Color(0xFF000000),
  },
);
const int _blackPrimaryValue = 0xFF000000;
