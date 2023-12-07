import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itetsostituzioni/main.dart';

late final StateNotifierProvider<UserNotifier, User> userProvider;

enum UserType { student, teacher }

@immutable
class User {
  final UserType? type;
  final String? name;

  const User(this.type, this.name);

  bool get isTeacher => type == UserType.teacher;
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier(super.state);

  set type(UserType type) {
    prefs.setUserType(type);
    prefs.setUserName(null);
    state = User(type, null);
  }

  set name(String name) {
    prefs.setUserName(name);
    state = User(state.type, name);
  }
}
