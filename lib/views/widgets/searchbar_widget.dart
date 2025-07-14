import 'package:downtube_app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;

  const SearchBarWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.onSubmitted,
    this.readOnly = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          autofocus: true,
          onSubmitted: widget.onSubmitted,
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(
            hintText: "Search videos...",
            hintStyle: const TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: widget.readOnly
                ? const Icon(Icons.download, color: AppColors.primary)
                : InkWell(
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                    onTap: () => context.pop(),
                  ),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.primary),
                    onPressed:
                        widget.onClear ??
                        () {
                          widget.controller.clear();
                          setState(() {}); // Rebuild to update suffix icon
                        },
                  )
                : const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}
