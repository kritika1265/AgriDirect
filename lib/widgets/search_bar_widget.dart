import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
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
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isControllerInternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isControllerInternal = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_onTextChanged);
      
      if (_isControllerInternal && oldWidget.controller == null) {
        _controller.dispose();
      }
      
      if (widget.controller == null) {
        _controller = TextEditingController();
        _isControllerInternal = true;
      } else {
        _controller = widget.controller!;
        _isControllerInternal = false;
      }
      
      _controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_isControllerInternal) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to show/hide clear button
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }
  }

  void _onClear() {
    _controller.clear();
    if (widget.onClear != null) {
      widget.onClear!();
    }
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

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
              controller: _controller,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Search...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: _onClear,
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
          if (widget.showFilter) ...[
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.grey),
              onPressed: widget.onFilterPressed,
            ),
          ],
        ],
      ),
    );
  }
}