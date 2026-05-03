import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../data/Models/User.dart';
import '../../../../../../data/Models/mock_data.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../Widgets/discover_people.dart';
import '../Widgets/profile_header.dart';
import '../Widgets/profile_info.dart';
import '../Widgets/profile_post_grid.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
    //danh sách bạn bè gợi ý
    final List<User> suggestions = MockData.getSuggestedUsers();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            // Fix lỗi tràn pixel ở tiêu đề
            Expanded(
              child: Text(
                currentUser.username,
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
      body: SingleChildScrollView( //cuộn màn hình lên xuống thoi
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // lấy ảnh đại diện và thong tin của tai khoan hien tai (dữ liệu giả thoi)
            ProfileHeader(user: currentUser),

            // hiển thị tên, bio, nut bấm
            ProfileInfo(user: currentUser),

            // gợi ý kết bạn ::::00000000
            DiscoverPeople(suggestedUsers: suggestions),

            const SizedBox(height: 20),

            // tab bar hinh ảnh , reel, tag
            const DefaultTabController( //ddieuf kiển chuyển các tab
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
                  // Phần này thường dùng Sliver hoặc Fix height cho Grid
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