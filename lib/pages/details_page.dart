import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itetsostituzioni/data/substitutions.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/ui/app_bar_fix.dart';

const List<String> timetables = ["07:50 - 08:40", "08:40 - 09:30", "09:30 - 10:20", "10:30 - 11:20", "11:20 - 12:10", "12:10 - 13:00", "13:30 - 14:20", "14:20 - 15:10", "15:10 - 16:00", "16:00 - 16:50"];

class DetailsPage extends ConsumerWidget {
  final String user;
  final List<Substitution> substitutions;

  const DetailsPage(this.user, this.substitutions, {super.key});

  static Widget detailsTile({required IconData icon, required String title, required String trailing}) {
    return ListTile(
      visualDensity: const VisualDensity(vertical: -2.5),
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(trailing),
    );
  }

  static ListView listView(List<Substitution> substitutions, bool isTeacher, String user) {
    return ListView(
      children: (substitutions..sort((a, b) => a.orario.compareTo(b.orario))).map((substitution) {
        return ExpansionTile(
          title: Text("${substitution.orario}° ora${!isTeacher && user != substitution.classe ? " (${substitution.classe})" : ""}"),
          subtitle: Text(timetables[substitution.orario - 1]),
          children: [
            detailsTile(
              icon: isTeacher ? Icons.person : Icons.perm_identity,
              title: substitution.docenteAssente,
              trailing: "Assente",
            ),
            if (isTeacher)
              detailsTile(
                icon: Icons.room,
                title: substitution.classe,
                trailing: "Classe",
              )
            else
              detailsTile(
                icon: Icons.person,
                title: substitution.docenteSostituto,
                trailing: "Sostituto",
              ),
            if (substitution.note.trim().isNotEmpty)
              detailsTile(
                icon: Icons.assignment,
                title: substitution.note,
                trailing: "Note",
              ),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTeacher = ref.watch(userProvider).isTeacher;

    return Scaffold(
      appBar: AppBarFix(title: Text("Sostituzioni ${isTeacher ? "di" : "della classe"} $user")),
      body: listView(substitutions, isTeacher, user),
    );
  }
}
