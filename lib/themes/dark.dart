import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';

ThemeData darkTheme = ThemeData.dark().copyWith(
  extensions: <ThemeExtension<dynamic>>[
    const CustomColors(
      textColor: Color.fromARGB(255, 255, 255, 255),
      textbuttonBgColor: Color.fromARGB(89, 66, 66, 66),
      iconColor: Color.fromARGB(255, 255, 255, 255),
      iconActiveColor: Color.fromARGB(255, 0, 255, 255),
      cardBgColor: Color.fromARGB(89, 66, 66, 66),
      cardShadowColor: Color.fromARGB(255, 0, 0, 0),
    ),
  ],
);
