import 'package:flutter/material.dart';

class EditProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;

  const EditProfileField({
    super.key,
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.onTap,
  });

  static const Color _borderColor = Color(0xFF262626);
  static const Color _labelColor = Color(0xFFF5F5F5);
  static const Color _actionBlue = Color(0xFF0095F6);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nhãn bên trái (Có chiều rộng cố định để căn chỉnh)
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: const TextStyle(color: _labelColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ),
              // Ô nhập bên phải
              Expanded(
                child: TextFormField(
                  controller: controller,
                  readOnly: readOnly,
                  onTap: onTap,
                  cursorColor: _actionBlue,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    // Không có đường viền ô
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 12), // Tăng padding để dễ chạm
                  ),
                ),
              ),
            ],
          ),
        ),
        // Đường chia mờ
        const Divider(color: _borderColor, height: 1, indent: 16),
      ],
    );
  }
}
