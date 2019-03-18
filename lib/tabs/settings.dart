import 'package:flutter/material.dart';
import '../globals.dart';
import '../utils/sostituzione.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart' as urlLauncher;

class Settings extends StatefulWidget{
  @override
  SettingsState createState() => new SettingsState();
}

class SettingsState extends State<Settings> {

  String dropdownValueUser;
  String dropdownValueRole;
  BuildContext snackbarContextSettings;

  void openWebsite(String url) async {
    if(await urlLauncher.canLaunch(url)) {
      urlLauncher.launch(url);
    }
  }

  @override
  void initState() {
    super.initState();
    dropdownValueRole = settings["role"];
    if (docenteExists(settings["user"]))
      dropdownValueUser = settings["user"];
  }

  void userChosen() {
    sostituzioni.removeWhere((sostituzione) => sostituzione.length==0);
    sostituzioniClassi.removeWhere((sostituzione) => sostituzione.length==0);
    settings["user"] = dropdownValueUser;
    if(settings["role"]=="Studente"){
      if (sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == settings["user"]) == -1) {
        sostituzioniClassi.add(new SostituzioneClasse(settings["user"])); //Aggiungi un oggetto SostituzioneClasse per la classe selezionata (Se già non esisteva)
        sostituzioniClassi.sort((a, b) => a.classe.compareTo(b.classe)); //Ordina i prof sostituti per nome
      }
    }
    else {
      settings["user"] = dropdownValueUser;
      if (sostituzioni.indexWhere((sostituzione) => sostituzione.profSostituto == settings["user"]) == -1) {
        sostituzioni.add(new SostituzioneDocente(settings["user"])); //Aggiungi un oggetto SostituzioneDocente per il docente selezionato (Se già non esisteva)
        sostituzioni.sort((a, b) => a.profSostituto.compareTo(b.profSostituto)); //Ordina i prof sostituti per nome
      }
    }

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

    setState(() {
      saveToFile(settingsFile, json.encode(settings));
    });

    updateDatabaseInformation();
    Scaffold.of(snackbarContextSettings).showSnackBar(new SnackBar(
      content: new Text("Impostazioni salvate."),
      duration: Duration(milliseconds: 750),
    ));
  }

  void roleChosen(){
    setState(() {
      settings["role"] = dropdownValueRole;
      settings["user"] = null;
      dropdownValueUser = null;
      sostituzioni.removeWhere((sostituzione) => sostituzione.length==0);
      sostituzioniClassi.removeWhere((sostituzione) => sostituzione.length==0);
      saveToFile(settingsFile, json.encode(settings));
    });

    updateDatabaseInformation();
    Scaffold.of(snackbarContextSettings).showSnackBar(new SnackBar(
      content: new Text("Impostazioni salvate."),
      duration: Duration(milliseconds: 750),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blueGrey,
          title: new Text("Impostazioni"),
        ),
        body: new Stack(
          children: <Widget>[
            new ListView(
              children: <Widget>[
                new Divider(),
                new ListTile(
                  title: new Text("Utente", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 27.5)),
                ),
                new ListTile(
                  title: new Text("Ruolo"),
                  trailing: new DropdownButton(
                    hint: new Text("Scegli un ruolo..."),
                    value: dropdownValueRole,
                    items: [
                      new DropdownMenuItem(value: "Docente", child: new Text("Docente")),
                      new DropdownMenuItem(value: "Studente", child: new Text("Studente")),
                    ],
                    onChanged: (var chosen) {
                      setState((){dropdownValueRole = chosen; roleChosen();});
                    },
                  ),
                ),
                new ListTile(
                  title: new Text(settings["role"]=="Studente" ? "Classe" : "Docente"),
                  trailing: new DropdownButton(
                    value: dropdownValueUser,
                    iconSize: (docenti.length == 0 ||
                        docenti[0].value == "!error") ? 0.0 : 24.0,
                    hint: new Text(
                      ((settings["role"]=="Studente" && dataError && classi.length==0) || (settings["role"]=="Docente" && dataError && docenti.length==0)) ? "Problema di connessione" :
                      ((settings["role"]=="Docente" && docenti.length==0) || (settings["role"]=="Studente" && classi.length==0)) ?
                      "Caricamento in corso..." :
                      settings["role"]=="Studente" ?
                      "Scegli una classe..." : "Scegli un docente...",
                      style: new TextStyle(
                        color: ((settings["role"]=="Studente" && dataError && classi.length==0) || (settings["role"]=="Docente" && dataError && docenti.length==0)) ? Colors.red : Colors.black,
                        fontWeight: ((settings["role"]=="Studente" && dataError && classi.length==0) || (settings["role"]=="Docente" && dataError && docenti.length==0)) ? FontWeight.bold : FontWeight
                            .normal,
                        fontSize: 16.0,
                      ),
                    ),
                    items:
                    settings["role"]=="Studente" && classi.length != 0 ? classi :
                    settings["role"]=="Docente" && docenti.length != 0 ? docenti :
                    [new DropdownMenuItem(value: 0, child: new Text(""))],
                    onChanged: (var chosen) {
                      setState((){dropdownValueUser = chosen; userChosen();});
                    },
                  ),
                ),
                new Divider(),
              ],
            ),
            new Align(
              alignment: Alignment.bottomLeft,
              child: new SizedBox(
                width: double.infinity,
                child: new Padding(
                  padding: EdgeInsets.all(20),
                  child: new RaisedButton(
                    onPressed: () => openWebsite("http://itetsostituzioni.altervista.org/privacyPolicy.html"),
                    child: new Text("Privacy Policy"),
                  ),
                ),
              )
            )
          ],
        ),
      bottomNavigationBar: new Builder(builder: (BuildContext context2) { //Snackbar
        snackbarContextSettings = context2;
        return new Container(width: 0.0, height: 0.0,);
      }
      ),
    );
  }
}