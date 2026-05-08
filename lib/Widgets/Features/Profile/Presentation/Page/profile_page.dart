import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../../../../data/datasources/ApiServices.dart';
import '../Widgets/discover_people.dart';
import '../Widgets/profile_header.dart';
import '../Widgets/profile_info.dart';
import '../Widgets/profile_post_grid.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<SuggestedUserDTO> _suggestions = [];
  bool _isLoadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    try {
      // Gọi API lấy danh sách bạn bè gợi ý
      final response = await ApiService().get('/user/suggestions');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _suggestions = rawList.map((i) => SuggestedUserDTO.fromJson(i)).toList();
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSuggestions = false);
      }
    }
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
            ProfileHeader(user: currentUser),
            // các button chỉnh sửa, chia sẻ trang cá nhân, thêm bạn
            ProfileInfo(user: currentUser),
            // danh sách bạn bè gợi ý
            _isLoadingSuggestions 
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                : DiscoverPeople(suggestedUsers: _suggestions),

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