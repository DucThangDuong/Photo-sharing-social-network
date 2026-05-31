import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/Helper.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../data/datasources/global/User.dart';
import '../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../Widgets/Features/Profile/Presentation/Widgets/comment_bottom_sheet.dart';
import '../../../Widgets/Features/Home/Presentation/Widgets/post_likes_sheet.dart';

class UserPostsDetailPageGuest extends StatefulWidget {
  final int initialIndex;
  final UserModelDTO? user;

  const UserPostsDetailPageGuest({super.key, required this.initialIndex, this.user});

  @override
  State<UserPostsDetailPageGuest> createState() => _UserPostsDetailPageState();
}

class _UserPostsDetailPageState extends State<UserPostsDetailPageGuest> {
  late final ScrollController _scrollController;
  List<PostDetailUserDTO> _detailedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.initialIndex * 600.0,
    );
    _fetchDetailedPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // lấy danh sách bài viết của người dùng từ api
  Future<void> _fetchDetailedPosts() async {
    try {
      final endpoint = widget.user != null ? '/user/${widget.user!.id}/posts' : '/user/posts';
      final response = await CallMyAPI.getUserPostsDetail(endpoint);
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _detailedPosts =
              rawList.map((i) => PostDetailUserDTO.fromJson(i)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // người dùng like bài viết và cập nhật số lượt thích
  Future<void> _toggleLike(PostDetailUserDTO post) async {
    final bool currentlyLiked = post.isLikedByCurrentUser;
    setState(() {
      final index = _detailedPosts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _detailedPosts[index] = post.copyWith(
          isLikedByCurrentUser: !currentlyLiked,
          likeCount: currentlyLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
    });

    try {
      await CallMyAPI.toggleLikePost(post.id);
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _detailedPosts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _detailedPosts[index] = post;
          }
        });
      }
    }
  }
  // xem các option để người dùng chọn làm gì với bài viết
  Future<void> _showSheet(BuildContext context, Widget sheet, {bool isFull = false}) async {
    final dynamic result = await showModalBottomSheet(
      context: context,
      isScrollControlled: isFull,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => sheet,
    );

    if (result == 'deleted' && mounted) {
      Navigator.pop(context);
      return;
    }

    if (result != null && result is PostDetailUserDTO) {
      setState(() {
        final index = _detailedPosts.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _detailedPosts[index] = result;
        }
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Bài viết', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_detailedPosts.isEmpty
              ? const Center(
                  child: Text('Không có bài viết',
                      style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _detailedPosts.length,
                  itemBuilder: (context, index) {
                    final post = _detailedPosts[index];
                    final currentUser = context.watch<UserProvider>().user;
                    final displayUser = widget.user ?? currentUser;
                    return UserPostDetailItemGuest(
                      post: post,
                      displayUser: displayUser,
                      onToggleLike: _toggleLike,
                      onShowSheet: (ctx, sheet) => _showSheet(ctx, sheet, isFull: sheet is CommentBottomSheet),
                    );
                  },
                )),
    );
  }
}

class UserPostDetailItemGuest extends StatefulWidget {
  final PostDetailUserDTO post;
  final UserModelDTO? displayUser;
  final Function(PostDetailUserDTO) onToggleLike;
  final Function(BuildContext, Widget) onShowSheet;

  const UserPostDetailItemGuest({
    super.key,
    required this.post,
    required this.displayUser,
    required this.onToggleLike,
    required this.onShowSheet,
  });

  @override
  State<UserPostDetailItemGuest> createState() => _UserPostDetailItemGuestState();
}

class _UserPostDetailItemGuestState extends State<UserPostDetailItemGuest> {
  int _currentImageIndex = 0;

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            widget.post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border,
            color: widget.post.isLikedByCurrentUser ? Colors.red : Colors.white,
          ),
          onPressed: () => widget.onToggleLike(widget.post),
        ),
        if (!widget.post.disableComments)
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => widget.onShowSheet(
              context,
              CommentBottomSheet(post: widget.post),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.send_outlined, color: Colors.white),
          onPressed: () {},
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

  @override
  Widget build(BuildContext context) {
    if (widget.displayUser == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white54),
      );
    }
    var imageUserUrl = AppHelper.formatImageURL(
        widget.displayUser!.avatarUrl.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
              radius: 15, backgroundImage: NetworkImage(imageUserUrl)),
          title: Text(widget.displayUser!.username ?? 'Người dùng',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
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
        _buildActionButtons(context),
        if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
                widget.post.caption!, style: const TextStyle(color: Colors.white)),
          ),
        if (widget.post.likeCount >= 0 && !widget.post.hideLikeCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: GestureDetector(
              onTap: () => widget.onShowSheet(
                context,
                PostLikesSheet(postId: widget.post.id),
              ),
              child: Text('${widget.post.likeCount} lượt thích', style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        if (widget.post.commentCount >= 0 && !widget.post.disableComments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: GestureDetector(
              onTap: () => widget.onShowSheet(
                context,
                CommentBottomSheet(post: widget.post),
              ),
              child: Text('Xem tất cả ${widget.post.commentCount} bình luận',
                  style: const TextStyle(color: Colors.grey)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            '${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

