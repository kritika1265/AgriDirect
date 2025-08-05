import 'package:flutter/material.dart';

/// A customizable loading widget with optional message
class LoadingWidget extends StatelessWidget {
  /// Optional message to display below the loading indicator
  final String? message;
  
  /// Size of the loading indicator
  final double? size;
  
  /// Color of the loading indicator and text
  final Color? color;

  /// Creates a loading widget
  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 50.0,
            height: size ?? 50.0,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: color ?? Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// A loading overlay that can be displayed over any widget
class LoadingOverlay extends StatelessWidget {
  /// The child widget to display behind the loading overlay
  final Widget child;
  
  /// Whether to show the loading overlay
  final bool isLoading;
  
  /// Optional message to display in the loading overlay
  final String? loadingMessage;
  
  /// Color of the loading indicator
  final Color? loadingColor;
  
  /// Opacity of the overlay background
  final double overlayOpacity;

  /// Creates a loading overlay
  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
    this.loadingColor,
    this.overlayOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(overlayOpacity),
            child: LoadingWidget(
              message: loadingMessage,
              color: loadingColor,
            ),
          ),
      ],
    );
  }
}