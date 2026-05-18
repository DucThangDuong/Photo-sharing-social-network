import 'package:flutter/material.dart';

class NewPostControlBar extends StatelessWidget {
  final bool isMultiSelectMode;
  final VoidCallback onToggleMultiSelectMode;

  const NewPostControlBar({
    super.key,
    required this.isMultiSelectMode,
    required this.onToggleMultiSelectMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Text(
                'Gần đây',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
            ],
          ),
          GestureDetector(
            onTap: onToggleMultiSelectMode,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMultiSelectMode ? Colors.blueAccent : Colors.white12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.filter_none, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Chọn',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}