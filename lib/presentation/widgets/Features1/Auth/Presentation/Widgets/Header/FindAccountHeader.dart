import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindAccountHeader extends StatelessWidget {
  final bool isSearchingByPhone;

  const FindAccountHeader({super.key, required this.isSearchingByPhone});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Tìm tài khoản',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Text(
          isSearchingByPhone
              ? 'Nhập số di động của bạn.'
              : 'Nhập email hoặc tên người dùng của bạn.',
          style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}