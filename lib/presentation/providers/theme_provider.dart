import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initialThemeModeProvider = Provider<String>((ref) => 'system');

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.watch(initialThemeModeProvider);
    return saved == 'dark'
        ? ThemeMode.dark
        : saved == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
  }

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = state == ThemeMode.dark
        ? 'dark'
        : state == ThemeMode.light
            ? 'light'
            : 'system';
    await prefs.setString('themeMode', key);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
