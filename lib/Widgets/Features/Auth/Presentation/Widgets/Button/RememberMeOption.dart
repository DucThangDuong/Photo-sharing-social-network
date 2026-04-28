import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RememberMeOption extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onLearnMore;

  const RememberMeOption({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFF0064E0),
            onChanged: onChanged,
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 14),
              children: [
                const TextSpan(text: 'Ghi nhớ thông tin đăng nhập. '),
                TextSpan(
                  text: 'Tìm hiểu thêm',
                  style: const TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()..onTap = onLearnMore,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}