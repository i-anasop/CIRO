import 'package:flutter/material.dart';

class UserProfileService extends ChangeNotifier {
  UserProfileService._internal();
  static final UserProfileService instance = UserProfileService._internal();

  String _name = '';
  String _role = '';
  String _email = '';
  int _avatarIndex = 0; // 0: Indigo Person, 1: Emerald Shield, 2: Amber Star, 3: Purple Command
  String? _customAvatarUrl;

  String get name => _name;
  String get role => _role;
  String get email => _email;
  int get avatarIndex => _avatarIndex;
  String? get customAvatarUrl => _customAvatarUrl;

  // Predefined gorgeous premium colors and icons for profiles
  static final List<Color> avatarColors = [
    const Color(0xFF4F46E5), // Royal Indigo
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Warning Amber
    const Color(0xFF8B5CF6), // Purple Glow
  ];

  static final List<IconData> avatarIcons = [
    Icons.person_rounded,
    Icons.security_rounded,
    Icons.star_rounded,
    Icons.admin_panel_settings_rounded,
  ];

  void updateProfile({
    required String name,
    required String role,
    required String email,
    required int avatarIndex,
    String? customAvatarUrl,
  }) {
    _name = name.trim();
    _role = role.trim();
    _email = email.trim();
    _avatarIndex = avatarIndex;
    _customAvatarUrl = customAvatarUrl;
    notifyListeners();
  }
}
