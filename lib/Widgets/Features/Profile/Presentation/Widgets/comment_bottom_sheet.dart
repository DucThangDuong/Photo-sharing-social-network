import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/DTOs/PostDTO.dart';
import 'package:untitled/data/datasources/ApiServices.dart';

class CommentBottomSheet extends StatefulWidget {
  final PostDetailUserDTO post;
  const CommentBottomSheet({super.key, required this.post});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  List<CommentDTO> _comments = [];
  bool _isLoading = true;
  bool _isSending = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchComments() async {
    try {
      final response = await ApiService().get('/post/${widget.post.id}/comments');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _comments = rawList.map((i) => CommentDTO.fromJson(i)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final response = await ApiService().post(
        '/post/${widget.post.id}/comment',
        data: {'Content': content},
      );

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
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text('Bình luận', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text('Chưa có bình luận nào', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          String avatar = '';
                          if (comment.avatarUrl != null && comment.avatarUrl!.isNotEmpty) {
                            avatar = 'http://10.0.2.2:5090${comment.avatarUrl}';
                            if (avatar.contains('localhost')) {
                              avatar = avatar.replaceAll('localhost', '10.0.2.2');
                            }
                          }
                          return ListTile(
                            leading: avatar.isNotEmpty
                                ? CircleAvatar(radius: 16, backgroundImage: NetworkImage(avatar))
                                : const CircleAvatar(radius: 16, backgroundColor: Colors.grey),
                            title: Text(comment.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.content, style: const TextStyle(color: Colors.white, fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(
                                  '${comment.createdAt.day}/${comment.createdAt.month}/${comment.createdAt.year} ${comment.createdAt.hour}:${comment.createdAt.minute.toString().padLeft(2, '0')}', 
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                          );
                        },
                      ),
          ),
          _buildInputArea(context),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 15, right: 15, top: 10),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.grey),
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
          _isSending
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : TextButton(
                  onPressed: _sendComment, 
                  child: const Text('Đăng', style: TextStyle(color: Colors.blue)),
                ),
        ],
      ),
    );
  }
}