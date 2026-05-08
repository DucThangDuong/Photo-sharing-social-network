import 'package:flutter/material.dart';
import '../../../../../data/datasources/DTOs/PostDTO.dart';
import '../../../../../data/Helper.dart';

class DiscoveryGrid extends StatelessWidget {
  final List<PostSummaryDTO> posts;
  final bool isLoading;

  const DiscoveryGrid({super.key, required this.posts, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white54));
    }

    if (posts.isEmpty) {
      return const Center(child: Text('Không có bài viết nổi bật', style: TextStyle(color: Colors.grey)));
    }

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 0.75,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        String imageUrl = post.postMedia.isNotEmpty
            ? AppHelper.formatImageURL(post.postMedia[0].mediaUrl)
            : '';
        return Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
              )
            else
              Container(color: Colors.grey[900]),
          ],
        );
      },
    );
  }
}