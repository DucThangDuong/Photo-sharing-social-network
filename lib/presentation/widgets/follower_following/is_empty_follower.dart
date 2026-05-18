import 'package:flutter/material.dart';

class EmptyFollowerState extends StatelessWidget {
  const EmptyFollowerState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          child: const Icon(Icons.person_add_outlined, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Bạn sẽ thấy tất cả những người\ntheo dõi mình tại đây',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
          ),
        ),
      ],
    );
  }
}
