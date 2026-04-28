import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../pages/newCaptionPost.dart';

class NewPostAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMultiSelectMode;
  final List<AssetEntity> selectedAssets;
  final String imagePath;

  const NewPostAppBar({
    super.key,
    required this.isMultiSelectMode,
    required this.selectedAssets,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 28),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Bài viết mới',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () async {
            List<String> pathsToShare = [];
            if (isMultiSelectMode && selectedAssets.isNotEmpty) {
              for (var asset in selectedAssets) {
                final file = await asset.file;
                if (file != null) pathsToShare.add(file.path);
              }
            } else if (imagePath.isNotEmpty) {
              pathsToShare.add(imagePath);
            }
            if (pathsToShare.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ảnh để tiếp tục.')),
              );
              return;
            }
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinalSharePostScreen(imagePaths: pathsToShare),
                ),
              );
            }
          },
          child: const Text(
            'Tiếp',
            style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}