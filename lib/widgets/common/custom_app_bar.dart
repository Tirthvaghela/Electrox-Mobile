import 'package:flutter/material.dart';
import '../../config/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.textOnDark,
          fontFamily: 'Roboto',
        ),
      ),
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: AppTheme.textOnDark,
      elevation: 2,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      bottom: bottom,
      iconTheme: const IconThemeData(
        color: AppTheme.textOnDark,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0 + (bottom?.preferredSize.height ?? 0.0));
}