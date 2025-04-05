// import 'package:flutter/material.dart';

class UserProfile {
  String name;
  String tagline;
  String? avatarPath;

  UserProfile({this.name = '用户', this.tagline = '专注达人', this.avatarPath});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '用户',
      tagline: json['tagline'] as String? ?? '专注达人',
      avatarPath: json['avatarPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'tagline': tagline, 'avatarPath': avatarPath};
  }

  UserProfile copyWith({String? name, String? tagline, String? avatarPath}) {
    return UserProfile(
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
