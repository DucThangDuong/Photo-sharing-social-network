import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../../Home/Presentation/Pages/main_wrapper.dart';
import '../Widgets/Button/AuthButton.dart';
import '../Widgets/InputField/AuthInputField.dart';
import '../Widgets/Logo/Login_Logo.dart';
import '../Widgets/Logo/MetaFooter.dart';
import 'register_page.dart';
import 'find_account_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
import 'package:untitled/data/datasources/global/CallAPIOfUser.dart';
import 'package:untitled/data/datasources/global/SnackBarError.dart';

class InstagramLoginDark extends StatefulWidget {
  @override
  _InstagramLoginDarkState createState() => _InstagramLoginDarkState();
}
class _InstagramLoginDarkState extends State<InstagramLoginDark> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  // gửi yêu cầu đăng nhập lên api
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await CallMyAPI.login(email, password);
      if (response != null && response['data'] != null) {
        final String? token = response['data']['access_token'];
        if (token != null) {
          const storage = FlutterSecureStorage();
          await storage.write(key: 'access_token', value: token);
          try {
            await FirebaseMessaging.instance.requestPermission();

            String? fcmToken = await FirebaseMessaging.instance.getToken();

            if (fcmToken != null) {
              await ApiService().post('/auth/save-device-token', data: {
                'deviceToken': fcmToken,
                'deviceType': 'android'
              });
              print("Đã lưu FCM Token: $fcmToken");
            }
          } catch (e) {
            print("Lỗi cấu hình Firebase Token: $e");
          }
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainWrapper()),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarError.show(context, prefix: 'Tài khoản hoặc mật khẩu không chính xác');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // widget btn tạo tài khoản mới
  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF0064E0), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterEmailPage())),
        child: const Text('Tạo tài khoản mới', style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold)),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),
                        const LoginLogo(),
                        const SizedBox(height: 50),

                        // Ô nhập Email/User
                        AuthInputField(
                          controller: _emailController,
                          hint: 'Email người dùng',
                        ),
                        const SizedBox(height: 12),

                        // Ô nhập Mật khẩu
                        AuthInputField(
                          controller: _passwordController,
                          hint: 'Mật khẩu',
                          isPassword: true,
                          isVisible: _isPasswordVisible,
                          toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),

                        const SizedBox(height: 15),

                        // Nút Đăng nhập
                        AuthButton(
                          label: _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                          color: const Color(0xFF0064E0),
                          onPressed: _isLoading ? () {} : _handleLogin,
                        ),

                        // TextButton(
                        //   onPressed: () => Navigator.push(
                        //       context,
                        //       MaterialPageRoute(builder: (context) => const FindAccountPage())
                        //   ),
                        //   child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.white)),
                        // ),

                        const Spacer(flex: 2),

                        // Nút Tạo tài khoản
                        _buildCreateAccountButton(),
                        const SizedBox(height: 15),

                        // const MetaFooter(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}