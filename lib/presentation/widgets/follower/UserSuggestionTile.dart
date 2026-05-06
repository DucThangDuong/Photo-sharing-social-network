import 'package:flutter/material.dart';

class UserSuggestionTile extends StatelessWidget {
  final String name;
  final String avatarUrl;
  final VoidCallback onFollowPressed;
  final VoidCallback onRemovePressed;

  const UserSuggestionTile({
    super.key,
    required this.name,
    required this.avatarUrl,
    required this.onFollowPressed,
    required this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[800],
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),

          // Tên và mô tả
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Gợi ý cho bạn',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),

          // Nút Theo dõi (Xanh dương)
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onFollowPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C68FF), // Màu xanh Instagram
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Theo dõi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),

          // Nút Xóa (Dấu x)
          GestureDetector(
            onTap: onRemovePressed,
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }
}
