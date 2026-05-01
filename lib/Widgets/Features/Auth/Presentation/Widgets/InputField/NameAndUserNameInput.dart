import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NameAndUserNameInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isValid;

  const NameAndUserNameInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.isValid = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF333333)),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white54),
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: isValid
                ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                : null,
          ),
        ),
      ],
    );
  }
}