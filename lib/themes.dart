import 'package:flutter/material.dart';

ThemeData get lightTheme {
  const colorScheme = ColorScheme.light(primary: Colors.blue);
  final appBarTheme = AppBarTheme(backgroundColor: Colors.blue.shade200, foregroundColor: Colors.black);

  return ThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    dividerColor: colorScheme.onSurface.withOpacity(0.12),
    appBarTheme: appBarTheme,
    tabBarTheme: TabBarTheme(
      labelColor: Colors.blue.shade800,
      indicatorColor: Colors.blue.shade800,
      unselectedLabelColor: appBarTheme.foregroundColor,
      overlayColor: MaterialStatePropertyAll(colorScheme.onSurface.withOpacity(0.12)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w500),
      headlineSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
    ),
  );
}

ThemeData get darkTheme {
  final colorScheme = ColorScheme.dark(primary: Colors.blue.shade300);
  final appBarTheme = AppBarTheme(backgroundColor: Colors.blueGrey.shade900, foregroundColor: Colors.white);

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    dividerColor: colorScheme.onSurface.withOpacity(0.12),
    appBarTheme: appBarTheme,
    tabBarTheme: TabBarTheme(
      labelColor: Colors.blue,
      indicatorColor: Colors.blue,
      unselectedLabelColor: appBarTheme.foregroundColor,
      overlayColor: MaterialStatePropertyAll(colorScheme.onSurface.withOpacity(0.12)),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w500),
      headlineSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
    ),
  );
}
