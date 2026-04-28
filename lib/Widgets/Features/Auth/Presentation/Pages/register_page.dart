import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/Button/AuthButton.dart';
import '../Widgets/Button/CountryPickerRow.dart';
import '../Widgets/Button/PrivacyNote.dart';
import '../Widgets/Header/PhoneHeader.dart';
import '../Widgets/InputField/PhoneInputField.dart';
import 'create_account_email.dart';
import 'create_account_number.dart';

class RegisterPhonePage extends StatefulWidget {
  @override
  _RegisterPhonePageState createState() => _RegisterPhonePageState();
}
class _RegisterPhonePageState extends State<RegisterPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  late TapGestureRecognizer _tapGestureRecognizer;

  GestureTapCallback? get _launchInstagramHelp => null;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _handleOpenLink;
  }

  @override
  void dispose() {
    _tapGestureRecognizer.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Logic Validation
  bool _isVietnamesePhoneNumber(String phone) {
    final RegExp phoneRegex = RegExp(r'^(0[3|5|7|8|9])([0-9]{8})$');
    return phoneRegex.hasMatch(phone);
  }
  Future<void> _handleOpenLink() async {
    final Uri url = Uri.parse('https://help.instagram.com/574047304429005');

    try {
      // Thử mở trực tiếp với mode externalApplication
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        debugPrint('Không thể mở liên kết: $url');
      }
    } catch (e) {
      debugPrint('Lỗi phát sinh: $e');
    }
  }
  void _handleNextStep() {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số điện thoại');
    } else if (!_isVietnamesePhoneNumber(phone)) {
      _showErrorSnackBar('Số điện thoại không đúng định dạng Việt Nam');
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePasswordPage()));
    }
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
                        const PhoneHeader(),
                        const SizedBox(height: 30),

                        CountryPickerRow(onChange: () {}),

                        PhoneInputField(controller: _phoneController),
                        const SizedBox(height: 15),

                        PrivacyNote(recognizer: _tapGestureRecognizer),
                        const SizedBox(height: 30),

                        AuthButton(
                          label: 'Tiếp',
                          color: const Color(0xFF0064E0),
                          onPressed: _handleNextStep,
                        ),
                        const SizedBox(height: 15),

                        AuthButton(
                          label: 'Đăng ký bằng email',
                          color: const Color(0xFF262626),
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterEmailPage())),
                        ),

                        const Spacer(),
                        _buildFooter(),
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 20),
      child: Center(
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tôi có tài khoản rồi', style: TextStyle(color: Color(0xFF0064E0), fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Giữ lại hàm thông báo lỗi
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }
}