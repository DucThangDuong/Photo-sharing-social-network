import 'package:flutter/material.dart';

import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import 'follower_following_guest.dart';

class ProfileHeaderGuest extends StatelessWidget {
  final UserModelDTO user;
  final VoidCallback? onAvatarTap;
  final bool hasStories;
  final bool isStorySeen;

  const ProfileHeaderGuest({
    super.key,
    required this.user,
    this.onAvatarTap,
    this.hasStories = false,
    this.isStorySeen = false,
  });
  Widget _buildStatItem(String count, String label, ) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    var imageUrl = 'http://10.0.2.2:5090'+user.avatarUrl.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: hasStories
                      ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: isStorySeen ? Colors.grey[700] : null,
                    gradient: isStorySeen
                        ? null
                        : const LinearGradient(
                      colors: [
                        Color(0xFFFEDA75),
                        Color(0xFFFA7E1E),
                        Color(0xFFD62976),
                        Color(0xFF962FBF),
                        Color(0xFF4F5BD5),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  )
                      : null,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF121212),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: user.avatarUrl != null ? NetworkImage(imageUrl) : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(user.postsNumber.toString(), 'bài viết'),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowPageGuest(initialIndex: 0, user: user,)),
                    );
                  },
                  child: _buildStatItem(user.followersNumber.toString(), 'người theo dõi'),
                ),
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FollowPageGuest(initialIndex: 1,user: user)),
                    );
                  },
                  child: _buildStatItem(user.followingsNumber.toString(), 'đang theo dõi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}