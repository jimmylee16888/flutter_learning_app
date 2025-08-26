// lib/app_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings({ThemeMode? themeMode, Locale? locale})
    : _themeMode = themeMode ?? ThemeMode.system,
      _locale = locale;

  ThemeMode _themeMode;
  Locale? _locale;

  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  Future<void> setThemeMode(ThemeMode m) async {
    _themeMode = m;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setInt('themeMode', m.index);
  }

  Future<void> setLocale(Locale? l) async {
    _locale = l;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    if (l == null) {
      await sp.remove('locale');
    } else {
      await sp.setString('locale', l.toLanguageTag());
    }
  }

  static Future<AppSettings> load() async {
    final sp = await SharedPreferences.getInstance();
    final tmIndex = sp.getInt('themeMode');
    final tm = tmIndex == null ? ThemeMode.system : ThemeMode.values[tmIndex];

    final tag = sp.getString('locale');
    Locale? loc;
    if (tag != null && tag.isNotEmpty) {
      final parts = tag.split('-');
      if (parts.length == 1) {
        loc = Locale(parts[0]);
      } else if (parts.length >= 2) {
        loc = Locale(parts[0], parts[1]);
      }
    }
    return AppSettings(themeMode: tm, locale: loc);
  }
}
