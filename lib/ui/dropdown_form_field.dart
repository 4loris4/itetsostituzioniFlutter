import 'package:flutter/material.dart';

class DropdownFormField<T, Z> extends StatelessWidget {
  final T? value;
  final String title;
  final List<({T value, String name})> items;
  final Widget? hint;
  final void Function(T)? onChanged;

  const DropdownFormField({
    this.value,
    required this.title,
    required this.items,
    this.hint,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
        Expanded(
            child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: hint,
          items: items.map((item) => DropdownMenuItem(value: item.value, child: Text(item.name))).toList(),
          onChanged: onChanged == null
              ? null
              : (value) {
                  if (value != null) onChanged!(value);
                },
        )),
      ],
    );
  }
}
