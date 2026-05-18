// CIRO — App Mode Service
// Controls Demo Mode vs Real Mode toggle.
// Uses ChangeNotifier so all screens react when mode changes.

import 'package:flutter/foundation.dart';

class AppModeService extends ChangeNotifier {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final AppModeService instance = AppModeService._();
  AppModeService._();

  // Default: Demo Mode ON (safe for hackathon)
  bool _demoMode = true;

  bool get isDemoMode => _demoMode;
  bool get isRealMode => !_demoMode;

  void setDemoMode(bool value) {
    if (_demoMode == value) return;
    _demoMode = value;
    notifyListeners();
  }

  void toggleMode() => setDemoMode(!_demoMode);
}
