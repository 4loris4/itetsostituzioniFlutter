import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:itet_sostituzioni/constants.dart';
import 'package:itet_sostituzioni/main.dart';
import 'package:itet_sostituzioni/pages/substitutions/sostituzioni_page.dart';

@immutable
class Substitution {
  final String docenteSostituto;
  final int orario;
  final String classe;
  final String docenteAssente;
  final String note;

  const Substitution({
    required this.docenteSostituto,
    required this.orario,
    required this.classe,
    required this.docenteAssente,
    required this.note,
  });

  factory Substitution.fromJson(Map<String, dynamic> json) {
    return Substitution(
      docenteSostituto: json["docenteSostituto"],
      orario: json["orario"],
      classe: json["classe"],
      docenteAssente: json["docenteAssente"],
      note: json["note"],
    );
  }
}

@immutable
class SubstitutionsData {
  final DateTime data;
  final String timestamp;
  final List<Substitution> sostituzioni;
  final String itp1;
  final String itp2;
  final bool loadedFromCache;

  const SubstitutionsData({
    required this.data,
    required this.timestamp,
    required this.sostituzioni,
    required this.itp1,
    required this.itp2,
    this.loadedFromCache = false,
  });

  factory SubstitutionsData.fromJson(Map<String, dynamic> json, [bool loadedFromCache = false]) {
    final timestamp = (json["timestamp"] as String).split(" ");
    return SubstitutionsData(
      data: DateTime.parse((json["data"] as String).split("/").reversed.join("-")),
      timestamp: "Pubblicate il ${timestamp[0]} alle ${timestamp[1]}",
      sostituzioni: List<Map<String, dynamic>>.from(json["sostituzioni"]).map((json) => Substitution.fromJson(json)).toList(),
      itp1: json["itp1"] ?? "",
      itp2: json["itp2"] ?? "",
      loadedFromCache: loadedFromCache,
    );
  }
}

final substitutionsProvider = FutureProvider<SubstitutionsData>((ref) async {
  SubstitutionsData data;
  try {
    final response = await http.get(substitutionsUrl);
    /* final response = await http.get(Uri.parse("http://192.168.1.108:5500/listaPubblica.json")); */ //TODO remove, do some testing
    data = SubstitutionsData.fromJson(jsonDecode(response.body));
    prefs.setSubstitutionsJSON(response.body);
  } catch (_) {
    final savedData = prefs.substitutionsJSON;
    if (savedData == null) rethrow;
    data = SubstitutionsData.fromJson(jsonDecode(savedData), true);
    SostituzioniPage.showSnackBar("Impossibile aggiornare le sostituzioni, riprova più tardi");
  }
  return data;
});
