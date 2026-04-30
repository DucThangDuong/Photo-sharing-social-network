import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/Models/PostViewModel.dart';
import '../../../../../../data/Models/mock_data.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../../../pages/newPost.dart';
import '../../../Auth/Presentation/Pages/login_page.dart';
import '../widgets/post_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
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
  @override
  Widget build(BuildContext context) {
    final List<PostViewModel> posts = MockData.getPosts();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Instagram',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewPostScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            onPressed: () {},
          ),
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
          // 2. CẬP NHẬT: Truyền tham số postData cho PostItem
          return PostItem(postData: posts[index]);
        },
      ),
    );
  }
}