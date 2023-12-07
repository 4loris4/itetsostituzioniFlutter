import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itetsostituzioni/main.dart';

late final StateNotifierProvider<ThemeNotifier, ThemeMode> themeProvider;

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier(super.state);

  set theme(ThemeMode theme) {
    prefs.setTheme(theme);
    state = theme;
  }
}
