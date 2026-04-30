import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordHeader extends StatelessWidget {
  const PasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          'Tạo mật khẩu',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        Text(
          'Tạo mật khẩu gồm ít nhất 6 chữ cái hoặc chữ số. Bạn nên chọn mật khẩu thật khó đoán.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}