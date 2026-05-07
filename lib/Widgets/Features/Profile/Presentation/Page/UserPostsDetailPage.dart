import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/global/User.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../widgets/post_options_sheet.dart';

class UserPostsDetailPage extends StatefulWidget {
  final int initialIndex;

  const UserPostsDetailPage({super.key, required this.initialIndex});

  @override
  State<UserPostsDetailPage> createState() => _UserPostsDetailPageState();
}

class _UserPostsDetailPageState extends State<UserPostsDetailPage> {
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

  Future<void> _fetchDetailedPosts() async {
    try {
      final response = await ApiService().get('/user/posts');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _detailedPosts = rawList.map((i) => PostDetailUserDTO.fromJson(i)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              ? const Center(child: Text('Không có bài viết', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _detailedPosts.length,
                  itemBuilder: (context, index) => _buildPostItem(context, _detailedPosts[index]),
                )),
    );
  }

  Widget _buildPostItem(BuildContext context, PostDetailUserDTO post) {
    String imageUrl = post.postMedia.isNotEmpty ? 'http://10.0.2.2:5090' + post.postMedia[0].mediaUrl : '';

    final currentUser = context.watch<UserProvider>().user;
    if (currentUser == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white54),
      );
    }
    var imageUserUrl = 'http://10.0.2.2:5090'+currentUser.avatarUrl.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading:CircleAvatar(radius: 15, backgroundImage: NetworkImage(imageUserUrl)),
          title: Text(currentUser?.username ?? 'Người dùng', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () => _showSheet(context, PostOptionsSheet(post: post)),
          ),
        ),
        if (imageUrl.isNotEmpty)
          Image.network(imageUrl, width: double.infinity, fit: BoxFit.fitWidth),
        _buildActionButtons(context, post),
        if (post.caption != null && post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(post.caption!, style: const TextStyle(color: Colors.white)),
          ),
        if (post.likeCount >= 0 && !post.hideLikeCount)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text('${post.likeCount} lượt thích', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        if (post.commentCount >= 0 && !post.disableComments)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text('Xem tất cả ${post.commentCount} bình luận', style: const TextStyle(color: Colors.grey)),
          ),
          
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, PostDetailUserDTO post) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
            post.isLikedByCurrentUser ? Icons.favorite : Icons.favorite_border, 
            color: post.isLikedByCurrentUser ? Colors.red : Colors.white,
          ), 
          onPressed: () => _toggleLike(post),
        ),
        if (!post.disableComments)
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () => _showSheet(context, CommentBottomSheet(post: post), isFull: true),
          ),
        IconButton(icon: const Icon(Icons.send_outlined, color: Colors.white), onPressed: () {}),
      ],
    );
  }

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
        await ApiService().post('/user/post/${post.id}/like', data: {});
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

  Future<void> _showSheet(BuildContext context, Widget sheet, {bool isFull = false}) async {
    final dynamic result = await showModalBottomSheet(
      context: context,
      isScrollControlled: isFull,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => sheet,
    );

    if (result != null && result is PostDetailUserDTO) {
      setState(() {
        final index = _detailedPosts.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _detailedPosts[index] = result;
        }
      });
    }
  }
}