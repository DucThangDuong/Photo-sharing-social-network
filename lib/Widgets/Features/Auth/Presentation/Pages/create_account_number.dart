import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CreatePasswordPage extends StatefulWidget {
  const CreatePasswordPage({super.key});

  @override
  State<CreatePasswordPage> createState() => _CreatePasswordPageState();
}

class _CreatePasswordPageState extends State<CreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberPassword = true; // Trạng thái checkbox
  bool _isPasswordVisible = false; // Ẩn/hiện mật khẩu
  Future<void> _launchInstagramHelp() async {
    final Uri url = Uri.parse('https://help.instagram.com/1020536697967549');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Không thể mở $url');
    }
  }
  @override
  void dispose() {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // 1. Tiêu đề
                        const Text(
                          'Tạo mật khẩu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        // 2. Mô tả
                        const Text(
                          'Tạo mật khẩu gồm ít nhất 6 chữ cái hoặc chữ số. Bạn nên chọn mật khẩu thật khó đoán.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 3. Ô nhập mật khẩu
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Mật khẩu',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white54),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            // Nút ẩn hiện mật khẩu
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 4. Checkbox Ghi nhớ mật khẩu
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _rememberPassword,
                                activeColor: const Color(0xFF0064E0),
                                checkColor: Colors.white,
                                side: const BorderSide(color: Colors.grey),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (bool? value) {
                                  setState(() {
                                    _rememberPassword = value ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  children: [
                                    const TextSpan(text: 'Ghi nhớ thông tin đăng nhập. '),
                                    TextSpan(
                                      text: 'Tìm hiểu thêm',
                                      style: const TextStyle(
                                        color: Color(0xFF0064E0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer: TapGestureRecognizer()..onTap = () {
                                        _launchInstagramHelp();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 5. Nút Tiếp
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0064E0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // Logic chuyển tiếp hoặc thông báo nếu pass < 6 ký tự
                              if (_passwordController.text.length < 6) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
                                );
                              } else {
                                // Navigator.push sang trang nhập tên người dùng...
                              }
                            },
                            child: const Text(
                              'Tiếp',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // 6. Footer
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                // Quay về màn hình login chính
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              },
                              child: const Text(
                                'Tôi có tài khoản rồi',
                                style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
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