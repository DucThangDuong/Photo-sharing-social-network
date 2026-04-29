import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CountryPickerRow extends StatelessWidget {
  final VoidCallback onChange;

  const CountryPickerRow({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Việt Nam (+84)', style: TextStyle(color: Colors.white, fontSize: 16)),
        TextButton(
          onPressed: onChange,
          child: const Text(
            'Thay đổi',
            style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}