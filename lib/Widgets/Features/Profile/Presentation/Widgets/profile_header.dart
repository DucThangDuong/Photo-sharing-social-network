import 'package:flutter/material.dart';

import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../presentation/pages/follower.dart';

class ProfileHeader extends StatelessWidget {
  final UserModelDTO user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    var imageUrl = 'http://10.0.2.2:5090'+user.avatarUrl.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.grey[800],
                backgroundImage: user.avatarUrl != null ? NetworkImage(imageUrl) : null,
              ),
              // bong ghi chu
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.black, width: 1),
                  ),
                  child: const Text(
                    'Đang mê mẩn...',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(user.postsNumber.toString(), 'bài viết'),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FollowersPage(initialIndex: 0)),
                    );
                  },
                  child: _buildStatItem(user.followersNumber.toString(), 'người theo dõi'),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FollowersPage(initialIndex: 1)),
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

  Widget _buildStatItem(String count, String label, ) {
    return Column(
      children: [
        Text(count, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }
}