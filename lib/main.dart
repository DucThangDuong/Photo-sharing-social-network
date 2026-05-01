import 'package:flutter/material.dart';
import 'package:untitled/presentation/widgets/Features1/Auth/Presentation/Pages/RegisterNamePage.dart';
import 'package:untitled/presentation/widgets/Features1/Auth/Presentation/Pages/login_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: InstagramLoginDark(),
    );
  }
}

