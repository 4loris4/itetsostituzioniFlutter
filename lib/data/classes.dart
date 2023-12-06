import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itet_sostituzioni/constants.dart';
import 'package:itet_sostituzioni/main.dart';
import 'package:itet_sostituzioni/pages/substitutions/sostituzioni_page.dart';

final classesProvider = FutureProvider<List<String>>((ref) async {
  List<String> data;
  try {
    final response = await http.get(classesUrl);
    data = List<String>.from(jsonDecode(response.body));
    prefs.setClassesJSON(response.body);
  } catch (_) {
    final savedData = prefs.classesJSON;
    if (savedData == null) rethrow;
    data = List<String>.from(jsonDecode(savedData));
    SostituzioniPage.showSnackBar("Impossibile aggiornare la lista delle classi, riprova più tardi");
  }
  return data;
});