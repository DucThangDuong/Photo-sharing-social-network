import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasources/global/User.dart';
import '../../../../../presentation/pages/newPost.dart';
import '../../../Auth/Presentation/Pages/login_page.dart';
import '../../Models/mock_data.dart';
import '../../Models/post_model.dart';
import '../widgets/post_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu mẫu đã tạo
    final List<PostModel> posts = MockData.getPosts();
    Future<void> handleLogout(BuildContext context) async {
      try {
        const storage = FlutterSecureStorage();
        await storage.delete(key: 'access_token');
        if (context.mounted) {
          Provider.of<UserProvider>(context, listen: false).clearUser();
        }
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => InstagramLoginDark()),
                (route) => false,
          );
        }
      } catch (e) {
        print("Lỗi khi đăng xuất: $e");
      }
    }
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
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              handleLogout(context);
            },
          ),
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