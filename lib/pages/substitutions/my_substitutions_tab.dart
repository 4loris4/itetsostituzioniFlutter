import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:itetsostituzioni/data/classes.dart';
import 'package:itetsostituzioni/data/substitutions.dart';
import 'package:itetsostituzioni/data/teachers.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/pages/details_page.dart';
import 'package:itetsostituzioni/utils.dart';

class MySubstitutionsTab extends ConsumerWidget {
  final List<Substitution> mySubstitutions;

  const MySubstitutionsTab(this.mySubstitutions, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isTeacher = user.isTeacher;

    if (user.name != null) {
      if (mySubstitutions.isNotEmpty) return DetailsPage.listView(mySubstitutions, isTeacher, user.name!);

      return centeredListView(
        Column(
          children: [
            Text("Nessuna sostituzione trovata", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            Text("Non sono previste sostituzioni per ${isTeacher ? "te" : "la tua classe"}!", textAlign: TextAlign.center),
          ],
        ),
      );
    }

    final listProvider = isTeacher ? teachersProvider : classesProvider;
    return PadColumn(
      padding: const EdgeInsets.all(24),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(isTeacher ? "Chi sei?" : "Quale classe frequenti?", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
        Text("Per poter utilizzare questa sezione, seleziona ${isTeacher ? "il tuo nome" : "la tua classe"} dalla lista qui sotto!", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        const Text("Potrai cambiare nuovamente questa opzione nelle impostazioni (in alto a destra).", textAlign: TextAlign.center),
        const SizedHeight(16),
        ref.watch(listProvider).unwrapPrevious().when(data: (data) {
          return DropdownButton(
            isExpanded: true,
            hint: Text(isTeacher ? "Scegli un docente..." : "Scegli una classe..."),
            items: data.map((name) => DropdownMenuItem(value: name, child: Text(name))).toList(),
            onChanged: (value) {
              if (value != null) ref.read(userProvider.notifier).name = value;
            },
          );
        }, error: (_, __) {
          return Column(
            children: [
              Text("Impossibile scaricare la lista ${isTeacher ? "dei docenti" : "delle classi"}", style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.red), textAlign: TextAlign.center),
              const SizedHeight(4),
              ElevatedButton(onPressed: () => ref.invalidate(listProvider), child: const Text("Riprova")),
            ],
          );
        }, loading: () {
          return Column(
            children: [
              Text("Caricamento lista ${isTeacher ? "docenti" : "classi"}...", style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center),
              const SizedHeight(4),
              const LinearProgressIndicator(),
            ],
          );
        }),
      ],
    );
  }
}
