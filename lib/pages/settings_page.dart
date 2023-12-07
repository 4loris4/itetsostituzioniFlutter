import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:itetsostituzioni/data/classes.dart';
import 'package:itetsostituzioni/data/teachers.dart';
import 'package:itetsostituzioni/data/theme.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/ui/app_bar_fix.dart';
import 'package:itetsostituzioni/ui/dropdown_form_field.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final user = ref.watch(userProvider);
    final isTeacher = user.isTeacher;
    final listProvider = isTeacher ? teachersProvider : classesProvider;

    return Scaffold(
      appBar: AppBarFix(title: const Text("Impostazioni")),
      body: SingleChildScrollView(
        child: PadColumn(
          spacing: 8,
          padding: EdgeInsets.only(left: 16, right: 8, bottom: MediaQuery.of(context).padding.bottom + 8, top: 8),
          children: [
            DropdownFormField(
              value: theme,
              title: "Tema",
              items: const [
                (value: ThemeMode.system, name: "Dispositivo"),
                (value: ThemeMode.light, name: "Chiaro"),
                (value: ThemeMode.dark, name: "Scuro"),
              ],
              onChanged: (theme) => ref.read(themeProvider.notifier).theme = theme,
            ),
            DropdownFormField(
              value: user.type,
              title: "Ruolo",
              items: const [
                (value: UserType.teacher, name: "Docente"),
                (value: UserType.student, name: "Studente"),
              ],
              onChanged: (type) => ref.read(userProvider.notifier).type = type,
            ),
            Row(
              children: [
                Expanded(child: Text(isTeacher ? "Docente" : "Classe", style: Theme.of(context).textTheme.bodyLarge)),
                Expanded(
                  child: ref.watch(listProvider).unwrapPrevious().when(
                    data: (data) {
                      return DropdownButton<String>(
                        value: user.name,
                        isExpanded: true,
                        hint: Text(isTeacher ? "Scegli un docente..." : "Scegli una classe..."),
                        items: data.map((name) => DropdownMenuItem(value: name, child: FittedBox(child: Text(name)))).toList(),
                        onChanged: (value) {
                          if (value != null) ref.read(userProvider.notifier).name = value;
                        },
                      );
                    },
                    error: (_, __) {
                      return Row(
                        children: [
                          Expanded(child: Text("Errore", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red))),
                          IconButton(onPressed: () => ref.invalidate(listProvider), tooltip: "Riprova", icon: const Icon(Icons.refresh)),
                        ],
                      );
                    },
                    loading: () {
                      return Row(
                        children: [
                          Expanded(child: Text("Caricamento...", style: Theme.of(context).textTheme.labelLarge)),
                          const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
