import 'package:flutter/material.dart';
import 'package:untitled/Widgets/Features/Auth/Presentation/Pages/register_page.dart';
import '../../../Home/Presentation/Pages/main_wrapper.dart';
import '../Widgets/Button/AuthButton.dart';
import '../Widgets/InputField/AuthInputField.dart';
import '../Widgets/Logo/Login_Logo.dart';
import '../Widgets/Logo/MetaFooter.dart';
import 'find_account_page.dart';

class InstagramLoginDark extends StatefulWidget {
  @override
  _InstagramLoginDarkState createState() => _InstagramLoginDarkState();
}
class _InstagramLoginDarkState extends State<InstagramLoginDark> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
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
                hint: 'Tên người dùng, email/số di động',
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
                label: 'Đăng nhập',
                color: const Color(0xFF0064E0),
                onPressed: (){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainWrapper()),
                  );
                  print("An dang nhap");
                },
              ),

              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FindAccountPage())),
                child: const Text('Quên mật khẩu?', style: TextStyle(color: Colors.white)),
              ),

              const Spacer(flex: 2),

              // Nút Tạo tài khoản (Style Outlined)
              _buildCreateAccountButton(),
              const SizedBox(height: 15),

              const MetaFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget riêng cho nút tạo tài khoản vì nó có style Outlined khác biệt
  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF0064E0), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPhonePage())),
        child: const Text('Tạo tài khoản mới', style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold)),
      ),
    );
  }
}