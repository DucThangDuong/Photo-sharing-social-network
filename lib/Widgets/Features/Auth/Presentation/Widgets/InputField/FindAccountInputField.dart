import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FindAccountInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearchingByPhone;

  const FindAccountInputField({
    super.key,
    required this.controller,
    required this.isSearchingByPhone,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isSearchingByPhone ? TextInputType.phone : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: isSearchingByPhone ? 'Số di động' : 'Email hoặc tên người dùng',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}