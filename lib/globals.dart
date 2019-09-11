import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:itetsostituzioni/Utils/Sostituzione.dart';
import 'package:itetsostituzioni/Utils/SostituzioniUser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

const Color blue = Color(0xFF5dade2);
const String downloadURL = "http://istitutopilati.it/gestione_sostituzioni";
final FirebaseMessaging messaging = FirebaseMessaging();
bool hasLoaded = false;
bool isRefreshing = false;
bool downloadError = false;
bool noSostituzioni = false;
String sostituzioniDate = "ITET Sostituzioni";
String sostituzioniTimestamp = "";
List<SostituzioniUser> sostituzioni = List();
String itp1 = "", itp2 = "";
List<String> docenti = List();
List<String> classi = List();
Map<String, dynamic> settings = Map();
Directory dir;
String settingsFileName = "settings", sostituzioniFileName = "sostituzioni", docentiFileName = "docenti", classiFileName = "classi";

Future<String> readFile(String fileName) async {
  File file = File(dir.path + "/" + fileName);

  if(file.existsSync()) {
    return await file.readAsString();
  }
  return "{}";
}

Future<Null> writeFile(String fileName, String data) async {
  File file = File(dir.path + "/" + fileName);

  if(!await file.exists()){
    file.create();
  }
  await file.writeAsString(data);
}

String formatDate(DateTime date) {
  List<String> weekday = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"];
  List<String> month = ["Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre"];
  return "${weekday[date.weekday-1]} ${date.day} ${month[date.month-1]} ${date.year}";
}

Future<Null> loadData() async {
  dir = await getApplicationDocumentsDirectory();
  settings = jsonDecode(await readFile(settingsFileName));
  await loadSostituzioni(false);
}

Future<bool> loadSostituzioni(bool download) async {
  bool downloadError = false;
  var sostituzioniJSON, docentiJSON, classiJSON;

  if (download) {
    http.Response response;
    try { response = await http.get(downloadURL+"/sostituzioni/listaPubblica.json", headers: {"Accept": "application/json"}); } on Exception { downloadError = true; }
    if (response == null) {
      downloadError = true;
    } else {
      sostituzioniJSON = jsonDecode(response.body);
      writeFile(sostituzioniFileName, response.body);
    }

    try { response = await http.get(downloadURL+"/docenti/docenti.json", headers: {"Accept": "application/json"}); } on Exception { downloadError = true; }
    if (response == null) {
      downloadError = true;
    } else {
      docentiJSON = jsonDecode(response.body);
      writeFile(docentiFileName, response.body);
    }

    try { response = await http.get(downloadURL+"/classi/classi.json", headers: {"Accept": "application/json"}); } on Exception { downloadError = true; }
    if (response == null) {
      downloadError = true;
    } else {
      classiJSON = jsonDecode(response.body);
      writeFile(classiFileName, response.body);
    }
  } else {
    sostituzioniJSON = jsonDecode(await readFile(sostituzioniFileName));
    docentiJSON = jsonDecode(await readFile(docentiFileName));
    classiJSON = jsonDecode(await readFile(classiFileName));
  }

  if (!downloadError) {
    if(sostituzioniJSON["sostituzioni"] != null) {
      sostituzioni.clear();
      if(settings["user"] != null) {
        sostituzioni.add(SostituzioniUser(settings["user"]));
      }

      sostituzioniDate = "Sostituzioni di ${formatDate(DateTime.parse(sostituzioniJSON["data"].toString().split("/").reversed.toList().join("-")))}";
      sostituzioniTimestamp = "Pubblicate il ${sostituzioniJSON["timestamp"].toString().split(" ")[0]} alle ${sostituzioniJSON["timestamp"].toString().split(" ")[1]}";

      noSostituzioni = sostituzioniJSON["sostituzioni"].length == 0;
      for (var sostituzioneJSON in sostituzioniJSON["sostituzioni"]) {
        Sostituzione sostituzione = Sostituzione(sostituzioneJSON["docenteSostituto"], sostituzioneJSON["orario"], sostituzioneJSON["classe"], sostituzioneJSON["docenteAssente"], sostituzioneJSON["note"]);
        String user = sostituzioneJSON[settings["docente"] == false ? "classe" : "docenteSostituto"] != " " ? sostituzioneJSON[settings["docente"] == false ? "classe" : "docenteSostituto"] : "";

        if (sostituzioni.indexWhere((a) => a.user == user) == -1) {
          sostituzioni.add(SostituzioniUser(user));
        }
        sostituzioni.firstWhere((a) => a.user == user).add(sostituzione);

        //"Nessun sostituto" come ultimo
        if (sostituzioni.indexWhere((a) => a.user == "") != -1) {
          SostituzioniUser sostituzioniUser = sostituzioni.firstWhere((a) => a.user == "");
          sostituzioni.removeWhere((a) => a.user == "");
          sostituzioni.add(sostituzioniUser);
        }
      }

      //ITP
      itp1 = sostituzioniJSON["itp1"];
      itp2 = sostituzioniJSON["itp2"];
    }

    if(docentiJSON[0] != null) {
      docenti.clear();
      for (var docenteJSON in docentiJSON) {
        docenti.add("${docenteJSON["cognome"]} ${docenteJSON["nome"]}");
      }
    }

    if(classiJSON[0] != null) {
      classi.clear();
      for (var classeJSON in classiJSON) {
        classi.add(classeJSON);
      }
    }
  }

  return downloadError;
}

void updateDatabaseInformation() async {
  String token = await messaging.getToken();

  await Firestore.instance.collection("tokens").where("token", isEqualTo: token).getDocuments().then((result) {
    if(result.documents.length != 1) {
      result.documents.forEach((document) => document.reference.delete());
      Firestore.instance.collection("tokens").add({"token" : token, "docente" : settings["docente"], "user" : settings["user"]});
    }
    else {
      result.documents[0].reference.updateData({"token" : token, "docente" : settings["docente"], "user" : settings["user"]});
    }
  });
}