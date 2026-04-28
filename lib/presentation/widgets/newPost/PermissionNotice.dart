import 'package:flutter/material.dart';

class NewPostPermissionNotice extends StatelessWidget {
  final VoidCallback onManagePermission;

  const NewPostPermissionNotice({super.key, required this.onManagePermission});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Bạn đã cấp cho Instagram quyền truy cập vào một số ảnh và video.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onManagePermission,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Quản lý',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}