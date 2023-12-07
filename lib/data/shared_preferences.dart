import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itetsostituzioni/data/theme.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/utils.dart';
import 'package:shared_preferences/shared_preferences.dart' as package;

class SharedPreferences {
  final package.SharedPreferences _prefs;

  SharedPreferences._(this._prefs);

  static Future<SharedPreferences> init() async {
    final prefs = SharedPreferences._(await package.SharedPreferences.getInstance());

    themeProvider = StateNotifierProvider((ref) => ThemeNotifier(prefs.theme));
    userProvider = StateNotifierProvider((ref) => UserNotifier(User(prefs.userType, prefs.user)));

    return prefs;
  }

  static const _themeKey = "theme";
  ThemeMode get theme => inlineTry(() => ThemeMode.values[_prefs.getInt(_themeKey)!], ThemeMode.system);
  Future<bool> setTheme(ThemeMode theme) => _prefs.setInt(_themeKey, theme.index);

  static const _userTypeKey = "userType";
  UserType? get userType => inlineTry(() => UserType.values[_prefs.getInt(_userTypeKey)!], null);
  Future<bool> setUserType(UserType userType) => _prefs.setInt(_userTypeKey, userType.index);

  static const _userKey = "user";
  String? get user => _prefs.getString(_userKey);
  Future<bool> setUserName(String? user) => user == null ? _prefs.remove(_userKey) : _prefs.setString(_userKey, user);

  static const _substitutionsJSONKey = "substitutionsJSON";
  String? get substitutionsJSON => _prefs.getString(_substitutionsJSONKey);
  Future<bool> setSubstitutionsJSON(String data) => _prefs.setString(_substitutionsJSONKey, data);

  static const _teachersJSONKey = "teachersJSON";
  String? get teachersJSON => _prefs.getString(_teachersJSONKey);
  Future<bool> setTeachersJSON(String data) => _prefs.setString(_teachersJSONKey, data);

  static const _classesDataJSON = "classesJSON";
  String? get classesJSON => _prefs.getString(_classesDataJSON);
  Future<bool> setClassesJSON(String data) => _prefs.setString(_classesDataJSON, data);
}
