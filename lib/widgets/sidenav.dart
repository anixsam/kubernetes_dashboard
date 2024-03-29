import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/routes.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';
import 'package:kubernetes_dashboard/widgets/sidenav_item.dart';

class CollapsibleSideNav extends StatefulWidget {
  const CollapsibleSideNav({
    super.key,
    required this.pageController,
  });

  final PageController pageController;

  @override
  State<CollapsibleSideNav> createState() => _CollapsibleSideNavState();
}

class _CollapsibleSideNavState extends State<CollapsibleSideNav> {
  bool _isCollapsed = false;
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final CustomColors customTheme =
        Theme.of(context).extension<CustomColors>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
      color: Colors.transparent,
      width: _isCollapsed ? 150 : 200,
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: double.infinity,
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  _isCollapsed ? Icons.menu : Icons.menu_open,
                  color: customTheme.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            ...Routes.routes.map((route) {
              return Column(
                children: [
                  SideNavIcon(
                    isCollapsed: _isCollapsed,
                    icon: route.icon,
                    text: route.name,
                    iconColor: customTheme.iconColor ?? Colors.black,
                    bgColor: customTheme.textbuttonBgColor ?? Colors.white,
                    isActive: currentPage == Routes.routes.indexOf(route),
                    onTap: () {
                      widget.pageController.animateToPage(
                        Routes.routes.indexOf(route),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                      setState(() {
                        currentPage = Routes.routes.indexOf(route);
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),
            // SideNavIcon(
            //   isCollapsed: _isCollapsed,
            //   icon: FontAwesomeIcons.houseChimney,
            //   text: 'Home',
            //   iconColor: customTheme.iconColor ?? Colors.black,
            //   bgColor: customTheme.textbuttonBgColor ?? Colors.white,

            // ),
            // const SizedBox(height: 20),
            // SideNavIcon(
            //   isCollapsed: _isCollapsed,
            //   icon: FontAwesomeIcons.gear,
            //   text: 'Settings',
            //   iconColor: customTheme.iconColor ?? Colors.black,
            //   bgColor: customTheme.textbuttonBgColor ?? Colors.white,
            // ),
          ],
        ),
      ),
    );
  }
}
