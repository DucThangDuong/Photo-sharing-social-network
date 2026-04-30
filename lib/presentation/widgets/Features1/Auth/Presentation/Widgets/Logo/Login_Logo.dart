import 'package:flutter/cupertino.dart';

class LoginLogo extends StatelessWidget {
  const LoginLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 75,
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: NetworkImage('https://cdn-icons-png.flaticon.com/512/174/174855.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}