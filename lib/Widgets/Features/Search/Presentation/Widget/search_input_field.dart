import 'package:flutter/material.dart';

class SearchInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final VoidCallback onTap;
  final Function(String) onSubmitted;
  final VoidCallback onCancel;

  const SearchInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onTap,
    required this.onSubmitted,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                ),
                onTap: onTap,
                onSubmitted: onSubmitted,
              ),
            ),
          ),
          if (isSearching)
            TextButton(
              onPressed: onCancel,
              child: const Text('Hủy', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}