import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itet_sostituzioni/constants.dart';
import 'package:itet_sostituzioni/main.dart';
import 'package:itet_sostituzioni/pages/substitutions/sostituzioni_page.dart';

final teachersProvider = FutureProvider<List<String>>((ref) async {
  List<String> data;
  try {
    final response = await http.get(teachersUrl);
    data = List<Map<String, dynamic>>.from(jsonDecode(response.body)).map((teacher) => "${teacher["cognome"]} ${teacher["nome"]}").toList();
    prefs.setTeachersJSON(response.body);
  } catch (_) {
    final savedData = prefs.teachersJSON;
    if (savedData == null) rethrow;
    data = List<Map<String, dynamic>>.from(jsonDecode(savedData)).map((teacher) => "${teacher["cognome"]} ${teacher["nome"]}").toList();
    SostituzioniPage.showSnackBar("Impossibile aggiornare la lista dei docenti, riprova più tardi");
  }
  return data;
});
