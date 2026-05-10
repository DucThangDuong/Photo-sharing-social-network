import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/DTOs/StoryDTO.dart';
import '../Widgets/profile_header.dart';
import '../Widgets/profile_info.dart';
import '../Widgets/profile_post_grid.dart';
import '../../../../../../presentation/pages/NewStory.dart';
import '../../../../../../presentation/pages/StoryViewPage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasStories = false;
  UserStoryDTO? _userStory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<UserProvider>().user;
      if (currentUser != null) {
        _fetchUserStories(currentUser.id);
      }
    });
  }

  Future<void> _fetchUserStories(int userId) async {
    try {
      final response = await ApiService().get('/story/active');
      if (mounted) {
        final data = response['data'];
        if (data != null && data is List) {
          // Lấy danh sách story của chính current user từ active stories
          var currentUserStories = data.firstWhere((element) => element['userId'] == userId, orElse: () => null);
          if (currentUserStories != null) {
            UserStoryDTO userStory = UserStoryDTO.fromJson(currentUserStories);
            setState(() {
              _hasStories = userStory.stories.isNotEmpty;
              _userStory = userStory;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
    }
  }

  void _showAvatarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_outline, color: Colors.white),
                  title: const Text('Thêm tin mới', style: TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoryUploadPage()),
                    );
                  },
                ),
                if (_hasStories && _userStory != null)
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline, color: Colors.white),
                    title: const Text('Xem tin', style: TextStyle(color: Colors.white, fontSize: 16)),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StoryViewPage(userStory: _userStory!)),
                      );
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  title: const Text('Xem ảnh đại diện', style: TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<UserProvider>().user;
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            Expanded(
              child: Text(
                currentUser.fullName ?? currentUser.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // lấy thông tin cơ bản
            ProfileHeader(
              user: currentUser,
              onAvatarTap: () => _showAvatarOptions(context),
              hasStories: _hasStories,
            ),
            // các button chỉnh sửa, chia sẻ trang cá nhân, thêm bạn
            ProfileInfo(user: currentUser),
            const SizedBox(height: 20),

            // tab bar hinh ảnh , reel, tag
            const DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.video_library_outlined)),
                      Tab(icon: Icon(Icons.assignment_ind_outlined)),
                    ],
                  ),
                  // các bài viết của người dùng
                  ProfilePostGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}