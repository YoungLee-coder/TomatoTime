import 'package:flutter/material.dart';

class AnimatedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? leading;
  final double? titleSpacing;
  final List<Widget>? actions;

  const AnimatedAppBar({
    Key? key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.leading,
    this.titleSpacing,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      color: backgroundColor,
      child: AppBar(
        title: Text(
          title,
          style:
              foregroundColor != null
                  ? TextStyle(
                    color: foregroundColor,
                    fontWeight: FontWeight.bold,
                  )
                  : null,
        ),
        elevation: elevation,
        backgroundColor: Colors.transparent,
        foregroundColor: foregroundColor,
        leading: leading,
        titleSpacing: titleSpacing,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
