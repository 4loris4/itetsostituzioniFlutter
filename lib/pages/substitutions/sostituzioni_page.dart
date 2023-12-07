import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itetsostituzioni/data/substitutions.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/pages/settings_page.dart';
import 'package:itetsostituzioni/pages/substitutions/my_substitutions_tab.dart';
import 'package:itetsostituzioni/pages/substitutions/substitutions_tab.dart';
import 'package:itetsostituzioni/ui/app_bar_fix.dart';
import 'package:itetsostituzioni/utils.dart';

class SostituzioniPage extends ConsumerWidget {
  const SostituzioniPage({super.key});

  static late BuildContext _snackbarContext;

  static showSnackBar(String content) {
    try {
      ScaffoldMessenger.of(_snackbarContext).showSnackBar(SnackBar(content: Text(content)));
    } catch (_) {}
  }

  Widget _scaffold({required BuildContext context, String title = "ITET Sostituzioni", TabBar? tabBar, required Widget body, List<Widget> bottomChildren = const []}) {
    return Scaffold(
      appBar: AppBarFix(
        title: FittedBox(child: Text(title)),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage(), fullscreenDialog: true)),
            tooltip: "Impostazioni",
            icon: const Icon(Icons.settings),
          ),
        ],
        bottom: tabBar,
      ),
      body: Builder(builder: (context) {
        _snackbarContext = context;
        return body;
      }),
      bottomNavigationBar: bottomChildren.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
              color: Theme.of(context).appBarTheme.backgroundColor,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: bottomChildren),
            ),
    );
  }

  Map<String, List<Substitution>> groupSubstitutions(SubstitutionsData substitutionsData, User user) {
    final groups = <String, List<Substitution>>{};
    for (final substitution in substitutionsData.sostituzioni) {
      (groups[user.isTeacher ? substitution.docenteSostituto : substitution.classe] ??= []).add(substitution);
    }

    //If we have set a class, also add congregated substitutions for our class
    if (user.type == UserType.student && user.name != null) {
      for (final substitution in substitutionsData.sostituzioni) {
        if (substitution.classe != user.name && substitution.classe.contains(user.name!)) {
          (groups[user.name!] ??= []).add(substitution);
        }
      }
    }

    return groups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final provider = ref.watch(substitutionsProvider);

    return DefaultTabController(
      initialIndex: user.name == null ? 1 : 0,
      length: 2,
      child: provider.when(
        data: (substitutionsData) {
          final groupedSubstitutions = groupSubstitutions(substitutionsData, user);
          return _scaffold(
              context: context,
              title: DateFormat("'Sostituzioni di' EEEE d MMMM").format(substitutionsData.data),
              tabBar: TabBar(
                tabs: [
                  Tab(child: FittedBox(child: Text(
                    () {
                      if (user.name == null) return user.isTeacher ? "Le mie sostituzioni" : "La mia classe";
                      return "${user.name} ${"(${(groupedSubstitutions[user.name] ?? []).length})"}";
                    }(),
                  ))),
                  Tab(text: user.isTeacher ? "Tutte le sostituzioni" : "Tutte le classi"),
                ],
              ),
              body: TabBarView(
                children: [
                  MySubstitutionsTab(groupedSubstitutions),
                  SubstitutionsTab(groupedSubstitutions, (absent: substitutionsData.itp1, covered: substitutionsData.itp2)),
                ],
              ),
              bottomChildren: [
                if (substitutionsData.loadedFromCache)
                  Container(
                    padding: const EdgeInsets.all(2),
                    color: Colors.redAccent,
                    child: Text("Le sostituzioni potrebbero non essere aggiornate!", style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor), textAlign: TextAlign.center),
                  ),
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(substitutionsData.timestamp, style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor), textAlign: TextAlign.center),
                ),
              ]);
        },
        error: (_, __) {
          return _scaffold(
            context: context,
            body: RefreshIndicator(
              onRefresh: () => ref.refresh(substitutionsProvider.future),
              child: centeredListView(
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Impossibile scaricare le sostituzioni", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red), textAlign: TextAlign.center),
                      const Text("Riprova più tardi", textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        loading: () {
          return _scaffold(context: context, body: const Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }
}
