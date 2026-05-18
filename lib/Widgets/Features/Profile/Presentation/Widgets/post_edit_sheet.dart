import 'package:flutter/material.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/ApiServices.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasources/global/User.dart';
import '../../../../../data/datasources/DTOs/UserDTO.dart';
import '../Page/edit_caption_post_page.dart';

class PostOptionsSheet extends StatelessWidget {
  final PostDetailUserDTO post;
  const PostOptionsSheet({super.key, required this.post});

  Future<void> _confirmAndUpdate(BuildContext context, String field, dynamic newValue, String confirmMessage) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
        content: Text(confirmMessage, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.white))
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đồng ý', style: TextStyle(color: Colors.blue))
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await ApiService().put(
        '/user/post/${post.id}',
        data: {field: newValue},
      );

      if (response != null && response['data'] != null) {
        PostDetailUserDTO updatedPost = PostDetailUserDTO.fromJson(response['data']);
        if (context.mounted) Navigator.pop(context, updatedPost);
      } else {
        if (context.mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPublic = post.visibility == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOptionItem(
            Icons.lock_outline,
            isPublic ? 'Chuyển sang chế độ riêng tư' : 'Chuyển sang chế độ công khai',
            () => _confirmAndUpdate(context, 'Visibility', isPublic ? 1 : 0, 'Bạn có chắc muốn đổi chế độ hiển thị?')
          ),
          _buildOptionItem(
            Icons.archive_outlined,
            post.isArchived ? 'Bỏ lưu trữ' : 'Lưu trữ',
            () => _confirmAndUpdate(context, 'IsArchived', !post.isArchived, 'Bạn có chắc muốn thay đổi trạng thái lưu trữ?')
          ),
          _buildOptionItem(Icons.edit_outlined, 'Chỉnh sửa', () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPostPage(post: post),
              ),
            );
            if (result != null && context.mounted) {
              Navigator.pop(context, result);
            }
          }),
          _buildOptionItem(
            Icons.favorite_border,
            post.hideLikeCount ? 'Hiển thị số lượt thích' : 'Ẩn số lượt thích',
            () => _confirmAndUpdate(context, 'HideLikeCount', !post.hideLikeCount, 'Bạn có chắc muốn thay đổi cài đặt hiển thị lượt thích?')
          ),
          _buildOptionItem(
            Icons.mode_comment_outlined,
            post.disableComments ? 'Bật tính năng bình luận' : 'Tắt tính năng bình luận',
            () => _confirmAndUpdate(context, 'DisableComments', !post.disableComments, 'Bạn có chắc muốn thay đổi cài đặt bình luận?')
          ),
          const Divider(color: Colors.white12),
          _buildOptionItem(Icons.delete_outline, 'Xóa bài viết', () async {
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.grey[900],
                title: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                content: const Text('Bạn có chắc muốn xóa bài viết này không?', style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Hủy', style: TextStyle(color: Colors.white))
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Xóa', style: TextStyle(color: Colors.red))
                  ),
                ],
              ),
            );

            if (confirm != true) return;

            try {
              await ApiService().delete('/user/post/${post.id}');

              if (context.mounted) {
                try {
                  final userRes = await ApiService().get('/user/profile');
                  if (userRes != null && userRes['data'] != null) {
                    UserModelDTO updatedUser = UserModelDTO.fromJson(userRes['data']);
                    Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
                  }
                } catch (e) {
                  debugPrint("Lỗi tải lại thông tin người dùng: $e");
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Xóa bài viết thành công!')),
                );

                Navigator.pop(context, 'deleted');
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Xóa bài viết thất bại: $e')),
                );
                Navigator.pop(context);
              }
            }
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