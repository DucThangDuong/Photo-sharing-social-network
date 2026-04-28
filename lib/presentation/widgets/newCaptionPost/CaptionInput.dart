import 'package:flutter/material.dart';

class NewCaptionInput extends StatelessWidget {
  const NewCaptionInput({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Thêm chú thích...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
          border: InputBorder.none,
        ),
        maxLines: null,
      ),
    );
  }
}