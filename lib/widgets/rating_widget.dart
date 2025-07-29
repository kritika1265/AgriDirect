class RatingWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final Function(double)? onRatingChanged;
  final bool allowHalfRating;

  const RatingWidget({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
    this.onRatingChanged,
    this.allowHalfRating = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged!(index + 1.0)
              : null,
          child: Icon(
            _getStarIcon(index),
            size: size,
            color: _getStarColor(index, context),
          ),
        );
      }),
    );
  }

  IconData _getStarIcon(int index) {
    if (rating >= index + 1) {
      return Icons.star;
    } else if (allowHalfRating && rating >= index + 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }

  Color _getStarColor(int index, BuildContext context) {
    if (rating > index) {
      return activeColor ?? Colors.amber;
    } else {
      return inactiveColor ?? Colors.grey.shade400;
    }
  }
}