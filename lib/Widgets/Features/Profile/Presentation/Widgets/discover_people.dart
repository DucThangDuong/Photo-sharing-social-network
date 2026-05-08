import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../data/Helper.dart';
import '../../../../../data/datasources/ApiServices.dart';
import '../../../../../data/datasources/global/User.dart';

class DiscoverPeople extends StatefulWidget {
  final List<SuggestedUserDTO> suggestedUsers;
  const DiscoverPeople({super.key, required this.suggestedUsers});

  @override
  State<DiscoverPeople> createState() => _DiscoverPeopleState();
}

class _DiscoverPeopleState extends State<DiscoverPeople> {
  late List<SuggestedUserDTO> _users;

  @override
  void initState() {
    super.initState();
    _users = List.from(widget.suggestedUsers);
  }

  // khi người dùng tương tác người dùng
  Future<void> _updateUserProfile() async {
    try {
      final response = await ApiService().get('/user/profile');
      if (mounted) {
        final updatedUser = UserModelDTO.fromJson(response['data']);
        Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
      }
    } catch (e) {
      debugPrint("Error updating user profile: $e");
    }
  }

  Future<void> _toggleFollow(SuggestedUserDTO user, int index) async {
    final bool isFollowing = user.isFollowing;
    final int userId = user.id;

    setState(() {
      _users[index] = user.copyWith(isFollowing: !isFollowing);
    });

    try {
      if (isFollowing) {
        await ApiService().post('/user/follow/$userId', data: {});
      } else {
        await ApiService().post('/user/follow/$userId', data: {});
      }
      
      await _updateUserProfile();
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _users[index] = user;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_users.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text('Khám phá mọi người', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 15),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return _buildSuggestCard(user, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestCard(SuggestedUserDTO user, int index) {
    String avatarUrl = user.avatarUrl != null && user.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(user.avatarUrl!)
        : '';

    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[800],
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
          ),
          const SizedBox(height: 10),
          Text(user.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isFollowing ? Colors.grey[800] : const Color(0xFF0064E0),
              minimumSize: const Size(double.infinity, 30),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            onPressed: () => _toggleFollow(user, index),
            child: Text(
              user.isFollowing ? 'Hủy follow' : 'Theo dõi',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}