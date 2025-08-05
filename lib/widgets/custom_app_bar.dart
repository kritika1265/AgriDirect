import 'package:flutter/material.dart';

/// A customizable app bar widget with enhanced styling options
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;
  
  /// Actions to display on the right side of the app bar
  final List<Widget>? actions;
  
  /// Leading widget (usually back button or menu button)
  final Widget? leading;
  
  /// Whether to center the title
  final bool centerTitle;
  
  /// Background color of the app bar
  final Color? backgroundColor;
  
  /// Foreground color (text and icons)
  final Color? foregroundColor;
  
  /// Elevation of the app bar
  final double? elevation;
  
  /// Bottom widget (usually TabBar)
  final PreferredSizeWidget? bottom;
  
  /// Whether to automatically imply leading widget
  final bool automaticallyImplyLeading;
  
  /// Text style for the title
  final TextStyle? titleTextStyle;

  /// Creates a custom app bar
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleTextStyle ?? TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 4.0,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      shadowColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}