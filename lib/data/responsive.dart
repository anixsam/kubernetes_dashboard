import 'package:flutter/material.dart';

class Responsive {
  isMobile(context) {
    return MediaQuery.of(context).size.width < 800;
  }

  isDesktop(context) {
    return MediaQuery.of(context).size.width > 800;
  }
}
