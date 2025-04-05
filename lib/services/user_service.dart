import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserService {
  static const String _userProfileKey = 'user_profile';

  // 获取用户信息
  Future<UserProfile> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileJson = prefs.getString(_userProfileKey);

      if (userProfileJson != null) {
        final userProfileMap =
            jsonDecode(userProfileJson) as Map<String, dynamic>;
        return UserProfile.fromJson(userProfileMap);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }

    // 返回默认用户信息
    return UserProfile();
  }

  // 保存用户信息
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileJson = jsonEncode(profile.toJson());
      return await prefs.setString(_userProfileKey, userProfileJson);
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  // 保存用户头像
  Future<String?> saveAvatar(File imageFile) async {
    if (kIsWeb) {
      debugPrint('Web platform does not support file operations');
      return null;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'user_avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${directory.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving avatar: $e');
      return null;
    }
  }

  // 删除用户头像
  Future<bool> deleteAvatar(String path) async {
    if (kIsWeb) {
      debugPrint('Web platform does not support file operations');
      return false;
    }

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
      return false;
    }
  }
}
