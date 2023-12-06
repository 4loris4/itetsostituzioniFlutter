import 'package:flutter/widgets.dart';

T inlineTry<T>(T Function() tryFunc, T defaultValue) {
  try {
    return tryFunc();
  } catch (_) {
    return defaultValue;
  }
}

Widget centeredListView(Widget child) {
  return LayoutBuilder(
    builder: (context, constraints) => ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: child),
        )
      ],
    ),
  );
}
