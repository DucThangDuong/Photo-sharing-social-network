import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback toggleVisibility;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.toggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: !isVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Mật khẩu',
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
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}