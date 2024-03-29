import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/providers/dashboard_config_provider.dart';
import 'package:kubernetes_dashboard/screens/home_page.dart';
import 'package:kubernetes_dashboard/screens/settings.dart';
import 'package:kubernetes_dashboard/widgets/sidenav.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );

  List<Widget> pages = [
    const HomePage(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();

    fetchConfig();
  }

  void fetchConfig() {
    DashboardConfigProvider dashboardConfigProvider =
        Provider.of<DashboardConfigProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashboardConfigProvider.fetchDashboardConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    DashboardConfigProvider dashboardConfigProvider =
        Provider.of<DashboardConfigProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: CollapsibleSideNav(
              pageController: _pageController,
            ),
          ),
          dashboardConfigProvider.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
                  flex: 5,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: pages,
                  ),
                )
        ],
      ),
    );
  }
}
