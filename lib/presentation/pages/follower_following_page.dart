import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/DTOs/UserDTO.dart';
import '../../data/datasources/ApiServices.dart';
import '../../data/datasources/global/User.dart';
import '../../data/Helper.dart';
import '../widgets/follower_following/follower_following_AppBar.dart';
import '../widgets/follower_following/is_empty_follower.dart';
import '../widgets/follower_following/summary_user.dart';
import 'guest_profile_page.dart';

class FollowersPage extends StatefulWidget {
  final int initialIndex;
  const FollowersPage({super.key, this.initialIndex = 0});
  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  List<SummaryUserDTO> _followers = [];
  List<SuggestedUserDTO> _followings = [];
  List<SuggestedUserDTO> _suggestions = [];
  bool _isLoadingFollowers = true;
  bool _isLoadingFollowings = true;
  bool _isLoadingSuggestions = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context
          .read<UserProvider>()
          .user;
      if (currentUser != null) {
        _fetchFollowers(currentUser.id);
        _fetchFollowings(currentUser.id);
        _fetchSuggestions();
      }
    });
  }

  // Lấy danh sách người theo dõi mình
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

  // Lấy danh sách người mình đang theo dõi
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

  // Lấy danh sách user gợi ý cho người dùng
  Future<void> _fetchSuggestions() async {
    try {
      final response = await ApiService().get('/user/suggestions');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          _suggestions =
              rawList.map((i) => SuggestedUserDTO.fromJson(i)).toList();
          _isLoadingSuggestions = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  // Xử lý khi nhấn Follow/Unfollow từ bất kỳ widget nào
  void _handleFollowToggle(SuggestedUserDTO user, bool isFollowing) {
    setState(() {
      int suggestIndex = _suggestions.indexWhere((u) => u.id == user.id);
      if (suggestIndex != -1) {
        _suggestions[suggestIndex] = _suggestions[suggestIndex].copyWith(isFollowing: isFollowing);
      }

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
        ).then((_) {
          final currentUser = context.read<UserProvider>().user;
          if (currentUser != null) {
            _fetchFollowers(currentUser.id);
            _fetchFollowings(currentUser.id);
            _fetchSuggestions();
          }
        });
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

  // widget hiện người theo dõi mình
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

          if (!_isLoadingSuggestions && _suggestions.isNotEmpty) ...[
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: Text(
                  'Gợi ý cho bạn',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final user = _suggestions[index];
                return SummaryUser(
                  user: user,
                  onFollowToggle: (isFollowing) => _handleFollowToggle(user, isFollowing),
                  onRemovePressed: () {
                    setState(() {
                      _suggestions.removeAt(index);
                    });
                  },
                );
              },
            ),
          ],

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // widget hiện người mình đang theo dõi
  Widget _buildFollowingsTab() {
    if (_isLoadingFollowings) {
      return const Center(child: CircularProgressIndicator(color: Colors.white54));
    }
    if (_followings.isEmpty) {
      return const Center(
        child: Text('Bạn chưa theo dõi ai', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }
    return ListView.builder(
      itemCount: _followings.length,
      itemBuilder: (context, index) {
        final user = _followings[index];
        return SummaryUser(
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
                Tab(text: '${currentUser.followersNumber} người theo dõi'),
                Tab(text: '${currentUser.followingsNumber} đang theo dõi'),
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
