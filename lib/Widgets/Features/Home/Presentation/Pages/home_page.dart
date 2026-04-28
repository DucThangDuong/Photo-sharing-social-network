import 'package:flutter/material.dart';
import '../../../../../presentation/pages/newPost.dart';
import '../../Models/mock_data.dart';
import '../../Models/post_model.dart';
import '../widgets/post_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu mẫu đã tạo
    final List<PostModel> posts = MockData.getPosts();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Instagram',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NewPostScreen()),
            );
          }),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.chat_bubble_outline), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return PostItem(post: posts[index]);
        },
      ),
    );
  }
}