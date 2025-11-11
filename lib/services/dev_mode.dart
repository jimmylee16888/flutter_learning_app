import 'package:shared_preferences/shared_preferences.dart';

class DevMode {
  static const _kKey = 'dev_mode_enabled';

  static Future<bool> isEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kKey, value);
  }

  static Future<bool> toggle() async {
    final sp = await SharedPreferences.getInstance();
    final next = !(sp.getBool(_kKey) ?? false);
    await sp.setBool(_kKey, next);
    return next;
  }
}
