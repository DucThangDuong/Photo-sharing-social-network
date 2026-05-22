import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:untitled/data/datasources/global/CallAPIOfUser.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/global/User.dart';
import '../../../../../presentation/pages/new_post_page.dart';
import '../../../../../presentation/pages/guest_profile_page.dart';
import '../../../Profile/Presentation/Page/profile_page.dart';
import '../../../Auth/Presentation/Pages/login_page.dart';
import '../Widgets/post_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<HomePostDTO> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHomePosts();
  }
  // lấy danh sách feed từ api
  Future<void> _fetchHomePosts() async {
    try {
      final response = await CallMyAPI.getFeedsOfMe();
      if (mounted) {
        setState(() {
          _posts = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  // người dùng nhấn like bài viết, call api
  Future<void> _toggleLike(HomePostDTO post) async {
    final bool currentlyLiked = post.isLikedByCurrentUser;

    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post.copyWith(
          isLikedByCurrentUser: !currentlyLiked,
          likeCount: currentlyLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }
    });

    try {
      await ApiService().post('/post/${post.id}/like', data: {});
    } catch (e) {
      if (mounted) {
        setState(() {
          final index = _posts.indexWhere((p) => p.id == post.id);
          if (index != -1) {
            _posts[index] = post;
          }
        });
      }
    }
  }
  // đăng xuất tài khoản
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
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              handleLogout(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? const Center(child: Text('Chưa có bài viết nào', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _fetchHomePosts,
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, index) {
                      final post = _posts[index];
                      return PostItem(
                        post: post,
                        onPostUpdated: (updatedPost) {
                          setState(() {
                            final idx = _posts.indexWhere((p) => p.id == updatedPost.id);
                            if (idx != -1) {
                              _posts[idx] = updatedPost;
                            }
                          });
                        },
                        onLikeToggle: () => _toggleLike(post),
                        onUserTap: () {
                          final currentUser = context.read<UserProvider>().user;
                          if (currentUser != null && post.userId == currentUser.id) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfilePage()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GuestProfilePage(userId: post.userId)),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}