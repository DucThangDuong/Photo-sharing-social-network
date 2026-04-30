import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Số di động',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
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