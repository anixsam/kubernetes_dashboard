import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/providers/dashboard_config_provider.dart';
import 'package:kubernetes_dashboard/providers/data_provider.dart';
import 'package:kubernetes_dashboard/screens/home.dart';
import 'package:kubernetes_dashboard/themes/dark.dart';
import 'package:kubernetes_dashboard/themes/light.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider()),
        ChangeNotifierProvider(create: (context) => DashboardConfigProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kubernetes Dashboard',
      home: const HomeScreen(),
      theme: lightTheme,
      darkTheme: darkTheme,
    );
  }
}
