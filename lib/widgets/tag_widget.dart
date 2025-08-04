import 'package:flutter/material.dart';

class TagWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const TagWidget({
    super.key, // Updated from Key? key
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isSelected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final bgColor = isSelected
        ? theme.primaryColor
        : backgroundColor ?? theme.colorScheme.surface;
    
    final txtColor = isSelected
        ? theme.colorScheme.onPrimary
        : textColor ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected 
            ? null 
            : Border.all(
                color: theme.colorScheme.outline.withOpacity(0.5),
                width: 1,
              ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: txtColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}