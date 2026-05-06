import 'package:flutter/material.dart';

import 'EditPostPage.dart';

class PostOptionsSheet extends StatelessWidget {
  final dynamic post;
  const PostOptionsSheet({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionItem(Icons.lock_outline, 'Chế độ riêng tư/Công khai', () {}),
          _buildOptionItem(Icons.archive_outlined, 'Lưu trữ', () {}),
          _buildOptionItem(Icons.edit_outlined, 'Chỉnh sửa', () {
            Navigator.pop(context); // Đóng Menu cũ
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPostPage(post: post),
              ),
            );
          }),
          _buildOptionItem(Icons.favorite_border, 'Ẩn số lượt thích', () {}),
          _buildOptionItem(Icons.mode_comment_outlined, 'Tắt tính năng bình luận', () {}),
          const Divider(color: Colors.white12),
          _buildOptionItem(Icons.delete_outline, 'Xóa bài viết', () {
            // Gọi API xóa bài viết của Thành ở đây
          }, isDanger: true),
        ],
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.white),
      title: Text(title, style: TextStyle(color: isDanger ? Colors.red : Colors.white)),
      onTap: onTap,
    );
  }
}