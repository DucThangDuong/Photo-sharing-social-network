import 'package:flutter/material.dart';
import 'package:untitled/presentation/pages/view_story_user_page.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/DTOs/StoryDTO.dart';
import '../../data/datasources/DTOs/UserDTO.dart';
import '../../data/datasources/ApiServices.dart';
import '../../data/datasources/global/CallAPIOfUser.dart';
import '../../data/datasources/global/User.dart';
import '../../data/Helper.dart';
import '../widgets/guest_profile/ProfilePostGridGuest.dart';
import '../widgets/guest_profile/profile_header.dart';
import 'chat_detail_page.dart';

class GuestProfilePage extends StatefulWidget {
  final int userId;
  final bool initialIsFollowing;

  const GuestProfilePage({
    super.key,
    required this.userId,
    this.initialIsFollowing = false,
  });

  @override
  State<GuestProfilePage> createState() => _GuestProfilePageState();
}

class _GuestProfilePageState extends State<GuestProfilePage> {
  UserModelDTO? _user;
  UserStoryDTO? _userStory;
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isActionLoading = false;
  bool _hasStories = false;
  bool _isStorySeen = false;
  List<HighlightDTO> _highlights = [];

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initialIsFollowing;
    _fetchUserProfile();
  }

  // lấy thông tin người dùng muốn xem từ api
  Future<void> _fetchUserProfile() async {
    try {
      final response = await CallMyAPI.getUserProfileById(widget.userId);
      final isFollowUser = await CallMyAPI.isFollowUser(widget.userId);
      if (mounted) {
        final data = response['data'];
        if (data != null) {
          final loadedUser = UserModelDTO.fromJson(data);
          setState(() {
            _user = loadedUser;
            _isLoading = false;
            _isFollowing = isFollowUser['data'] as bool;
          });
          _fetchUserStories(loadedUser.id);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }
  //lấy danh sách story của người dùng từ api
  Future<void> _fetchUserStories(int userId) async {
    try {
      final activeStories = await CallMyAPI.getGuestStoryActive(userId);
      final userHighlights = await CallMyAPI.getUserHighlights(userId);
      
      if (mounted) {
        UserStoryDTO? currentUserStory;
        for (var story in activeStories) {
            currentUserStory = story;
            break;
        }
        setState(() {
          if (currentUserStory != null) {
            _hasStories = currentUserStory.stories.isNotEmpty;
            _userStory = currentUserStory;
            _isStorySeen = currentUserStory.hasSeen;
          }
          _highlights = userHighlights;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user stories: $e');
    }
  }

  void _viewHighlight(HighlightDTO highlight) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
    
    final highlightDetail = await CallMyAPI.getGuestHighlightDetails(highlight.id);
    if (mounted) Navigator.pop(context);

    if (highlightDetail == null || highlightDetail.stories.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tải điểm nhấn hoặc điểm nhấn rỗng')));
      }
      return;
    }

    if (_user == null) return;

    UserStoryDTO dummyUserStory = UserStoryDTO(
      userId: _user!.id,
      username: _user!.username,
      avatarUrl: _user!.avatarUrl,
      hasSeen: true,
      stories: highlightDetail.stories,
    );

    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoryViewPage(userStory: dummyUserStory, isGuestHighlight: true),
        ),
      );
    }
  }
  // me follow người dùng này
  Future<void> _toggleFollow() async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);

    try {
      await CallMyAPI.followUser(widget.userId);
      try {
        final profileRes = await CallMyAPI.getUserProfile();
        if (profileRes != null && profileRes['data'] != null) {
          final updatedUser = UserModelDTO.fromJson(profileRes['data']);
          if (mounted) {
            Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
          }
        }
      } catch (profileErr) {
        debugPrint('Error updating my profile info after follow: $profileErr');
      }

      setState(() {
        _isFollowing = !_isFollowing;
        _isActionLoading = false;
        if (_user != null) {
          int followersCount = _user!.followersNumber;
          followersCount = _isFollowing ? followersCount + 1 : followersCount - 1;

          _user = UserModelDTO(
            id: _user!.id,
            username: _user!.username,
            email: _user!.email,
            fullName: _user!.fullName,
            bio: _user!.bio,
            avatarUrl: _user!.avatarUrl,
            followersNumber: followersCount,
            followingsNumber: _user!.followingsNumber,
            postsNumber: _user!.postsNumber,
            gender: _user!.gender,
          );
        }
      });
    } catch (e) {
      debugPrint('Error toggling follow: $e');
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  bool _isChatLoading = false;

  Future<void> _openChat() async {
    if (_isChatLoading || _user == null) return;
    setState(() => _isChatLoading = true);

    try {
      final conversationId = await CallMyAPI.getOrCreateConversation(_user!.id);
      if (conversationId != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(
              conversationId: conversationId,
              otherUserName: _user!.username,
              otherUserAvatar: _user!.avatarUrl,
            ),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể tạo hoặc lấy phòng chat')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error opening chat: $e');
    } finally {
      if (mounted) setState(() => _isChatLoading = false);
    }
  }

  //các option để người dùng chọn xem story
  void _showAvatarOptions(BuildContext context) {
    if(_user==null) return;
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
                if (_hasStories && _userStory != null)
                  ListTile(
                    leading: const Icon(Icons.play_circle_outline, color: Colors.white),
                    title: const Text('Xem tin', style: TextStyle(color: Colors.white, fontSize: 16)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => StoryViewPage(userStory: _userStory!)),
                      );
                      _fetchUserStories(_user!.id);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                  title: const Text('Xem ảnh đại diện', style: TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (_user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                InteractiveViewer(
                                  child: Image.network(
                                    AppHelper.formatImageURL(_user!.avatarUrl!),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 40,
                                  right: 20,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Người dùng này chưa có ảnh đại diện')),
                      );
                    }
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white54),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, _isFollowing);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context, _isFollowing),
          ),
          title: Text(
            _user!.fullName ?? _user!.username,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
// Thông tin cơ bản
            ProfileHeaderGuest(
              user: _user!,
              hasStories: _hasStories,
              isStorySeen: _isStorySeen,
              onAvatarTap: () => _showAvatarOptions(context),
            ),

// Bio & Nút Follow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF262626),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alternate_email, color: Colors.white, size: 12),
                            Text(_user!.username, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(_user!.bio!, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _toggleFollow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _isFollowing ? const Color(0xFF262626) : const Color(0xFF4C68FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isActionLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    _isFollowing ? 'Hủy theo dõi' : 'Theo dõi',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: _openChat,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isChatLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Nhắn tin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            if (_highlights.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _highlights.map((highlight) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: GestureDetector(
                          onTap: () => _viewHighlight(highlight),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 1),
                                  image: highlight.coverUrl != null && highlight.coverUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(AppHelper.formatImageURL(highlight.coverUrl!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: (highlight.coverUrl == null || highlight.coverUrl!.isEmpty)
                                    ? const Icon(Icons.star, color: Colors.white, size: 30)
                                    : null,
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  highlight.title,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 10),

// Tabs bài viết của người dùng này
            const DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on, color: Colors.white))],
                  ),
                ],
              ),
            ),
            ProfilePostGridGuest(user: _user),
          ],
        ),
      ),
    ),
  );
}
}
