import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// 深色背景 + 金色底边的古典 AppBar
class ClassicalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const ClassicalAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(
          title: Text(title),
          actions: actions,
          leading: leading,
          automaticallyImplyLeading: showBackButton,
        ),
        // Gold bottom border
        Container(
          height: 2,
          color: AppColors.gold,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 2);
}
