import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class PrivacyNote extends StatelessWidget {
  final TapGestureRecognizer recognizer;

  const PrivacyNote({super.key, required this.recognizer});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
        children: [
          const TextSpan(text: 'Chúng tôi có thể gửi thông báo cho bạn qua WhatsApp và SMS. '),
          TextSpan(
            text: 'Tìm hiểu thêm',
            style: const TextStyle(
              color: Color(0xFF0064E0),
              fontWeight: FontWeight.bold,
            ),
            // Gán recognizer vào đây
            recognizer: recognizer,
          ),
        ],
      ),
    );
  }
}