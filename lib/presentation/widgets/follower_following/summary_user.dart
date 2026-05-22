import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../pages/guest_profile_page.dart';
import '../../../data/datasources/DTOs/UserDTO.dart';
import '../../../data/datasources/ApiServices.dart';
import '../../../data/datasources/global/User.dart';
import '../../../data/Helper.dart';

class SummaryUser extends StatefulWidget {
  final SuggestedUserDTO user;
  final VoidCallback? onRemovePressed;
  final Function(bool isFollowing)? onFollowToggle;

  const SummaryUser({
    super.key,
    required this.user,
    this.onRemovePressed,
    this.onFollowToggle,
  });

  @override
  State<SummaryUser> createState() => _UserSuggestionTileState();
}

class _UserSuggestionTileState extends State<SummaryUser> {
  bool _isLoading = false;

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

    final bool isFollowing = widget.user.isFollowing;
    final int userId = widget.user.id;

    setState(() {
      _isLoading = true;
    });

    try {
      // Toggle follow API
      final response = await ApiService().post('/user/follow/$userId', data: {});
      final bool newFollowStatus = response['data']['isFollowed'] ?? !isFollowing;

      if (mounted) {
        widget.onFollowToggle?.call(newFollowStatus);
        await _updateUserProfile();
      }
    } catch (e) {
      if (mounted) {
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

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuestProfilePage(
              userId: widget.user.id,
              initialIsFollowing: widget.user.isFollowing,
            ),
          ),
        ).then((isFollowing) {
          if (isFollowing != null && isFollowing is bool && isFollowing != widget.user.isFollowing) {
            widget.onFollowToggle?.call(isFollowing);
          }
        });
      },
      child: Padding(
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
                  backgroundColor: widget.user.isFollowing ? Colors.grey[800] : const Color(0xFF4C68FF),
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
                        widget.user.isFollowing ? 'Hủy theo dõi' : 'Theo dõi',
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
      ),
    );
  }
}
