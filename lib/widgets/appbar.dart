import 'package:flutter/material.dart';
import 'package:kubernetes_dashboard/themes/custom_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    required this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    CustomColors customTheme = Theme.of(context).extension<CustomColors>()!;

    return AppBar(
      surfaceTintColor: customTheme.cardBgColor,
      backgroundColor: customTheme.cardBgColor,
      title: Text(
        title,
        style: TextStyle(
          color: customTheme.textColor ?? Colors.black,
        ),
      ),
      actions: actions,
    );
  }
}
