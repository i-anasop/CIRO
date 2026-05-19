// CIRO — App Mode Service
// Controls Demo Mode vs Real Mode toggle.
// Uses ChangeNotifier so all screens react when mode changes.

import 'dart:io';
import 'package:flutter/foundation.dart';

class AppModeService extends ChangeNotifier {
  // ── Singleton ─────────────────────────────────────────────────────────────
  static final AppModeService instance = AppModeService._();
  AppModeService._() {
    _loadPersistedMode();
  }

  // Default: Demo Mode ON (safe for hackathon)
  bool _demoMode = true;

  bool get isDemoMode => _demoMode;
  bool get isRealMode => !_demoMode;

  void _loadPersistedMode() {
    try {
      if (kIsWeb) return;
      final file = File(_getFilePath());
      if (file.existsSync()) {
        final content = file.readAsStringSync().trim();
        _demoMode = content == 'demo';
      }
    } catch (e) {
      debugPrint("Error loading persisted mode: $e");
    }
  }

  void _persistMode() {
    try {
      if (kIsWeb) return;
      final file = File(_getFilePath());
      file.writeAsStringSync(_demoMode ? 'demo' : 'real');
    } catch (e) {
      debugPrint("Error persisting mode: $e");
    }
  }

  String _getFilePath() {
    return '${Directory.systemTemp.path}/ciro_app_mode.txt';
  }

  void setDemoMode(bool value) {
    if (_demoMode == value) return;
    _demoMode = value;
    _persistMode();
    notifyListeners();
  }

  void toggleMode() => setDemoMode(!_demoMode);
}
