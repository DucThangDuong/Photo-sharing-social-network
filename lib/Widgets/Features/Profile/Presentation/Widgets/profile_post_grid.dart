import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePostGrid extends StatelessWidget {
  const ProfilePostGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true, // cho phép cuộn trong siglescrollview
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, //ngang 3 hình
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 9, // Số lượng bài viết mẫu
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[900],
          child: Image.network('https://picsum.photos/id/${index + 10}/200', fit: BoxFit.cover),
        );
      },
    );
  }
}