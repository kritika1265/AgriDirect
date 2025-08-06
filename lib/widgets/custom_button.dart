// All imports must be at the top
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final IconData? icon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? elevation;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Loading state - show centered progress indicator
    if (isLoading && isOutlined) {
      return SizedBox(
        width: width,
        height: height ?? 50.0,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final effectiveBorderRadius = borderRadius ?? 8.0;
    final effectivePadding = padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 24);
    final effectiveFontSize = fontSize ?? 16.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.w600;

    // Outlined Button Style
    if (isOutlined) {
      return SizedBox(
        width: width,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            padding: effectivePadding,
            side: BorderSide(
              color: borderColor ?? backgroundColor ?? Colors.green,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(effectiveBorderRadius),
            ),
          ),
          child: _buildButtonContent(context, isOutlined: true),
        ),
      );
    }

    // Elevated Button Style (Default)
    return SizedBox(
      width: width,
      height: height ?? 50.0,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.green,
          foregroundColor: textColor ?? Colors.white,
          padding: effectivePadding,
          elevation: elevation ?? 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, {bool isOutlined = false}) {
    final effectiveTextColor = isOutlined 
        ? (textColor ?? borderColor ?? backgroundColor ?? Colors.green)
        : (textColor ?? Colors.white);
    
    final effectiveFontSize = fontSize ?? 16.0;
    final effectiveFontWeight = fontWeight ?? FontWeight.w600;

    // Loading state content
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? (borderColor ?? backgroundColor ?? Colors.green) : Colors.white,
          ),
        ),
      );
    }

    // Button content with optional icon
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            color: effectiveTextColor,
            size: effectiveFontSize + 2,
          ),
          const SizedBox(width: 8.0),
        ],
        Text(
          text,
          style: TextStyle(
            color: effectiveTextColor,
            fontSize: effectiveFontSize,
            fontWeight: effectiveFontWeight,
          ),
        ),
      ],
    );
  }
}