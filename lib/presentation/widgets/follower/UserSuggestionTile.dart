import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/datasources/DTOs/UserDTO.dart';
import '../../../data/datasources/ApiServices.dart';
import '../../../data/datasources/global/User.dart';
import '../../../data/Helper.dart';

class UserSuggestionTile extends StatefulWidget {
  final SuggestedUserDTO user;
  final VoidCallback? onRemovePressed;

  const UserSuggestionTile({
    super.key,
    required this.user,
    this.onRemovePressed,
  });

  @override
  State<UserSuggestionTile> createState() => _UserSuggestionTileState();
}

class _UserSuggestionTileState extends State<UserSuggestionTile> {
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.user.isFollowing;
    print('UserSuggestionTile initState: isFollowing = $_isFollowing');
  }

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

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    final bool wasFollowing = _isFollowing;
    final int userId = widget.user.id;

    setState(() {
      _isFollowing = !wasFollowing;
      _isLoading = true;
    });

    try {
      if (wasFollowing) {
        await ApiService().post('/user/follow/$userId', data: {});
      } else {
        await ApiService().post('/user/follow/$userId', data: {});
      }
      await _updateUserProfile();
    } catch (e) {
      if (mounted) {
        setState(() => _isFollowing = wasFollowing);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String avatarUrl = widget.user.avatarUrl != null && widget.user.avatarUrl!.isNotEmpty
        ? AppHelper.formatImageURL(widget.user.avatarUrl!)
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey[800],
            backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
            child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 28) : null,
          ),
          const SizedBox(width: 12),

          // Tên và mô tả
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.username,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.user.fullName != null && widget.user.fullName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.user.fullName!,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Nút Theo dõi / Đang theo dõi
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey[800] : const Color(0xFF4C68FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      _isFollowing ? 'Hủy theo dõi' : 'Theo dõi',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          // Nút Xóa
          if (widget.onRemovePressed != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onRemovePressed,
              child: const Icon(Icons.close, color: Colors.grey, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
