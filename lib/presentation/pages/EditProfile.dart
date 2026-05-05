import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/DTOs/UserDTO.dart';
import '../../data/datasources/global/User.dart';
import '../widgets/edit_profile/EditProfileAppBar.dart';
import '../widgets/edit_profile/EditProfileField.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _genderController;

  static const Color _backgroundColor = Color(0xFF121212);
  static const Color _borderColor = Color(0xFF262626);
  static const Color _actionBlue = Color(0xFF0095F6);

  late String _initialName;
  late String _initialUsername;
  late String _initialBio;
  late String _initialGender;
  bool _isDirty = false;
  bool _isLoading = false;
  File? _newAvatar;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<UserProvider>().user;

    String getGenderText(int? genderValue) {
      if (genderValue == 1) return 'Nam';
      if (genderValue == 2) return 'Nữ';
      return 'Ẩn';
    }

    _nameController = TextEditingController(text: currentUser?.fullName ?? '');
    _usernameController = TextEditingController(text: currentUser?.username ?? '');
    _bioController = TextEditingController(text: currentUser?.bio ?? '');
    _genderController = TextEditingController(text: getGenderText(currentUser?.gender));
    _currentAvatarUrl= currentUser?.avatarUrl;
    
    if (currentUser?.avatarUrl != null && currentUser!.avatarUrl!.isNotEmpty) {
      _currentAvatarUrl = currentUser.avatarUrl!.replaceFirst('localhost', '10.0.2.2');
    }

    _initialName = _nameController.text;
    _initialUsername = _usernameController.text;
    _initialBio = _bioController.text;
    _initialGender = _genderController.text;

    _nameController.addListener(_checkDirty);
    _usernameController.addListener(_checkDirty);
    _bioController.addListener(_checkDirty);
    _genderController.addListener(_checkDirty);
  }

  void _checkDirty() {
    bool isDirty = _nameController.text != _initialName ||
        _usernameController.text != _initialUsername ||
        _bioController.text != _initialBio ||
        _genderController.text != _initialGender ||
        _newAvatar != null;

    if (isDirty != _isDirty) {
      setState(() {
        _isDirty = isDirty;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isDirty) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
                'Bỏ thay đổi?', style: TextStyle(color: Colors.white)),
            content: const Text(
              'Nếu bạn quay lại bây giờ, các thay đổi của bạn sẽ không được lưu.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Không thoát
                child: const Text('Hủy', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Đồng ý thoát
                child: const Text(
                    'Bỏ', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
    );

    return shouldPop ?? false;
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Giới tính', style: TextStyle(color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
              ),
              const Divider(color: Colors.white24, height: 1),
              _buildGenderOption('Nam'),
              _buildGenderOption('Nữ'),
              _buildGenderOption('Ẩn'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(color: Colors.white)),
      trailing: _genderController.text == value ? const Icon(
          Icons.check, color: _actionBlue) : null,
      onTap: () {
        _genderController.text = value;
        Navigator.pop(context);
      },
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newAvatar = File(image.path);
      });
      _checkDirty();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: const EditProfileAppBar(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      shape: BoxShape.circle,
                      image: _newAvatar != null 
                          ? DecorationImage(image: FileImage(_newAvatar!), fit: BoxFit.cover)
                          : (_currentAvatarUrl != null 
                              ? DecorationImage(image: NetworkImage('http://10.0.2.2:5090'+_currentAvatarUrl!), fit: BoxFit.cover)
                              : null),
                    ),
                    child: _newAvatar == null && _currentAvatarUrl == null
                        ? const Icon(Icons.person, color: _backgroundColor, size: 45)
                        : null,
                  ),
                ],
              ),
              TextButton(
                onPressed: _pickImage,
                child: const Text(
                  'Chỉnh sửa ảnh',
                  style: TextStyle(color: _actionBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: _borderColor),
                    bottom: BorderSide(color: _borderColor),
                  ),
                ),
                child: Column(
                  children: [
                    EditProfileField(label: 'Tên', controller: _nameController),
                    EditProfileField(label: 'Tên người dùng',
                        controller: _usernameController),
                    EditProfileField(
                        label: 'Tiểu sử', controller: _bioController),
                    EditProfileField(
                      label: 'Giới tính',
                      controller: _genderController,
                      readOnly: true,
                      onTap: _showGenderPicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nút Chỉnh sửa / Lưu ở dưới cùng
              if (_isDirty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          int getGenderValue(String text) {
                            if (text == 'Nam') return 1;
                            if (text == 'Nữ') return 2;
                            return 0; // Ẩn
                          }

                          var formData = FormData.fromMap({
                            'FullName': _nameController.text.trim(), // Nên viết hoa chữ cái đầu cho khớp hoàn toàn với C# DTO
                            'Username': _usernameController.text.trim(),
                            'Bio': _bioController.text.trim(),
                            'Gender': getGenderValue(_genderController.text.trim()),
                          });

                          if (_newAvatar != null) {
                            String fileName = _newAvatar!.path.split('/').last;

                            formData.files.add(MapEntry(
                              'Avatar',
                              await MultipartFile.fromFile(
                                _newAvatar!.path,    
                                filename: fileName,   
                              ),
                            ));
                          }

                          await ApiService().put('/user/profile', data: formData);

                          if (mounted) {
                            setState(() {
                              _initialName = _nameController.text;
                              _initialUsername = _usernameController.text;
                              _initialBio = _bioController.text;
                              _initialGender = _genderController.text;
                              _newAvatar = null;
                              _isDirty = false;
                            });
                            final userRes = await ApiService().get('/user/profile');
                            if (userRes != null && userRes['data'] != null) {
                              UserModelDTO user = UserModelDTO.fromJson(userRes['data']);
                              if (mounted) {
                                Provider.of<UserProvider>(context, listen: false).setUser(user);
                              }
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Đã cập nhật thông tin thành công!')),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cập nhật thất bại: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _actionBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : const Text('Lưu thay đổi', style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}