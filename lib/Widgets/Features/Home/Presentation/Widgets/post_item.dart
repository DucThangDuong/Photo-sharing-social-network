import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/DTOs/PostDTO.dart';
import 'package:untitled/data/Helper.dart';
import '../../../Profile/Presentation/Widgets/comment_bottom_sheet.dart';

class PostItem extends StatelessWidget {
  final HomePostDTO post;
  final ValueChanged<HomePostDTO> onPostUpdated;
  final VoidCallback onLikeToggle;

  const PostItem({
    super.key,
    required this.post,
    required this.onPostUpdated,
    required this.onLikeToggle,
  });
  // các btn tương tác bài viết
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
            color: post.isLikedByCurrentUser ? Colors.red : Colors.white,
          ),
          onPressed: onLikeToggle,
        ),
        if (!post.disableComments)
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => _showComments(context),
          ),
        IconButton(icon: const Icon(Icons.send_outlined, color: Colors.white), onPressed: () {}),
        const Spacer(),
        IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white), onPressed: () {}),
      ],
    );
  }
  // hiển thị danh sách comment của bài post
  void _showComments(BuildContext context) {
    final postDetail = PostDetailUserDTO(
      id: post.id,
      caption: post.caption,
      createdAt: post.createdAt,
      visibility: post.visibility,
      hideLikeCount: post.hideLikeCount,
      disableComments: post.disableComments,
      postMedia: post.postMedia,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      isLikedByCurrentUser: post.isLikedByCurrentUser,
      isArchived: post.isArchived,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentBottomSheet(post: postDetail),
    );
  }
  @override
  Widget build(BuildContext context) {
    String imageUrl = post.postMedia.isNotEmpty
        ? AppHelper.formatImageURL(post.postMedia[0].mediaUrl)
        : '';
    String userAvatar = post.avatarUrl != null && post.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(post.avatarUrl!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header: Avatar + Tên người đăng
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: userAvatar.isNotEmpty
              ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(userAvatar))
              : const CircleAvatar(radius: 18, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
          title: Text(
            post.username,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          trailing: const Icon(Icons.more_horiz, color: Colors.white),
        ),

        // 2. Hình ảnh bài viết
        if (imageUrl.isNotEmpty)
          Image.network(imageUrl, width: double.infinity, fit: BoxFit.fitWidth),

        // 3. Thanh tương tác
        _buildActionButtons(context),

        // 4. Số lượt thích
        if (post.likeCount >= 0 && !post.hideLikeCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('${post.likeCount} lượt thích',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),

        // 5. Caption
        if (post.caption != null && post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(text: post.caption!),
                ],
              ),
            ),
          ),

        // 6. Số bình luận
        if (post.commentCount >= 0 && !post.disableComments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: GestureDetector(
              onTap: () => _showComments(context),
              child: Text('Xem tất cả ${post.commentCount} bình luận',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ),

        // 7. Ngày đăng
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Text(
            '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

}