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
            image: NetworkImage('https://i.pinimg.com/736x/b2/3e/56/b23e561043f37f242019dbb6abab30d3.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}