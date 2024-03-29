import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';

ThemeData lightTheme = ThemeData.light().copyWith(
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(
      textColor: Colors.black,
      textbuttonBgColor: Color.fromARGB(103, 255, 255, 255),
      iconColor: Colors.black,
      iconActiveColor: Colors.blue,
      cardBgColor: Color.fromARGB(255, 255, 255, 255),
      cardShadowColor: Color.fromARGB(255, 0, 0, 0),
    ),
  ],
);
