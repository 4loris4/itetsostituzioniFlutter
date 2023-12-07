import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:itetsostituzioni/data/shared_preferences.dart';
import 'package:itetsostituzioni/data/user.dart';
import 'package:itetsostituzioni/pages/substitutions/sostituzioni_page.dart';
import 'package:itetsostituzioni/pages/welcome_page.dart';
import 'package:itetsostituzioni/themes.dart';

//TODO apk, aab
//TODO timeout?
//TODO settings theme
//TODO check api level... (old and new app)

late final SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.init();
  Intl.systemLocale = "it";

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));

  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return MaterialApp(
      title: "ITET Sostituzioni",
      theme: lightTheme,
      darkTheme: darkTheme,
      home: user.type == null ? const WelcomePage() : const SostituzioniPage(),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale("it")],
    );
  }
}
