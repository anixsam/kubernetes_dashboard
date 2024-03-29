import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';

// ignore: must_be_immutable
class SideNavIcon extends StatelessWidget {
  SideNavIcon({
    super.key,
    required this.isCollapsed,
    required this.icon,
    required this.text,
    required this.iconColor,
    required this.bgColor,
    required this.isActive,
    required this.onTap,
  });

  bool isCollapsed;
  bool isActive;
  Color bgColor;
  Color iconColor;
  IconData icon;
  String text;
  Function() onTap;

  @override
  Widget build(BuildContext context) {
    final CustomColors customTheme =
        Theme.of(context).extension<CustomColors>()!;
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        width: isCollapsed ? 50 : 150,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isActive
                ? customTheme.iconActiveColor ?? Colors.transparent
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            isCollapsed
                ? Container()
                : const SizedBox(
                    width: 10,
                  ),
            isCollapsed
                ? Container()
                : Text(
                    text,
                    style: TextStyle(
                      color: iconColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
