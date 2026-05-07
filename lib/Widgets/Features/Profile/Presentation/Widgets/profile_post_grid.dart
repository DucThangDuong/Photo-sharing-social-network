import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../Page/UserPostsDetailPage.dart';

class ProfilePostGrid extends StatefulWidget {
  const ProfilePostGrid({super.key});

  @override
  State<ProfilePostGrid> createState() => _ProfilePostGridState();
}

class _ProfilePostGridState extends State<ProfilePostGrid> {
  List<PostSummaryDTO> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      final response = await ApiService().get('/user/postsSummary');
      if (mounted) {
        setState(() {
          var rawList = response['data'] as List? ?? [];
          posts = rawList.map((i) => PostSummaryDTO.fromJson(i)).toList();
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
          imageUrl = 'http://10.0.2.2:5090' + mediaList[0].mediaUrl;
          if (imageUrl.contains('localhost')) {
            imageUrl = imageUrl.replaceAll('localhost', '10.0.2.2');
          }
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserPostsDetailPage(
                  initialIndex: index,
                ),
              ),
            );
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