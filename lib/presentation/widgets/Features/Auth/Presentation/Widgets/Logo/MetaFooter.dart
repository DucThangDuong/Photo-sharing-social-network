import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MetaFooter extends StatelessWidget {
  const MetaFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.all_inclusive, color: Colors.grey, size: 18),
          const SizedBox(width: 5),
          Text(
            'Meta',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}