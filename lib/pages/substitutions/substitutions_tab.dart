import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:itetsostituzioni/data/substitutions.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/pages/details_page.dart';
import 'package:itetsostituzioni/utils.dart';

class SubstitutionsTab extends ConsumerWidget {
  final Map<String, List<Substitution>> substitutions;
  final ({String absent, String covered}) itp;

  const SubstitutionsTab(this.substitutions, this.itp, {super.key});

  List<MapEntry<String, List<Substitution>>> getSortedSubstitutions(User user) {
    final list = substitutions.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    //If there is at least a substitution for our selected user, move it to the top
    if (user.name != null && substitutions.containsKey(user.name)) {
      list.removeWhere((item) => item.key == user.name);
      list.insert(0, MapEntry(user.name!, substitutions[user.name]!));
    }

    return list;
  }

  Widget itpTile() {
    return ExpansionTile(
      title: const Text("ITP"),
      children: [
        if (itp.absent.isNotEmpty)
          DetailsPage.detailsTile(
            icon: Icons.perm_identity,
            title: itp.absent,
            trailing: "ITP Assenti",
          ),
        if (itp.covered.isNotEmpty)
          DetailsPage.detailsTile(
            icon: Icons.perm_identity,
            title: itp.covered,
            trailing: "Coperti da ITP",
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final itpNotEmpty = itp.absent.isNotEmpty || itp.covered.isNotEmpty;

    if (substitutions.isNotEmpty || itpNotEmpty) {
      return ListView(
        children: [
          ...getSortedSubstitutions(user).map((group) {
            final personal = group.key == user.name;
            final length = group.value.length;
            return ListTile(
                title: Text(group.key),
                subtitle: Text("$length ${length == 1 ? "sostituzione" : "sostituzioni"}"),
                trailing: personal ? const Icon(Icons.person) : null,
                onTap: () {
                  if (personal) {
                    DefaultTabController.of(context).animateTo(0);
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => DetailsPage(group.key, group.value)));
                  }
                });
          }),
          if (itpNotEmpty) itpTile()
        ],
      );
    }

    return centeredListView(
      Column(
        children: [
          Text("Nessuna sostituzione trovata", style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const Text("Non sono previste sostituzioni per questa giornata!", textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
