class SearchBarWidget extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onClear;
  final bool showFilter;
  final VoidCallback? onFilterPressed;

  const SearchBarWidget({
    Key? key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
    this.showFilter = false,
    this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint ?? 'Search...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: controller?.text.isNotEmpty == true
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: onClear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          if (showFilter) ...[
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.grey),
              onPressed: onFilterPressed,
            ),
          ],
        ],
      ),
    );
  }
}