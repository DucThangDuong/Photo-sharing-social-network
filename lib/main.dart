import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'Widgets/Features/Auth/Presentation/Pages/login_page.dart';
import 'Widgets/Features/Home/Presentation/Pages/main_wrapper.dart';
import 'data/datasources/global/User.dart';
import 'Widgets/Features/Search/Presentation/Page/discover_post_detail_page.dart';
import 'presentation/pages/guest_profile_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔥 Đã nhận thông báo ngầm (Background/Terminated): ${message.notification?.title}");
}

void _handleNotificationNavigation(RemoteMessage message) {
  final data = message.data;
  if (data.isEmpty) return;

  final String? typeStr = data['type'];
  final String? postIdStr = data['postId'];
  final String? senderIdStr = data['senderId'];

  if (typeStr == '3' && postIdStr != null) {
    // Điều hướng đến chi tiết bài đăng
    final int postId = int.parse(postIdStr);
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => DiscoverPostDetailPage(postId: postId),
      ),
    );
  } else if (typeStr == '2' && senderIdStr != null) {
    // Điều hướng đến trang cá nhân
    final int senderId = int.parse(senderIdStr);
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => GuestProfilePage(userId: senderId),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationNavigation(message);
  });

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
          child: MyApp(initialScreen: firstScreen)
      )
  );

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print("🔥 Người dùng đã nhấn vào thông báo (từ Terminated): ${message.notification?.title}");
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationNavigation(message);
      });
    }
  });
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

