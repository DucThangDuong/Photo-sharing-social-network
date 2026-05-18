import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/data/Helper.dart';
import 'package:untitled/presentation/widgets/guest_profile/user_post_detail_page_guest.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../../data/datasources/DTOs/UserDTO.dart';
import '../../../../../data/datasources/global/CallAPIOfUser.dart';

class ProfilePostGridGuest extends StatefulWidget {
  final UserModelDTO? user;
  const ProfilePostGridGuest({super.key, this.user});

  @override
  State<ProfilePostGridGuest> createState() => _ProfilePostGridState();
}

class _ProfilePostGridState extends State<ProfilePostGridGuest> {
  List<PostSummaryDTO> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _fetchPosts();
    }
  }
  // lấy danh sách bài viết của người dùng này
  Future<void> _fetchPosts() async {
    try {
      if (widget.user == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      final List<PostSummaryDTO> response = await CallMyAPI.getPostsSummary(widget.user!.id);

      if (mounted) {
        setState(() {
          posts = response;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải bài viết: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(50.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(50.0),
        child: Center(
          child: Text('Chưa có bài viết nào', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final mediaList = post.postMedia;
        String imageUrl = '';
        if (mediaList.isNotEmpty) {
          imageUrl = AppHelper.formatImageURL(mediaList[0].mediaUrl);
        }

        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPostsDetailPageGuest(
                  initialIndex: index,
                  user: widget.user,
                ),
              ),
            );
            _fetchPosts();
          },
          child: Container(
            color: Colors.grey[900],
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        );
      },
    );
  }
}