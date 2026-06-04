import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/DTOs/PostDTO.dart';
import 'package:untitled/data/Helper.dart';
import 'package:untitled/Widgets/Features/Home/Presentation/Widgets/post_likes_sheet.dart';
import 'package:untitled/Widgets/Features/Home/Presentation/Widgets/share_post_bottom_sheet.dart';

import '../../../Profile/Presentation/Widgets/comment_bottom_sheet.dart';

class PostItem extends StatefulWidget {
  final HomePostDTO post;
  final ValueChanged<HomePostDTO> onPostUpdated;
  final VoidCallback onLikeToggle;
  final VoidCallback? onUserTap;

  const PostItem({
    super.key,
    required this.post,
    required this.onPostUpdated,
    required this.onLikeToggle,
    this.onUserTap,
  });

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  int _currentImageIndex = 0;

  // các btn tương tác bài viết
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
            color: widget.post.isLikedByCurrentUser ? Colors.red : Colors.white,
          ),
          onPressed: widget.onLikeToggle,
        ),
        if (!widget.post.disableComments)
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => _showComments(context),
          ),
        IconButton(
          icon: const Icon(Icons.near_me_outlined, color: Colors.white),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SharePostBottomSheet(postId: widget.post.id),
            );
          },
        ),
        
        Expanded(
          child: widget.post.postMedia.length > 1
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.post.postMedia.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.blue
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        
        const SizedBox(width: 48),
      ],
    );
  }

  // hiển thị danh sách comment của bài post
  void _showComments(BuildContext context) {
    final postDetail = PostDetailUserDTO(
      id: widget.post.id,
      caption: widget.post.caption,
      createdAt: widget.post.createdAt,
      visibility: widget.post.visibility,
      hideLikeCount: widget.post.hideLikeCount,
      disableComments: widget.post.disableComments,
      postMedia: widget.post.postMedia,
      likeCount: widget.post.likeCount,
      commentCount: widget.post.commentCount,
      isLikedByCurrentUser: widget.post.isLikedByCurrentUser,
      isArchived: widget.post.isArchived,
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
    String userAvatar = widget.post.avatarUrl != null && widget.post.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(widget.post.avatarUrl!)
        : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header: Avatar + Tên người đăng
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: GestureDetector(
            onTap: widget.onUserTap,
            child: userAvatar.isNotEmpty
                ? CircleAvatar(radius: 18, backgroundImage: NetworkImage(userAvatar))
                : const CircleAvatar(radius: 18, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
          ),
          title: GestureDetector(
            onTap: widget.onUserTap,
            child: Text(
              widget.post.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          trailing: const Icon(Icons.more_horiz, color: Colors.white),
        ),

        // 2. Hình ảnh bài viết
        if (widget.post.postMedia.isNotEmpty)
          AspectRatio(
            aspectRatio: 1,
            child: PageView.builder(
              itemCount: widget.post.postMedia.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                String imageUrl = AppHelper.formatImageURL(widget.post.postMedia[index].mediaUrl);
                return Image.network(
                  imageUrl, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

        // 3. Thanh tương tác
        SizedBox(height: 10),
        _buildActionButtons(context),

        // 4. Số lượt thích
        if (widget.post.likeCount >= 0 && !widget.post.hideLikeCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => PostLikesSheet(postId: widget.post.id),
                );
              },
              child: Text('${widget.post.likeCount} lượt thích',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

        // 5. Caption
        if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.white),
                children: [
                  TextSpan(text: widget.post.caption!),
                ],
              ),
            ),
          ),

        // 6. Số bình luận
        if (widget.post.commentCount >= 0 && !widget.post.disableComments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            child: GestureDetector(
              onTap: () => _showComments(context),
              child: Text('Xem tất cả ${widget.post.commentCount} bình luận',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ),

        // 7. Ngày đăng
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Text(
            '${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}