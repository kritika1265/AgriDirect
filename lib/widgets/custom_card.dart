import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? backgroundColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Border? border;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.onTap,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(8.0),
      child: Material(
        elevation: elevation ?? 4.0,
        borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
        color: backgroundColor ?? Colors.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(borderRadius ?? 12.0),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}