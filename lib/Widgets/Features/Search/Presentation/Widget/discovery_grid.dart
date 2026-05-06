// lib/presentation/search/widgets/discovery_grid.dart

import 'package:flutter/material.dart';

class DiscoveryGrid extends StatelessWidget {
  final List<dynamic> posts;
  final bool isLoading;

  const DiscoveryGrid({super.key, required this.posts, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white54));
    }

    return GridView.builder(
      // Giảm padding về 0 để các ảnh sát nhau như hình mẫu
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1, // Khoảng cách nhỏ giữa các ảnh
        mainAxisSpacing: 1,
        childAspectRatio: 0.75, // Tỷ lệ ảnh dọc
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            // Hiển thị hình ảnh
            Image.network(
              post['imageUrl'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
            ),

            // Lớp phủ hiển thị lượt xem ở góc dưới bên trái
            Positioned(
              bottom: 8,
              left: 8,
              child: Row(
                children: [
                  const Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.white,
                      size: 14
                  ),
                  const SizedBox(width: 4),
                  Text(
                    post['views'] ?? '0',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)]
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}