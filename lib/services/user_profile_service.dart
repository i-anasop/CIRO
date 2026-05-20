import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService extends ChangeNotifier {
  UserProfileService._internal();
  static final UserProfileService instance = UserProfileService._internal();

  static const _nameKey = 'ciro.profile.name';
  static const _roleKey = 'ciro.profile.role';
  static const _emailKey = 'ciro.profile.email';
  static const _avatarKey = 'ciro.profile.avatarIndex';
  static const _customAvatarKey = 'ciro.profile.customAvatarUrl';

  String _name = '';
  String _role = '';
  String _email = '';
  int _avatarIndex =
      0; // 0: Indigo Person, 1: Emerald Shield, 2: Amber Star, 3: Purple Command
  String? _customAvatarUrl;

  String get name => _name;
  String get role => _role;
  String get email => _email;
  int get avatarIndex => _avatarIndex;
  String? get customAvatarUrl => _customAvatarUrl;

  bool get isLoggedIn => _email.isNotEmpty || _name.isNotEmpty;

  Future<void> signOut() async {
    await updateProfile(
      name: '',
      role: '',
      email: '',
      avatarIndex: 0,
      customAvatarUrl: null,
    );
  }

  // Predefined gorgeous premium colors and icons for profiles
  static final List<Color> avatarColors = [
    const Color(0xFF4F46E5), // Royal Indigo
    const Color(0xFF10B981), // Emerald
    const Color(0xFFF59E0B), // Warning Amber
    const Color(0xFF8B5CF6), // Purple Glow
    const Color(0xFF06B6D4), // Sentinel Sat Cyan
    const Color(0xFFF43F5E), // Rapid Responder Rose
    const Color(0xFF3B82F6), // Quantum Pulse Blue
    const Color(0xFFEC4899), // Apex Intelligence Pink
  ];

  static final List<IconData> avatarIcons = [
    Icons.person_rounded,
    Icons.security_rounded,
    Icons.star_rounded,
    Icons.memory_rounded,
    Icons.satellite_alt_rounded,
    Icons.rocket_launch_rounded,
    Icons.hub_rounded,
    Icons.psychology_rounded,
  ];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString(_nameKey) ?? '';
    _role = prefs.getString(_roleKey) ?? '';
    _email = prefs.getString(_emailKey) ?? '';
    _avatarIndex = (prefs.getInt(_avatarKey) ?? 0).clamp(
      0,
      avatarIcons.length - 1,
    );
    final savedAvatar = prefs.getString(_customAvatarKey);
    _customAvatarUrl = savedAvatar == null || savedAvatar.isEmpty
        ? null
        : savedAvatar;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String role,
    required String email,
    required int avatarIndex,
    String? customAvatarUrl,
  }) async {
    _name = name.trim();
    _role = role.trim();
    _email = email.trim();
    _avatarIndex = avatarIndex;
    _customAvatarUrl = customAvatarUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, _name);
    await prefs.setString(_roleKey, _role);
    await prefs.setString(_emailKey, _email);
    await prefs.setInt(_avatarKey, _avatarIndex);
    if (_customAvatarUrl == null || _customAvatarUrl!.isEmpty) {
      await prefs.remove(_customAvatarKey);
    } else {
      await prefs.setString(_customAvatarKey, _customAvatarUrl!);
    }
    notifyListeners();
  }
}
