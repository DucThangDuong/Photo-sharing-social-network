import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/global/User.dart';
import '../widgets/follower/FollowerAppBar.dart';
import '../widgets/follower/EmptyFollowerState.dart';
import '../widgets/follower/UserSuggestionTile.dart';

class FollowersPage extends StatefulWidget {
  final int initialIndex;

  const FollowersPage({super.key, this.initialIndex = 0});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  final List<Map<String, String>> suggestedUsers = [
    {'name': 'Thành Tài', 'avatar': 'https://picsum.photos/id/1011/100/100'},
    {'name': 'vịu_ơ 💓', 'avatar': 'https://picsum.photos/id/1012/100/100'},
    {'name': 'Hoàng Đô', 'avatar': 'https://picsum.photos/id/1013/100/100'},
    {'name': 'Thuỳ Dương', 'avatar': 'https://picsum.photos/id/1014/100/100'},
    {'name': 'Gia Huy', 'avatar': 'https://picsum.photos/id/1015/100/100'},
    {'name': 'Võ Thị Thùy Linh', 'avatar': 'https://picsum.photos/id/1016/100/100'},
    {'name': 'Quỳnh Anh', 'avatar': 'https://picsum.photos/id/1018/100/100'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = context
        .watch<UserProvider>()
        .user;
    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: FollowerAppBar(user: currentUser),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicatorColor: Colors.white,
              indicatorWeight: 1.5,
              dividerColor: Colors.white12,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: currentUser.followersNumber.toString() +
                    ' người theo dõi'),
                Tab(text: currentUser.followingsNumber.toString() +
                    ' đang theo dõi'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFollowersTab(),
                  const Center(child: Text(
                      'Đang theo dõi', style: TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowersTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const EmptyFollowerState(),
          const SizedBox(height: 30),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: const Text(
                'Gợi ý cho bạn',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Danh sách người dùng
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: suggestedUsers.length,
            itemBuilder: (context, index) {
              final user = suggestedUsers[index];
              return UserSuggestionTile(
                name: user['name']!,
                avatarUrl: user['avatar']!,
                onFollowPressed: () {},
                onRemovePressed: () {},
              );
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}