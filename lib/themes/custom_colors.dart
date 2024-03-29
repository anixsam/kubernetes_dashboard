import 'package:flutter/material.dart';

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.textColor,
    required this.textbuttonBgColor,
    required this.iconColor,
    required this.iconActiveColor,
    required this.cardBgColor,
    this.cardShadowColor,
  });

  final Color? textColor;
  final Color? textbuttonBgColor;
  final Color? iconColor;
  final Color? iconActiveColor;
  final Color? cardBgColor;
  final Color? cardShadowColor;

  @override
  CustomColors copyWith({
    Color? textColor,
    Color? textbuttonBgColor,
    Color? iconColor,
    Color? iconActiveColor,
    Color? cardBgColor,
    Color? cardShadowColor,
  }) {
    return CustomColors(
      textColor: textColor ?? this.textColor,
      textbuttonBgColor: textbuttonBgColor ?? this.textbuttonBgColor,
      iconColor: iconColor ?? this.iconColor,
      iconActiveColor: iconActiveColor ?? this.iconActiveColor,
      cardBgColor: cardBgColor ?? this.cardBgColor,
      cardShadowColor: cardShadowColor ?? this.cardShadowColor,
    );
  }

  @override
  CustomColors lerp(CustomColors? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      textColor: Color.lerp(textColor, other.textColor, t),
      textbuttonBgColor:
          Color.lerp(textbuttonBgColor, other.textbuttonBgColor, t),
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      iconActiveColor: Color.lerp(iconActiveColor, other.iconActiveColor, t),
      cardBgColor: Color.lerp(cardBgColor, other.cardBgColor, t),
      cardShadowColor: Color.lerp(cardShadowColor, other.cardShadowColor, t),
    );
  }
}
