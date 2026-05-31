import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/global/User.dart';
import '../../../../../data/Helper.dart';

class EditPostPage extends StatefulWidget {
  final PostDetailUserDTO post;
  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _captionController;
  bool _isLoading = false;
  bool _isCaptionChanged = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController(text: widget.post.caption);
    _captionController.addListener(_onCaptionChanged);
  }

  @override
  void dispose() {
    _captionController.removeListener(_onCaptionChanged);
    _captionController.dispose();
    super.dispose();
  }

  void _onCaptionChanged() {
    final changed = _captionController.text != (widget.post.caption ?? '');
    if (changed != _isCaptionChanged) {
      setState(() {
        _isCaptionChanged = changed;
      });
    }
  }

  //  cập nhật chỉnh sửa lên api
  Future<void> _handleUpdate() async {
    setState(() => _isLoading = true);
    try {
      final response = await CallMyAPI.updatePostCaption(
        widget.post.id,
        {'Caption': _captionController.text.trim()},
      );

      if (mounted && response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thành công')));
        final String newCaption = _captionController.text.trim();
        PostDetailUserDTO updatedPost = widget.post.copyWith(caption: newCaption);
        Navigator.pop(context, updatedPost);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.post.postMedia.isNotEmpty
        ? 'http://10.0.2.2:5090' + widget.post.postMedia[0].mediaUrl
        : '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Chỉnh sửa bài viết',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isCaptionChanged)
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                      ),
                    ),
                  )
                : TextButton(
                    onPressed: _handleUpdate,
                    child: const Text(
                      'Xong',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final currentUser = userProvider.user;
                final avatarUrl = currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty
                    ? AppHelper.formatImageURL(currentUser.avatarUrl!)
                    : 'https://i.pravatar.cc/150';
                final username = currentUser?.username ?? 'Người dùng';

                return ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                color: Colors.grey[900],
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              ),
            ),

            // 3. Ô nhập chú thích
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: TextField(
                controller: _captionController,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Viết chú thích...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}