import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewCaptionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onToggleMultipleImages;

  const NewCaptionAppBar({super.key, required this.onToggleMultipleImages});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Bài viết mới',
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}