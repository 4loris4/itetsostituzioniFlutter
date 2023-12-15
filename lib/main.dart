import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itetsostituzioni/data/shared_preferences.dart';
import 'package:itetsostituzioni/data/theme.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/pages/substitutions/substitutions_page.dart';
import 'package:itetsostituzioni/pages/welcome_page.dart';
import 'package:itetsostituzioni/themes.dart';

late final SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.init();
  Intl.systemLocale = "it";

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: "ITET Sostituzioni",
      themeMode: theme,
      theme: lightTheme,
      darkTheme: darkTheme,
      home: user.type == null ? const WelcomePage() : const SubstitutionsPage(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale("it")],
    );
  }
}
