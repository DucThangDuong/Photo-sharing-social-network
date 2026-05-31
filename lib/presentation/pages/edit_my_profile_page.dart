import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:untitled/data/datasources/ApiServices.dart';
import 'package:untitled/data/datasources/global/CallAPIOfUser.dart';
import 'package:untitled/data/datasources/global/SnackBarError.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/DTOs/UserDTO.dart';
import '../../data/datasources/global/User.dart';
import '../widgets/edit_my_profile/edit_main.dart';
import '../widgets/edit_my_profile/edit_AppBar.dart';

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
    _currentAvatarUrl=  currentUser?.avatarUrl;

    _initialName = _nameController.text;
    _initialUsername = _usernameController.text;
    _initialBio = _bioController.text;
    _initialGender = _genderController.text;

    _nameController.addListener(_checkDirty);
    _usernameController.addListener(_checkDirty);
    _bioController.addListener(_checkDirty);
    _genderController.addListener(_checkDirty);
  }
  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _genderController.dispose();
    super.dispose();
  }
  // option chọn giới tính
  Widget _buildGenderOption(String value) {
    return ListTile(
      title: Text(value, style: const TextStyle(color: Colors.white)),
      trailing: _genderController.text == value ? const Icon(
          Icons.check, color: Color(0xFF0095F6)) : null,
      onTap: () {
        _genderController.text = value;
        Navigator.pop(context);
      },
    );
  }
  // kiểm tra có thay đổi dữ liệu không để hiện btn xác nhận gửi api
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
  // widget để chọn giới tính
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
  // chọn ảnh đại diện
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
  // btn nhấn xác nhận thay đổi thông tin
  Future<void> _ChangeEdit() async {
    setState(() {
      _isLoading = true;
    });
    try {
      int getGenderValue(String text) {
        if (text == 'Nam') return 1;
        if (text == 'Nữ') return 2;
        return 0;
      }

      var formData = FormData.fromMap({
        'FullName': _nameController.text.trim(),
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

      await CallMyAPI.updateUserProfile(formData);

      if (mounted) {
        setState(() {
          _initialName = _nameController.text;
          _initialUsername = _usernameController.text;
          _initialBio = _bioController.text;
          _initialGender = _genderController.text;
          _newAvatar = null;
          _isDirty = false;
        });
        final userRes = await CallMyAPI.getUserProfile();
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
        SnackBarError.show(context, prefix: 'Cập nhật thất bại');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: const EditProfileAppBar(),
        body: SingleChildScrollView(
          child: EditMain(
            nameController: _nameController,
            usernameController: _usernameController,
            bioController: _bioController,
            genderController: _genderController,
            isDirty: _isDirty,
            isLoading: _isLoading,
            newAvatar: _newAvatar,
            currentAvatarUrl: _currentAvatarUrl,
            onPickImage: _pickImage,
            onShowGenderPicker: _showGenderPicker,
            onSave: _ChangeEdit,
          ),
        ),
      ),
    );
  }
}