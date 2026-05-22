import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../../../data/datasources/DTOs/StoryDTO.dart';
import '../../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../presentation/pages/new_post_page.dart';
import '../Widgets/profile_header.dart';
import '../Widgets/profile_info.dart';
import '../Widgets/profile_post_grid.dart';
import '../Widgets/profile_liked_post_grid.dart';
import '../Widgets/profile_archived_post_grid.dart';
import '../../../../../../presentation/pages/new_story_page.dart';
import '../../../../../../presentation/pages/view_story_user_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasStories = false;
  UserStoryDTO? _userStory;
  int _selectedTabIndex = 0;

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
  //lấy danh sách story của người dùng từ api
  Future<void> _fetchUserStories(int userId) async {
    try {
      final activeStories = await CallMyAPI.getMyStoryActive();
      if (mounted) {
        UserStoryDTO? currentUserStory;
        for (var story in activeStories) {
          if (story.userId == userId) {
            currentUserStory = story;
            break;
          }
        }
        if (currentUserStory != null) {
          setState(() {
            _hasStories = currentUserStory!.stories.isNotEmpty;
            _userStory = currentUserStory;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
    }
  }
  //các option để người dùng chọn xem có new story, xem story
  void _showAvatarOptions(BuildContext context) {
    final currentUser = context.read<UserProvider>().user;
    if (currentUser == null) return;

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
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoryUploadPage()),
                    );
                    _fetchUserStories(currentUser.id);
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
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NewPostScreen()),
            );
          }),
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

// tab bar hinh ảnh , like, lưu trữ
            DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    onTap: (index) {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.favorite_border)),
                      Tab(icon: Icon(Icons.bookmark_border)),
                    ],
                  ),
// nội dung các tab
                  if (_selectedTabIndex == 0)
                    ProfilePostGrid(
                      key: ValueKey(currentUser.postsNumber),
                      user: currentUser,
                    )
                  else if (_selectedTabIndex == 1)
                    ProfileLikedPostGrid(
                      user: currentUser,
                    )
                  else
                    ProfileArchivedPostGrid(
                      user: currentUser,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}