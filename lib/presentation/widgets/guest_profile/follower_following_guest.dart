import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/presentation/widgets/guest_profile/summary_user_guest.dart';

import '../../../data/Helper.dart';
import '../../../data/datasources/ApiServices.dart';
import '../../../data/datasources/DTOs/UserDTO.dart';
import '../../../data/datasources/global/User.dart';
import '../../pages/guest_profile_page.dart';
import '../follower_following/follower_following_AppBar.dart';
import '../follower_following/is_empty_follower.dart';
import '../follower_following/summary_user.dart';

class FollowPageGuest extends StatefulWidget {
  final UserModelDTO user;
  final int initialIndex;
  const FollowPageGuest({super.key, this.initialIndex = 0, required this.user});
  @override
  State<FollowPageGuest> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowPageGuest> {
  List<SummaryUserDTO> _followers = [];
  List<SuggestedUserDTO> _followings = [];
  bool _isLoadingFollowers = true;
  bool _isLoadingFollowings = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user != null) {
        _fetchFollowers(widget.user.id);
        _fetchFollowings(widget.user.id);
      }
    });
  }

  // Lấy danh sách người theo dõi của người dùng này
  Future<void> _fetchFollowers(int userId) async {
    try {
      final response = await ApiService().get('/user/$userId/followers');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _followers = rawList.map((i) => SummaryUserDTO.fromJson(i)).toList();
          _isLoadingFollowers = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching followers: $e');
      if (mounted) setState(() => _isLoadingFollowers = false);
    }
  }

  // Lấy danh sách người dùng này theo dõi
  Future<void> _fetchFollowings(int userId) async {
    try {
      final response = await ApiService().get('/user/$userId/following');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _followings =
              rawList.map((i) => SuggestedUserDTO.fromJson(i)).toList();
          _isLoadingFollowings = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching followings: $e');
      if (mounted) setState(() => _isLoadingFollowings = false);
    }
  }

  // Xử lý khi nhấn Follow/Unfollow từ bất kỳ widget nào
  void _handleFollowToggle(SuggestedUserDTO user, bool isFollowing) {
    setState(() {
      int followingIndex = _followings.indexWhere((u) => u.id == user.id);
      if (isFollowing) {
        if (followingIndex == -1) {
          _followings.insert(0, user.copyWith(isFollowing: true));
        } else {
          _followings[followingIndex] = _followings[followingIndex].copyWith(isFollowing: true);
        }
      } else {
        if (followingIndex != -1) {
          _followings[followingIndex] = _followings[followingIndex].copyWith(isFollowing: false);
        }
      }
    });
  }
  // widget component hiển thị thông tin người dùng summary
  Widget _buildUserTile(SummaryUserDTO user) {
    String avatarUrl = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(user.avatarUrl!)
        : '';
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestProfilePage(
              userId: user.id,
              initialIsFollowing: true,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[800],
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (user.fullName != null && user.fullName!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      user.fullName!,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget hiện người dùng này theo dõi ai
  Widget _buildFollowersTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_isLoadingFollowers)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(child: CircularProgressIndicator(color: Colors.white54)),
            )
          else if (_followers.isEmpty) ...[
            const SizedBox(height: 40),
            const EmptyFollowerState(),
          ] else
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _followers.length,
              itemBuilder: (context, index) {
                return _buildUserTile(_followers[index]);
              },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // widget hiện người dùng này đang theo dõi
  Widget _buildFollowingsTab() {
    if (_isLoadingFollowings) {
      return const Center(child: CircularProgressIndicator(color: Colors.white54));
    }
    if (_followings.isEmpty) {
      return const Center(
        child: Text('Người dùng này chưa theo dõi ai', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    return ListView.builder(
      itemCount: _followings.length,
      itemBuilder: (context, index) {
        final user = _followings[index];
        return SummaryUserGuest(
          user: user,
          onFollowToggle: (isFollowing) => _handleFollowToggle(user, isFollowing),
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
              labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: '${widget.user.followersNumber} người theo dõi'),
                Tab(text: '${widget.user.followingsNumber} đang theo dõi'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFollowersTab(),
                  _buildFollowingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
