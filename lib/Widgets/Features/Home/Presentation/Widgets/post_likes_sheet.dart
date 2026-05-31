import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../data/Helper.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../../data/datasources/global/CallAPIOfUser.dart';
import '../../../../../../data/datasources/global/User.dart';
import '../../../../../presentation/pages/guest_profile_page.dart';

class PostLikesSheet extends StatefulWidget {
  final int postId;

  const PostLikesSheet({super.key, required this.postId});

  @override
  State<PostLikesSheet> createState() => _PostLikesSheetState();
}

class _PostLikesSheetState extends State<PostLikesSheet> {
  bool _isLoading = true;
  List<SuggestedUserDTO> _likedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchLikes();
  }

  Future<void> _fetchLikes() async {
    final users = await CallMyAPI.getPostLikes(widget.postId);
    if (mounted) {
      setState(() {
        _likedUsers = users;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow(SuggestedUserDTO user, int index) async {
    // Optimistic UI update
    final wasFollowing = user.isFollowing;
    setState(() {
      _likedUsers[index] = user.copyWith(isFollowing: !wasFollowing);
    });

    final success = await CallMyAPI.followUser(user.id);
    if (success == null) {
      // Revert if API failed
      if (mounted) {
        setState(() {
          _likedUsers[index] = user.copyWith(isFollowing: wasFollowing);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại sau')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<UserProvider>().user?.id;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Lượt thích',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(color: Colors.white24, height: 24),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white54),
                  )
                : _likedUsers.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có lượt thích nào.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _likedUsers.length,
                        itemBuilder: (context, index) {
                          final user = _likedUsers[index];
                          final isMe = user.id == currentUserId;
                          final avatarUrl = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                              ? AppHelper.formatImageURL(user.avatarUrl!)
                              : '';

                          return ListTile(
                            onTap: () {
                              Navigator.pop(context); // Close sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GuestProfilePage(userId: user.id),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                              child: avatarUrl.isEmpty
                                  ? const Icon(Icons.person, color: Colors.white, size: 28)
                                  : null,
                            ),
                            title: Text(
                              user.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: user.fullName != null && user.fullName!.isNotEmpty
                                ? Text(
                                    user.fullName!,
                                    style: const TextStyle(color: Colors.white54),
                                  )
                                : null,
                            trailing: isMe
                                ? null
                                : SizedBox(
                                    height: 32,
                                    child: ElevatedButton(
                                      onPressed: () => _toggleFollow(user, index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: user.isFollowing
                                            ? Colors.grey[800]
                                            : Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: Text(
                                        user.isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
