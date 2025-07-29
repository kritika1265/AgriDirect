class TagWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const TagWidget({
    Key? key,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isSelected = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? Theme.of(context).primaryColor
        : backgroundColor ?? Colors.grey.shade200;
    final txtColor = isSelected
        ? Colors.white
        : textColor ?? Colors.grey.shade700;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
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
