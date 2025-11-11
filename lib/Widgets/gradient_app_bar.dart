import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Gradient? gradient;
  final double? elevation;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const GradientAppBar({
    super.key,
    this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.gradient,
    this.elevation,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: elevation ?? 4,
      leading: leading,
      bottom: bottom,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient ??
              const LinearGradient(
                colors: [
                  Color.fromRGBO(37, 150, 250, 1),
                  Color.fromRGBO(54, 74, 98, 0.85)
                ],
                transform: GradientRotation(0.5),
              ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

