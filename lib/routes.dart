import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/screens/home_page.dart';
import 'package:kubernetes_dashboard/screens/settings.dart';

class Routes {
  static final List<Route> routes = [
    Route(
      name: 'Home',
      widget: const HomePage(),
      icon: Icons.home,
    ),
    Route(
      name: 'Settings',
      widget: const SettingsScreen(),
      icon: Icons.settings,
    ),
  ];
}

class Route {
  final String name;
  final Widget widget;
  final IconData icon;

  Route({
    required this.name,
    required this.widget,
    required this.icon,
  });
}
