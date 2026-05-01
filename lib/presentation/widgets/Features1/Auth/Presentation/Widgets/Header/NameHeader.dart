import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameHeader extends StatelessWidget {
  const NameHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(
          'Chỉnh sửa cách bạn xuất hiện trên Instagram',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}