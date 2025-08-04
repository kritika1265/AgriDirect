import 'package:flutter/material.dart';

/// A customizable rating widget that displays stars and allows user interaction.
class RatingWidget extends StatelessWidget {
  /// The current rating value (0.0 to maxRating).
  final double rating;
  
  /// The maximum number of stars to display.
  final int maxRating;
  
  /// The size of each star icon.
  final double size;
  
  /// The color of active (filled) stars.
  final Color? activeColor;
  
  /// The color of inactive (empty) stars.
  final Color? inactiveColor;
  
  /// Callback function called when the rating changes.
  final void Function(double)? onRatingChanged;
  
  /// Whether to allow half-star ratings.
  final bool allowHalfRating;

  /// Creates a rating widget.
  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.allowHalfRating = true,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(maxRating, (index) => GestureDetector(
      onTap: onRatingChanged != null
          ? () => _handleTap(index)
          : null,
      child: Icon(
        _getStarIcon(index),
        size: size,
        color: _getStarColor(index, context),
      ),
    )),
  );

  void _handleTap(int index) {
    onRatingChanged?.call(index + 1.0);
  }

  IconData _getStarIcon(int index) {
    final clampedRating = rating.clamp(0.0, maxRating.toDouble());
    
    if (clampedRating >= index + 1) {
      return Icons.star;
    } else if (allowHalfRating && clampedRating >= index + 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index, BuildContext context) {
    final clampedRating = rating.clamp(0.0, maxRating.toDouble());
    
    if (clampedRating > index) {
      return activeColor ?? Colors.amber;
    } else {
      return inactiveColor ?? Colors.grey.shade400;
    }
  }
}