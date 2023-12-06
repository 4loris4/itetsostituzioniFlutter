import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_series/flutter_series.dart';
import 'package:itet_sostituzioni/data/user.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: PadColumn(
          padding: const EdgeInsets.all(16),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Benvenuto nell'app!", style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
            Text("Prima di iniziare, scegli se vuoi utilizzare l'app come studente o come docente.", style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
            const Text("Potrai cambiare nuovamente questa opzione nelle impostazioni (in alto a destra).", textAlign: TextAlign.center),
            const SizedHeight(24),
            IntrinsicWidth(
              child: PadColumn(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(onPressed: () => ref.read(userProvider.notifier).type = UserType.teacher, child: const Text("Sono un docente")),
                  ElevatedButton(onPressed: () => ref.read(userProvider.notifier).type = UserType.student, child: const Text("Sono uno studente")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
