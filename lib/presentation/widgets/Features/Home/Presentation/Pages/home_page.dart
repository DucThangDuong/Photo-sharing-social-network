import 'package:flutter/material.dart';
import '../../../../../../data/Models/PostViewModel.dart';
import '../../../../../../data/Models/mock_data.dart';
import '../widgets/post_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu mẫu đã tạo
    final List<PostViewModel> posts = MockData.getPosts();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Instagram', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
        ],
      ),
      // ListView này sẽ cho phép bạn cuộn lên xuống thoải mái
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostItem(postData: posts[index]);
        },
      ),
    );
  }
}