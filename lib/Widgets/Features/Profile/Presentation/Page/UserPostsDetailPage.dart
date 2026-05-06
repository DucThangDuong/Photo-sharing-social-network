import 'package:flutter/material.dart';
import '../widgets/comment_bottom_sheet.dart'; // Nhớ sửa đường dẫn import
import '../widgets/post_options_sheet.dart';

class UserPostsDetailPage extends StatelessWidget {
  final List<dynamic> posts;
  final int initialIndex;

  const UserPostsDetailPage({super.key, required this.posts, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController(
      initialScrollOffset: initialIndex * 600.0,
    );

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
      body: ListView.builder(
        controller: scrollController,
        itemCount: posts.length,
        itemBuilder: (context, index) => _buildPostItem(context, posts[index]),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, dynamic post) {
    String imageUrl = 'http://10.0.2.2:5090' + post['postMedia'][0]['mediaUrl'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(radius: 15, backgroundColor: Colors.grey),
          title: const Text('Tên người dùng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () => _showSheet(context, PostOptionsSheet(post: post)),
          ),
        ),
        Image.network(imageUrl, width: double.infinity, fit: BoxFit.fitWidth),
        _buildActionButtons(context, post),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(post['caption'] ?? '', style: const TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic post) {
    return Row(
      children: [
        IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          onPressed: () => _showSheet(context, CommentBottomSheet(post: post), isFull: true),
        ),
        IconButton(icon: const Icon(Icons.send_outlined, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  // Hàm dùng chung để hiện BottomSheet
  void _showSheet(BuildContext context, Widget sheet, {bool isFull = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isFull,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => sheet,
    );
  }
}