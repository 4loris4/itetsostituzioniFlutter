library globals;
import 'dart:async';
import 'package:flutter/material.dart';
import './utils/sostituzione.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './main.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

List<SostituzioneDocente> sostituzioni = new List();
List<SostituzioneClasse> sostituzioniClassi = new List();
List<DropdownMenuItem> docenti = new List();
List<DropdownMenuItem> classi = new List();
Map<String,dynamic> settings = new Map();
String day = "ITET Sostituzioni";
String updateDay = "";
BuildContext snackbarContext;
bool dataError = false;
bool downloadError = false;
bool noSostituzioni = false;
bool personalVisited = false;
Directory dir;
File sostituzioniFile;
File docentiFile;
File classiFile;
File settingsFile;
final String sostituzioniFileName = "sostituzioniITET.json";
final String docentiFileName = "docentiITET.json";
final String classiFileName = "classiITET.json";
final String settingsFileName = "settingsITET.json";
final String sostituzioniURL = Uri.encodeFull("https://www.istitutopilati.it/gestione_sostituzioni/lista.json");
final String docentiURL = Uri.encodeFull("https://www.istitutopilati.it/gestione_sostituzioni/listadocenti.json");
final String classiURL = Uri.encodeFull("https://www.istitutopilati.it/gestione_sostituzioni/classi.json");

String capitalize(String string){
  if(string.length==0)
    return string;
  string = string[0].toUpperCase()+string.substring(1);
  for(int i=1;i<string.length-1;i++)
    if(string[i-1]==' ')
      string = string.substring(0,i)+string[i].toUpperCase()+string.substring(i+1);
  return string;
}

int sostituzioneIndex(String profSostituto){
  for(int i=0;i<sostituzioni.length;i++)
    if(sostituzioni[i].profSostituto == profSostituto)
      return i;
  return -1;
}

void saveToFile(File file, String content){
  if(!file.existsSync()){
    file.createSync();
  }
  file.writeAsStringSync(content);
}

bool docenteExists(String docente){
  if(docente==null || docenti==null || docenti.length==0)
    return false;
  for(var docenteItem in docenti) {
    if (docenteItem.value == docente)
      print(docenteItem.toString() + "\n" + docenteItem.value + "\n" + docente);
    return true;
  }
  return false;
}

bool classeExists(String classe){
  if(classe==null || classi==null || classi.length==0)
    return false;
  for(var classeItem in classi) {
    if (classeItem.value == classe)
      print(classeItem.toString() + "\n" + classeItem.value + "\n" + classe);
    return true;
  }
  return false;
}

Future<Null> loadData() async {
  //Ottiene i percorsi dei file e delle directory, carica i vari file
  print("Getting directory and files locations");
  dir = await getApplicationDocumentsDirectory();
  sostituzioniFile = new File(dir.path + "/" + sostituzioniFileName);
  docentiFile = new File(dir.path + "/" + docentiFileName);
  classiFile = new File(dir.path + "/" + classiFileName);
  settingsFile = new File(dir.path + "/" + settingsFileName);

  //Carica impostazioni da file
  if(settingsFile.existsSync())
    settings = json.decode(settingsFile.readAsStringSync());

  Map datiSostituzioni;
  List datiDocenti;
  List datiClassi;

  //Carica sostituzioni da file
  if(sostituzioniFile.existsSync()){
    print("sostituzioniFile found, reading...");
    datiSostituzioni = json.decode(sostituzioniFile.readAsStringSync());

    day = "Sostituzioni di " + datiSostituzioni["data_stringa"];
    updateDay = "Pubblicate il " + datiSostituzioni["timestamp"].toString().substring(0, datiSostituzioni["timestamp"].toString().indexOf(" ")) + " alle" + datiSostituzioni["timestamp"].toString().substring(datiSostituzioni["timestamp"].toString().indexOf(" ")); //Pubblicate il DATA alle ORA

    sostituzioni.clear();
    sostituzioniClassi.clear();
    if(settings["user"]!=null) {
      if(settings["role"]=="Studente")
        sostituzioniClassi.add(new SostituzioneClasse(settings["user"]));
      else
        sostituzioni.add(new SostituzioneDocente(settings["user"]));
    }
    for (Map sostituzioneJSON in datiSostituzioni["valori"]) { //Cicla tutte le sostituzioni nel JSON
      if(sostituzioneJSON["Prof_Sostituto"]=="!nosostituzioni"){
        noSostituzioni=true;
        break;
      }
      if(sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == sostituzioneJSON["Prof_Sostituto"])==-1)
        sostituzioni.add(new SostituzioneDocente(sostituzioneJSON["Prof_Sostituto"])); //Se non esiste ancora un oggetto per il prof sostituto, creane uno
      sostituzioni[sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == sostituzioneJSON["Prof_Sostituto"])]
          .addSostituzione( //Aggiungi la sostituzione all'oggetto del prof sostituto
          new Sostituzione(
            sostituzioneJSON["Prof_Sostituto"],
            sostituzioneJSON["Orario"],
            sostituzioneJSON["Classe"],
            sostituzioneJSON["Prof_Assente"],
            sostituzioneJSON["Note"]
          )
      );
    }
    for (Map sostituzioneJSON in datiSostituzioni["valori"]) { //Cicla tutte le sostituzioni nel JSON
      if(sostituzioneJSON["Classe"]=="!nosostituzioni"){
        noSostituzioni=true;
        break;
      }
      if(sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == sostituzioneJSON["Classe"])==-1)
        sostituzioniClassi.add(new SostituzioneClasse(sostituzioneJSON["Classe"])); //Se non esiste ancora un oggetto per la classe, creane uno
      sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == sostituzioneJSON["Classe"])]
          .addSostituzione( //Aggiungi la sostituzione all'oggetto del prof sostituto
          new Sostituzione(
              sostituzioneJSON["Prof_Sostituto"],
              sostituzioneJSON["Orario"],
              sostituzioneJSON["Classe"],
              sostituzioneJSON["Prof_Assente"],
              sostituzioneJSON["Note"]
          )
      );
    }
  }
  else{
    print("No sostituzioniFile available");
  }

  //Carica lista docenti da file
  if(docentiFile.existsSync()){
    print("docentiFile found, reading...");
    datiDocenti = json.decode(docentiFile.readAsStringSync());

    docenti.clear();
    for (Map docente in datiDocenti)
      docenti.add(
          new DropdownMenuItem(
              value: capitalize(docente["Docente"]),
              child: new Text(capitalize(docente["Docente"]))
          )
      );
  }
  else{
    print("No docentiFile available");
  }

  //Carica lista classi da file
  if(classiFile.existsSync()){
    print("classiFile found, reading...");
    datiClassi = json.decode(classiFile.readAsStringSync());

    classi.clear();
    for (Map classe in datiClassi)
      classi.add(
          new DropdownMenuItem(
              value: classe["Classe"],
              child: new Text(classe["Classe"])
          )
      );
  }
  else{
    print("No classiFile available");
  }

  // ignore: invalid_use_of_protected_member
  appState.setState((){
    sostituzioni.sort((a, b) => a.profSostituto.compareTo(b.profSostituto)); //Ordina i prof sostituti per nome
    sostituzioniClassi.sort((a, b) => a.classe.compareTo(b.classe)); //Ordina le classi con sostituzioni per nome
    docenti.sort((a, b) => a.value.compareTo(b.value)); //Ordina la lista dei prof
    classi.sort((a, b) => a.value.compareTo(b.value)); //Ordina la lista delle classi

    //Swap
    if(settings["role"]=="Docente" && settings["user"]!=null && sostituzioni.length>0) {
      SostituzioneDocente tmp = sostituzioni.firstWhere((sostituzione) => sostituzione.profSostituto == settings["user"]);
      sostituzioni[sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == settings["user"])] = sostituzioni[0];
      sostituzioni[0] = tmp;
    }
    else if(settings["role"]=="Studente" && settings["user"]!=null && sostituzioniClassi.length>0) {
      SostituzioneClasse tmp = sostituzioniClassi.firstWhere((sostituzione) => sostituzione.classe == settings["user"]);
      sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == settings["user"])] = sostituzioniClassi[0];
      sostituzioniClassi[0] = tmp;
    }

  });
}

Future<bool> getData() async {
  Map datiSostituzioni;
  List datiDocenti;
  List datiClassi;
  downloadError=false;
  // ignore: invalid_use_of_protected_member
  appState.setState((){
    dataError = false;
    noSostituzioni = false;
  });

  //Download lista sostituzioni
  http.Response responseSostituzioni;
  try {
    responseSostituzioni = await http.get(sostituzioniURL, headers: {"Accept": "application/json"});
  }
  on Exception{
    downloadError=true;
  }
  on Error{
    downloadError=true;
  }

  //Download lista docenti
  http.Response responseDocenti;
  try{
    responseDocenti = await http.get(docentiURL, headers: {"Accept": "application/json"});
  }
  on Exception{
    downloadError=true;
  }
  on Error{
    downloadError=true;
  }

  //Download lista classi
  http.Response responseClassi;
  try{
    responseClassi = await http.get(classiURL, headers: {"Accept": "application/json"});
  }
  on Exception{
    downloadError=true;
  }
  on Error{
    downloadError=true;
  }

  if(responseSostituzioni==null){ //Controlla se la lista delle sostituzioni è stata scaricata correttamente
    if(settings["role"]=="Studente" && sostituzioniClassi.length==0 || (settings["user"]!=null && sostituzioniClassi.length==1) || (settings["role"]=="Docente" && sostituzioni.length==0 || (settings["user"]!=null && sostituzioni.length==1))) //Non è stato possibile scaricare le sostituzioni
      dataError=true;
    print("Error when downloading sostituzioni");
  }
  else{
    datiSostituzioni = json.decode(responseSostituzioni.body);

    day = "Sostituzioni di " + datiSostituzioni["data_stringa"];
    updateDay = "Pubblicate il " + datiSostituzioni["timestamp"].toString().substring(0, datiSostituzioni["timestamp"].toString().indexOf(" ")) + " alle" + datiSostituzioni["timestamp"].toString().substring(datiSostituzioni["timestamp"].toString().indexOf(" ")); //Pubblicate il DATA alle ORA

    sostituzioni.clear();
    sostituzioniClassi.clear();
    if(settings["user"]!=null) {
      if(settings["role"]=="Studente")
        sostituzioniClassi.add(new SostituzioneClasse(settings["user"]));
      else
        sostituzioni.add(new SostituzioneDocente(settings["user"]));
    }
    for (Map sostituzioneJSON in datiSostituzioni["valori"]) { //Cicla tutte le sostituzioni nel JSON
      if(sostituzioneJSON["Prof_Sostituto"]=="!nosostituzioni"){
        noSostituzioni=true;
        break;
      }
      if(sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == sostituzioneJSON["Prof_Sostituto"])==-1)
        sostituzioni.add(new SostituzioneDocente(sostituzioneJSON["Prof_Sostituto"])); //Se non esiste ancora un oggetto per il prof sostituto, creane uno
      sostituzioni[sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == sostituzioneJSON["Prof_Sostituto"])]
          .addSostituzione( //Aggiungi la sostituzione all'oggetto del prof sostituto
          new Sostituzione(
              sostituzioneJSON["Prof_Sostituto"],
              sostituzioneJSON["Orario"],
              sostituzioneJSON["Classe"],
              sostituzioneJSON["Prof_Assente"],
              sostituzioneJSON["Note"]
          )
      );
    }
    for (Map sostituzioneJSON in datiSostituzioni["valori"]) { //Cicla tutte le sostituzioni nel JSON
      if(sostituzioneJSON["Classe"]=="!nosostituzioni"){
        noSostituzioni=true;
        break;
      }
      if(sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == sostituzioneJSON["Classe"])==-1)
        sostituzioniClassi.add(new SostituzioneClasse(sostituzioneJSON["Classe"])); //Se non esiste ancora un oggetto per la classe, creane uno
      sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == sostituzioneJSON["Classe"])]
          .addSostituzione( //Aggiungi la sostituzione all'oggetto del prof sostituto
          new Sostituzione(
              sostituzioneJSON["Prof_Sostituto"],
              sostituzioneJSON["Orario"],
              sostituzioneJSON["Classe"],
              sostituzioneJSON["Prof_Assente"],
              sostituzioneJSON["Note"]
          )
      );
    }
    print("sostituzioni downloaded successfully, saving to file...");
    saveToFile(sostituzioniFile, json.encode(datiSostituzioni));
  }

  if(responseDocenti==null){ //Controlla se la lista dei docenti è stata scaricata correttamente
    if(docenti.length==0) //Non è stato possibile scaricare la lista dei docenti
      dataError=true;
    print("Error when downloading docenti");
  }
  else{
    datiDocenti = json.decode(responseDocenti.body);

    docenti.clear();
    for (Map docente in datiDocenti)
      docenti.add(
          new DropdownMenuItem(
              value: capitalize(docente["Docente"]),
              child: new Text(capitalize(docente["Docente"]))
          )
      );
    print("docenti downloaded successfully, saving to file...");
    saveToFile(docentiFile, json.encode(datiDocenti));
  }

  if(responseClassi==null){ //Controlla se la lista delle classi è stata scaricata correttamente
    if(classi.length==0) //Non è stato possibile scaricare la lista delle classi
      dataError=true;
    print("Error when downloading classi");
  }
  else{
    datiClassi = json.decode(responseClassi.body);

    classi.clear();
    for (Map classe in datiClassi)
      classi.add(
          new DropdownMenuItem(
              value: classe["Classe"],
              child: new Text(classe["Classe"])
          )
      );
    print("classi downloaded successfully, saving to file...");
    saveToFile(classiFile, json.encode(datiClassi));
  }

  // ignore: invalid_use_of_protected_member
  appState.setState((){
    sostituzioni.sort((a, b) => a.profSostituto.compareTo(b.profSostituto)); //Ordina i prof sostituti per nome
    sostituzioniClassi.sort((a, b) => a.classe.compareTo(b.classe)); //Ordina le classi con sostituzioni per nome
    docenti.sort((a, b) => a.value.compareTo(b.value)); //Ordina la lista dei prof
    classi.sort((a, b) => a.value.compareTo(b.value)); //Ordina la lista delle classi

    //Swap
    if(settings["role"]=="Docente" && settings["user"]!=null && sostituzioni.length>0) {
      SostituzioneDocente tmp = sostituzioni.firstWhere((sostituzione) => sostituzione.profSostituto == settings["user"]);
      sostituzioni[sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == settings["user"])] = sostituzioni[0];
      sostituzioni[0] = tmp;
    }
    else if(settings["role"]=="Studente" && settings["user"]!=null && sostituzioniClassi.length>0) {
      SostituzioneClasse tmp = sostituzioniClassi.firstWhere((sostituzione) => sostituzione.classe == settings["user"]);
      sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == settings["user"])] = sostituzioniClassi[0];
      sostituzioniClassi[0] = tmp;
    }

    if((docenteExists(settings["user"]) || classeExists(settings["user"])) && !personalVisited)
      controller.animateTo(0);
  });

  if(downloadError) {
    Scaffold.of(snackbarContext).showSnackBar(new SnackBar(
      content: new Text("Impossibile aggiornare i dati.\nVerifica la tua connessione ad Internet o riprova più tardi."),
      duration: Duration(milliseconds: 3500),
    ));
    return false;
  }
  return true;
}