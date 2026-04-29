import 'package:flutter/material.dart';
import '../../../../../../data/Models/PostViewModel.dart';
import 'post_media_slider.dart';

class PostItem extends StatefulWidget {
  final PostViewModel postData;
  const PostItem({super.key, required this.postData});

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _isLiked = false;
  bool _isFollowed = false;

  @override
  Widget build(BuildContext context) {
    // Trích xuất các đối tượng từ ViewModel để code ngắn gọn hơn
    final user = widget.postData.user;
    final post = widget.postData.post;
    final mediaList = widget.postData.mediaList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header: Avatar + Tên + Nút Follow
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[800],
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white, size: 20)
                : null,
          ),
          title: Row(
            children: [
              Text(
                  user.username,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14
                  )
              ),
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

        // 2. Hình ảnh (Carousel) - Truyền danh sách PostMedia mới
        PostMediaSlider(mediaList: mediaList),

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
            IconButton(
                icon: const Icon(Icons.mode_comment_outlined, color: Colors.white),
                onPressed: () {}
            ),
            IconButton(
                icon: const Icon(Icons.send_outlined, color: Colors.white),
                onPressed: () {}
            ),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.bookmark_border, color: Colors.white),
                onPressed: () {}
            ),
          ],
        ),

        // 4. Lượt thích & Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_isLiked ? widget.postData.likeCount + 1 : widget.postData.likeCount} lượt thích',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
              const SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  children: [
                    TextSpan(
                        text: '${user.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold)
                    ),
                    TextSpan(text: post.caption ?? ''), // Lấy caption từ object post
                  ],
                ),
              ),
              const SizedBox(height: 5),
              if (widget.postData.commentCount > 0)
                Text(
                  'Xem tất cả ${widget.postData.commentCount} bình luận',
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