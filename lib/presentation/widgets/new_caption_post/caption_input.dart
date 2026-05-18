import 'package:flutter/material.dart';

class NewCaptionInput extends StatelessWidget {
  final TextEditingController controller;

  const NewCaptionInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
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