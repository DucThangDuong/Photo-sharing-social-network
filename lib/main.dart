import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:untitled/presentation/widgets/Features/Auth/Presentation/Pages/login_page.dart';
import 'package:untitled/presentation/widgets/Features/Home/Presentation/Pages/main_wrapper.dart';
import 'data/datasources/global/User.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  Widget firstScreen;
  if (token != null && token.isNotEmpty) {
    firstScreen = const MainWrapper();
  } else {
    firstScreen = InstagramLoginDark();
  }
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProvider()),
          ],
      child:MyApp(initialScreen: firstScreen)
      )
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

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
      home: initialScreen,
    );
  }
}

