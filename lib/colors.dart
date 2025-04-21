import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFE0E4EB),
  100: Color(0xFFB3BDCD),
  200: Color(0xFF8091AC),
  300: Color(0xFF4D648A),
  400: Color(0xFF264371),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFF001E50),
  700: Color(0xFF001947),
  800: Color(0xFF00143D),
  900: Color(0xFF000C2D),
});
const int _primaryPrimaryValue = 0xFF3463EB;

const MaterialColor primaryAccent =
    MaterialColor(_primaryAccentValue, <int, Color>{
  100: Color(0xFF667AFF),
  200: Color(_primaryAccentValue),
  400: Color(0xFF0022FF),
  700: Color(0xFF001FE6),
});
const int _primaryAccentValue = 0xFF334EFF;
