import 'package:flutter/material.dart';
import '../../../Profile/Presentation/Widgets/comment_bottom_sheet.dart';
import '../../Models/post_model.dart';
import 'post_media_slider.dart';

class PostItem extends StatefulWidget {
  final PostModel post;
  const PostItem({super.key, required this.post});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isLiked = false;
  bool _isFollowed = false;
  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép đẩy lên khi hiện bàn phím
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CommentBottomSheet(post: widget.post),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header: Avatar + Tên + Nút Follow
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(widget.post.user.avatarUrl),
          ),
          title: Row(
            children: [
              Text(widget.post.user.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(width: 8),
              // Nút Follow giả lập
              GestureDetector(
                onTap: () => setState(() => _isFollowed = !_isFollowed),
                child: Text(
                  _isFollowed ? '• Đang theo dõi' : '• Theo dõi',
                  style: TextStyle(
                    color: _isFollowed ? Colors.grey : const Color(0xFF0064E0),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          trailing: const Icon(Icons.more_horiz, color: Colors.white),
        ),

        // 2. Hình ảnh (Carousel)
        PostMediaSlider(mediaList: widget.post.mediaList),

        // 3. Thanh tương tác
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.white,
              ),
              onPressed: () => setState(() => _isLiked = !_isLiked),
            ),
            IconButton(icon: const Icon(Icons.mode_comment_outlined, color: Colors.white), onPressed: () =>_showComments(context)),
            IconButton(icon: const Icon(Icons.send_outlined, color: Colors.white), onPressed: () {}),
            const Spacer(),
            IconButton(icon: const Icon(Icons.bookmark_border, color: Colors.white), onPressed: () {}),
          ],
        ),

        // 4. Lượt thích & Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_isLiked ? widget.post.likeCount + 1 : widget.post.likeCount} lượt thích',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white),
                  children: [
                    TextSpan(text: '${widget.post.user.username} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Xem tất cả ${widget.post.commentCount} bình luận',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}