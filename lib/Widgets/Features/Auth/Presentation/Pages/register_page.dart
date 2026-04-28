import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'create_account_email.dart';
import 'create_account_number.dart';

class RegisterPhonePage extends StatefulWidget {
  @override
  _RegisterPhonePageState createState() => _RegisterPhonePageState();
}

class _RegisterPhonePageState extends State<RegisterPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _launchInstagramHelp;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _launchInstagramHelp() async {
    final Uri url = Uri.parse('https://help.instagram.com/574047304429005');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Không thể mở $url');
    }
  }
  bool _isVietnamesePhoneNumber(String phone) {
    //kiểm tra số điện thoại việt nam
    final RegExp phoneRegex = RegExp(r'^(0[3|5|7|8|9])([0-9]{8})$');
    return phoneRegex.hasMatch(phone);
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
        // GIẢI PHÁP: LayoutBuilder giúp lấy chiều cao chính xác của màn hình
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // Ép chiều cao tối thiểu bằng chiều cao màn hình để Spacer hoạt động
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          'Số di động của bạn là gì?',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'Nhập số di động có thể dùng để liên hệ với bạn. Sẽ không ai nhìn thấy thông tin này trên trang cá nhân của bạn.',
                          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 30),

                        // Phần quốc gia
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Việt Nam (+84)', style: TextStyle(color: Colors.white, fontSize: 16)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('Thay đổi', style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        // TextField
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Số di động',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFF1E1E1E),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Color(0xFF333333)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white54),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Tìm hiểu thêm
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                            children: [
                              const TextSpan(text: 'Chúng tôi có thể gửi thông báo cho bạn qua WhatsApp và SMS. '),
                              TextSpan(
                                text: 'Tìm hiểu thêm',
                                style: const TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold),
                                recognizer: _tapGestureRecognizer,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Nút Tiếp
                        _buildButton(
                          label: 'Tiếp',
                          color: const Color(0xFF0064E0),
                          onPressed: () {
                            String phone = _phoneController.text.trim();

                            if (phone.isEmpty) {
                              // 1. Kiểm tra trống
                              _showErrorSnackBar('Vui lòng nhập số điện thoại');
                            } else if (!_isVietnamesePhoneNumber(phone)) {
                              // 2. Kiểm tra định dạng hợp lệ
                              _showErrorSnackBar('Số điện thoại không đúng định dạng Việt Nam');
                            } else {
                              // 3. Nếu hợp lệ -> Chuyển trang
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreatePasswordPage()),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 15),

                        // Nút Đăng ký email
                        _buildButton(
                            label: 'Đăng ký bằng email',
                            color: const Color(0xFF262626),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterEmailPage()));
                            }
                        ),

                        // Dùng Spacer để đẩy nút cuối cùng xuống đáy nếu màn hình dài
                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 20),
                          child: Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                  'Tôi có tài khoản rồi',
                                  style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold)
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

  Widget _buildButton({
    required String label,
    required Color color,
    VoidCallback? onPressed, // Thêm dòng này
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 0,
        ),
        onPressed: onPressed, // Sử dụng tham số onPressed truyền vào
        child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating, // Hiển thị nổi trên giao diện
        duration: const Duration(seconds: 2),
      ),
    );
  }
}