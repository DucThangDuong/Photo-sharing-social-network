import 'package:flutter/material.dart';

import '../../../data/datasources/DTOs/UserDTO.dart';

class FollowerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModelDTO user;

  const FollowerAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        user.username,
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(
              Icons.person_add_outlined, color: Colors.white, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
