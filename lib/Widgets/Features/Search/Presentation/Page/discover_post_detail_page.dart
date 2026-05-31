import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/Helper.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../data/datasources/global/User.dart';
import '../../../../../presentation/pages/guest_profile_page.dart';
import '../../../Profile/Presentation/Page/profile_page.dart';
import '../../../Home/Presentation/Widgets/post_likes_sheet.dart';

class DiscoverPostDetailPage extends StatefulWidget {
  final int postId;

  const DiscoverPostDetailPage({super.key, required this.postId});

  @override
  State<DiscoverPostDetailPage> createState() => _DiscoverPostDetailPageState();
}

class _DiscoverPostDetailPageState extends State<DiscoverPostDetailPage> {
  HomePostDTO? _post;
  List<CommentDTO> _comments = [];
  bool _isLoading = true;
  bool _isSendingComment = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPostDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

// lấy thông tin bài viết từ api
  Future<void> _fetchPostDetail() async {
    try {
      final response = await CallMyAPI.getPostDetail(widget.postId);
      debugPrint('DEBUG FETCH POST DETAIL: $response');
      if (response != null) {
        if (mounted) {
          setState(() {
            dynamic postData;
            if (response is Map<String, dynamic> &&
                response.containsKey('data')) {
              postData = response['data'];
            } else {
              postData = response;
            }

            if (postData == null) {
              _post = null;
            } else if (postData is List) {
              final match = postData.firstWhere(
                    (element) =>
                element is Map<String, dynamic> &&
                    element['id'] == widget.postId,
                orElse: () => postData.isNotEmpty ? postData[0] : null,
              );
              if (match != null && match is Map<String, dynamic>) {
                _post = HomePostDTO.fromJson(match);
              }
            } else if (postData is Map<String, dynamic>) {
              _post = HomePostDTO.fromJson(postData);
            }
          });

          if (_post != null) {
            _fetchComments();
          } else {
            _isLoading = false;
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải chi tiết bài viết: $e')),
        );
      }
    }
  }

// lấy comments
  Future<void> _fetchComments() async {
    try {
      final response = await CallMyAPI.getComments(widget.postId);
      if (mounted) {
        setState(() {
          _comments = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching comments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

// tương tác
  Future<void> _toggleLike() async {
    if (_post == null) return;
    final bool currentlyLiked = _post!.isLikedByCurrentUser;

    setState(() {
      _post = _post!.copyWith(
        isLikedByCurrentUser: !currentlyLiked,
        likeCount: currentlyLiked ? _post!.likeCount - 1 : _post!.likeCount + 1,
      );
    });

    try {
      await CallMyAPI.toggleLikePost(_post!.id);
    } catch (e) {
      debugPrint('Error toggling like: $e');
      if (mounted) {
        setState(() {
          _post = _post!.copyWith(
            isLikedByCurrentUser: currentlyLiked,
            likeCount: currentlyLiked ? _post!.likeCount + 1 : _post!
                .likeCount - 1,
          );
        });
      }
    }
  }

// gửi comment lên api
  Future<void> _sendComment() async {
    if (_post == null) return;
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSendingComment) return;

    setState(() => _isSendingComment = true);

    try {
      final response = await CallMyAPI.sendComment(_post!.id, content);

      if (mounted && response != null && response['data'] != null) {
        final newComment = CommentDTO.fromJson(response['data']);
        setState(() {
          _comments.insert(0, newComment);
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi bình luận: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingComment = false);
    }
  }

  void _goToUserProfile(int userId) {
    final currentUser = context
        .read<UserProvider>()
        .user;
    if (currentUser != null && userId == currentUser.id) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GuestProfilePage(userId: userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }

    if (_post == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('Bài viết', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text(
            'Không tìm thấy bài viết', style: TextStyle(color: Colors.grey))),
      );
    }

    String imageUrl = _post!.postMedia.isNotEmpty
        ? AppHelper.formatImageURL(_post!.postMedia[0].mediaUrl)
        : '';
    String userAvatar = _post!.avatarUrl != null && _post!.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(_post!.avatarUrl!)
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Chi tiết bài viết',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    leading: GestureDetector(
                      onTap: () => _goToUserProfile(_post!.userId),
                      child: userAvatar.isNotEmpty
                          ? CircleAvatar(
                          radius: 18, backgroundImage: NetworkImage(userAvatar))
                          : const CircleAvatar(radius: 18,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.person, color: Colors.white)),
                    ),
                    title: GestureDetector(
                      onTap: () => _goToUserProfile(_post!.userId),
                      child: Text(
                        _post!.username,
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                    trailing: const Icon(Icons.more_horiz, color: Colors.white),
                  ),

                  // Hình ảnh bài viết
                  if (imageUrl.isNotEmpty)
                    Image.network(
                        imageUrl, width: double.infinity, fit: BoxFit.fitWidth),

                  // Thanh tương tác (Like, Comment, Send, Bookmark)
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _post!.isLikedByCurrentUser ? Icons.favorite : Icons
                              .favorite_border,
                          color: _post!.isLikedByCurrentUser
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: _toggleLike,
                      ),
                      if (!_post!.disableComments)
                        IconButton(
                          icon: const Icon(
                              Icons.chat_bubble_outline, color: Colors.white),
                          onPressed: () {},
                        ),
                      const Spacer(),
                    ],
                  ),

                  // Số lượt thích
                  if (_post!.likeCount >= 0 && !_post!.hideLikeCount)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => PostLikesSheet(postId: _post!.id),
                          );
                        },
                        child: Text('${_post!.likeCount} lượt thích',
                            style: const TextStyle(color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),

                  // Caption
                  if (_post!.caption != null && _post!.caption!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white),
                          children: [
                            TextSpan(text: _post!.caption!),
                          ],
                        ),
                      ),
                    ),

                  // Ngày đăng
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    child: Text(
                      '${_post!.createdAt.day}/${_post!.createdAt
                          .month}/${_post!.createdAt.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  const Divider(color: Colors.white12, height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    child: Text(
                      'Bình luận (${_comments.length})',
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),

                  if (_comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14, vertical: 20),
                      child: Text('Chưa có bình luận nào',
                          style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        String commentAvatar = comment.avatarUrl != null &&
                            comment.avatarUrl!.isNotEmpty
                            ? AppHelper.formatImageURL(comment.avatarUrl!)
                            : '';
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          leading: GestureDetector(
                            onTap: () => _goToUserProfile(comment.userId),
                            child: commentAvatar.isNotEmpty
                                ? CircleAvatar(radius: 16,
                                backgroundImage: NetworkImage(commentAvatar))
                                : const CircleAvatar(radius: 16,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white,
                                    size: 16)),
                          ),
                          title: GestureDetector(
                            onTap: () => _goToUserProfile(comment.userId),
                            child: Text(comment.username,
                                style: const TextStyle(color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(comment.content, style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                '${comment.createdAt.day}/${comment.createdAt
                                    .month}/${comment.createdAt.year} ${comment
                                    .createdAt.hour}:${comment.createdAt.minute
                                    .toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.favorite_border, size: 16,
                              color: Colors.grey),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          if (!_post!.disableComments)
            _buildInputArea(context)
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFF1E1E1E),
              alignment: Alignment.center,
              child: const Text(
                'Tính năng bình luận đã bị tắt cho bài viết này.',
                style: TextStyle(color: Colors.grey,
                    fontSize: 13,
                    fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    final currentUser = context
        .watch<UserProvider>()
        .user;
    String myAvatar = '';
    if (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty) {
      myAvatar = AppHelper.formatImageURL(currentUser.avatarUrl!);
    }

    return Container(
      color: const Color(0xFF1E1E1E),
      padding: EdgeInsets.only(bottom: MediaQuery
          .of(context)
          .viewInsets
          .bottom + 10, left: 15, right: 15, top: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            backgroundImage: myAvatar.isNotEmpty
                ? NetworkImage(myAvatar)
                : null,
            child: myAvatar.isEmpty ? const Icon(
                Icons.person, color: Colors.white, size: 18) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Thêm bình luận...',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          _isSendingComment
              ? const SizedBox(width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton(
            onPressed: _sendComment,
            child: const Text('Đăng', style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
