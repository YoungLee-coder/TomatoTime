import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../models/user_profile.dart';
import '../services/user_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final UserProfile userProfile;

  const ProfileEditScreen({Key? key, required this.userProfile})
    : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _userService = UserService();

  String? _avatarPath;
  File? _newAvatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userProfile.name;
    _taglineController.text = widget.userProfile.tagline;
    _avatarPath = widget.userProfile.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Web平台不支持选择图片')));
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newAvatarFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 如果有新头像，保存它
      String? newAvatarPath = _avatarPath;
      if (_newAvatarFile != null) {
        newAvatarPath = await _userService.saveAvatar(_newAvatarFile!);

        // 如果之前有头像，删除旧头像
        if (_avatarPath != null && newAvatarPath != null) {
          await _userService.deleteAvatar(_avatarPath!);
        }
      }

      // 创建新的用户资料
      final updatedProfile = UserProfile(
        name: _nameController.text,
        tagline: _taglineController.text,
        avatarPath: newAvatarPath,
      );

      // 保存用户资料
      final success = await _userService.saveUserProfile(updatedProfile);

      if (success) {
        if (mounted) {
          Navigator.pop(context, updatedProfile);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('保存资料失败')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存资料失败: $e')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // 头像
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _getAvatarImage(),
                      child: _getAvatarChild(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 姓名
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '姓名',
                  hintText: '请输入您的姓名',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入姓名';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // 签名
              TextFormField(
                controller: _taglineController,
                decoration: const InputDecoration(
                  labelText: '个性签名',
                  hintText: '请输入您的个性签名',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_newAvatarFile != null) {
      return FileImage(_newAvatarFile!);
    } else if (_avatarPath != null) {
      return FileImage(File(_avatarPath!));
    }
    return null;
  }

  Widget? _getAvatarChild() {
    if (_newAvatarFile != null || _avatarPath != null) {
      return null;
    }

    return Icon(
      Icons.person,
      size: 50,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
