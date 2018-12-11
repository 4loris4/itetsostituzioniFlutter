import 'package:flutter/material.dart';
import '../utils/sostituzione.dart';
import '../globals.dart';
import 'dart:convert';

class SostituzioniPersonal extends StatefulWidget{
  @override
  SostituzioniPersonalState createState() => new SostituzioniPersonalState();
}

class SostituzioniPersonalState extends State<SostituzioniPersonal>{

  String dropdownValue;

  void userChosen() {
    sostituzioni.removeWhere((sostituzione) => sostituzione.length==0);
    sostituzioniClassi.removeWhere((sostituzione) => sostituzione.length==0);
    settings["user"] = dropdownValue;
    if(settings["role"]=="Studente"){
      if (sostituzioniClassi.indexWhere((sostituzione) => sostituzione.classe == settings["user"]) == -1) {
        sostituzioniClassi.add(new SostituzioneClasse(settings["user"])); //Aggiungi un oggetto SostituzioneClasse per la classe selezionata (Se già non esisteva)
        sostituzioniClassi.sort((a, b) => a.classe.compareTo(b.classe)); //Ordina i prof sostituti per nome
      }
    }
    else {
      settings["user"] = dropdownValue;
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
    dropdownValue = null;
  }

  @override
  Widget build(BuildContext context) {
    if(settings["user"]!=null && (((settings["role"]=="Studente" && sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])==-1)||(settings["role"]=="Docente" && sostituzioni.indexWhere((sostituzione)=>sostituzione.profSostituto==settings["user"])==-1)) || (dataError && ((settings["role"]=="Studente" && sostituzioniClassi.length<=1) || (settings["role"]=="Docente" && sostituzioni.length<=1))))){
      return new Scaffold(
        appBar: new AppBar(backgroundColor: Colors.blueGrey, title: new Center(
            child: new FittedBox(
                child: new Text(settings["role"]=="Studente" ? "Sostituzioni della classe " + settings["user"] : "Sostituzioni di " + settings["user"]),
                fit: BoxFit.scaleDown
            ),
          )
        ),
        body: new Stack(
            children: <Widget>[
              new RefreshIndicator(
                child: new ListView(),
                onRefresh: ()async{await getData();},
              ),
              new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Problema di connessione",
                          textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0)),
                      new Padding(padding: new EdgeInsets.only(top: 5.0)),
                      new Text("Impossibile scaricare le sostituzioni",
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0)),
                    ],
                  )
              ),
            ],
        )
      );
    }
    if(settings["role"]=="Studente"){
      if(classeExists(settings["user"])){ //Modalità studente - Mostra sostituzioni classe
        return new Scaffold(
          appBar: new AppBar(backgroundColor: Colors.blueGrey, title: new Center(child: new Text("Sostituzioni della classe " + settings["user"]))),
          body: new Stack(
            children: <Widget>[
              new RefreshIndicator(
                child: new ListView.builder(
                  itemCount: (sostituzioniClassi==null || sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])==-1)? 0 : sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].length*2+1,
                  itemBuilder: (BuildContext context, int index){
                    if(index.isEven)
                      return new Divider(height: 8.0);
                    return new ExpansionTile(
                      title: new ListTile(
                        title: new Text(sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].sostituzione(index~/2).ora),
                        subtitle: new Text(sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].sostituzione(index~/2).orario),
                      ),
                      children: <Widget>[
                        new Divider(height: 0.0),
                        new ListTile(
                          dense: true,
                          leading: new Icon(Icons.perm_identity),
                          title: new Text(sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].sostituzione(index~/2).profAssente),
                          trailing: new Text("Assente", style: new TextStyle(fontSize: 10.0)),
                        ),
                        new Divider(height: 0.0),
                        new ListTile(
                          dense: true,
                          leading: new Icon(Icons.person),
                          title: new Text(sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].sostituzione(index~/2).profSostituto),
                          trailing: new Text("Sostituto", style: new TextStyle(fontSize: 10.0)),
                        ),
                        new Divider(height: 0.0),
                        sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].sostituzione(index~/2).note=="" ? new Column() :
                        new ListTile(
                          dense: true,
                          leading: new Icon(Icons.assignment),
                          title: new Text(sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].sostituzione(index~/2).note),
                        ),
                        new Divider(height: 0.0),
                      ],
                    );
                  },
                ),
                onRefresh: ()async{await getData();},
              ),
              sostituzioniClassi[sostituzioniClassi.indexWhere((sostituzione)=>sostituzione.classe==settings["user"])].length==0 ? new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Nessuna sostituzione trovata", textAlign: TextAlign.center, style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0)),
                      new Padding(padding: new EdgeInsets.only(top: 5.0)),
                      new Text("Non sono previste sostituzioni per la tua classe!", textAlign: TextAlign.center, style: new TextStyle(fontSize: 14.0)),
                    ],
                  )
              ) : new Center(),
            ],
          ),
        );
      }
      else { //Modalità studente - Classe non selezionata
        return new Scaffold(
            body: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text("Quale classe frequenti?", textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30.0)),
                  new Padding(padding: new EdgeInsets.only(top: 20.0)),
                  new Text(
                      "Prima di poter utilizzare questa sezione,\ndevi selezionare la tua classe dalla lista qui sotto!",
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 16.0)),
                  new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 12.5),
                    child: new DropdownButton(
                      value: dropdownValue,
                      iconSize: (classi.length == 0 ||
                          classi[0].value == "!error") ? 0.0 : 24.0,
                      hint: new Text(
                        dataError && classi.length==0 ? "Problema di connessione" : classi.length ==
                            0
                            ? "Caricamento in corso..."
                            : "Scegli una classe...",
                        style: new TextStyle(
                          color: dataError && classi.length==0 ? Colors.red : Colors.black,
                          fontWeight: dataError && classi.length==0 ? FontWeight.bold : FontWeight
                              .normal,
                          fontSize: 16.0,
                        ),
                      ),
                      items: classi.length == 0
                          ? [new DropdownMenuItem(value: 0, child: new Text(""))]
                          : classi,
                      onChanged: (var chosen) {
                        setState(() => dropdownValue = chosen);
                      },
                    ),
                  ),
                  new Text(
                      "Potrai cambiare nuovamente questa opzione\nnelle impostazioni (in alto a destra).",
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 13.0)),
                  new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 20.0),
                    child: new IconButton(iconSize: 40.0,
                        onPressed: dataError && classi.length==0 ? getData : classi.length == 0 ? null : dropdownValue == null ? null : userChosen,
                        icon: new Icon( dataError && classi.length==0 ? Icons.refresh : classi.length == 0 ? Icons.watch_later : Icons.done)
                    ),
                  ),
                ],
              ),
            )
        );
      }
    }
    else {
      if (docenteExists(settings["user"])) { //Modalità docente - Mostra sostituzioni docente
        return new Scaffold(
          appBar: new AppBar(backgroundColor: Colors.blueGrey,
              title: new Center(
                  child: new Text("Sostituzioni di " + settings["user"]))),
          body: new Stack(
            children: <Widget>[
              new RefreshIndicator(
                child: new ListView.builder(
                  itemCount: sostituzioni == null
                      ? 0
                      : sostituzioni.firstWhere((sostituzione) =>
                  sostituzione.profSostituto == settings["user"]).length * 2 +
                      1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index.isEven)
                      return new Divider(height: 8.0);
                    return new ExpansionTile(
                      title: new ListTile(
                        title: new Text(sostituzioni.firstWhere((
                            sostituzione) =>
                        sostituzione.profSostituto == settings["user"])
                            .sostituzione(index ~/ 2)
                            .ora),
                        subtitle: new Text(
                            sostituzioni.firstWhere((
                                sostituzione) =>
                            sostituzione.profSostituto == settings["user"])
                                .sostituzione(index ~/ 2)
                                .orario),
                      ),
                      children: <Widget>[
                        new Divider(height: 0.0),
                        new ListTile(
                          dense: true,
                          leading: new Icon(Icons.person),
                          title: new Text(sostituzioni.firstWhere((
                              sostituzione) =>
                          sostituzione.profSostituto == settings["user"])
                              .sostituzione(index ~/ 2)
                              .profAssente),
                        ),
                        new Divider(height: 0.0),
                        new ListTile(
                          dense: true,
                          leading: new Icon(Icons.room),
                          title: new Text(sostituzioni.firstWhere((
                              sostituzione) =>
                          sostituzione.profSostituto == settings["user"])
                              .sostituzione(index ~/ 2)
                              .classe),
                        ),
                        new Divider(height: 0.0),
                        sostituzioni.firstWhere((sostituzione) =>
                        sostituzione.profSostituto == settings["user"])
                            .sostituzione(index ~/ 2)
                            .note == "" ? new Column() :
                        new ListTile(
                          dense: true,
                          leading: new Icon(Icons.assignment),
                          title: new Text(sostituzioni.firstWhere((
                              sostituzione) =>
                          sostituzione.profSostituto == settings["user"])
                              .sostituzione(index ~/ 2)
                              .note),
                        ),
                        new Divider(height: 0.0),
                      ],
                    );
                  },
                ),
                onRefresh: () async {
                  await getData();
                },
              ),
              sostituzioni.firstWhere((sostituzione) =>
              sostituzione.profSostituto == settings["user"]).length == 0
                  ? new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Nessuna sostituzione trovata",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                      new Padding(padding: new EdgeInsets.only(top: 5.0)),
                      new Text("Non sono previste sostituzioni per te!",
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0)),
                    ],
                  )
              )
                  : new Center(),
            ],
          ),
        );
      }
      else { //Modalità docente - Docente non selezionato
        return new Scaffold(
            body: new Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text("Chi sei?", textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 30.0)),
                  new Padding(padding: new EdgeInsets.only(top: 20.0)),
                  new Text(
                      "Prima di poter utilizzare questa sezione,\ndevi selezionare il tuo nome dalla lista qui sotto!",
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 16.0)),
                  new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 12.5),
                    child: new DropdownButton(
                      value: dropdownValue,
                      iconSize: (docenti.length == 0 ||
                          docenti[0].value == "!error") ? 0.0 : 24.0,
                      hint: new Text(
                        dataError && docenti.length==0 ? "Problema di connessione" : docenti
                            .length ==
                            0
                            ? "Caricamento in corso..."
                            : "Scegli un docente...",
                        style: new TextStyle(
                          color: dataError && docenti.length==0 ? Colors.red : Colors.black,
                          fontWeight: dataError && docenti.length==0 ? FontWeight.bold : FontWeight
                              .normal,
                          fontSize: 16.0,
                        ),
                      ),
                      items: docenti.length == 0
                          ? [new DropdownMenuItem(value: 0, child: new Text(""))
                      ]
                          : docenti,
                      onChanged: (var chosen) {
                        setState(() => dropdownValue = chosen);
                      },
                    ),
                  ),
                  new Text(
                      "Potrai cambiare nuovamente questa opzione\nnelle impostazioni (in alto a destra).",
                      textAlign: TextAlign.center,
                      style: new TextStyle(fontSize: 13.0)),
                  new Padding(
                    padding: new EdgeInsets.symmetric(vertical: 20.0),
                    child: new IconButton(iconSize: 40.0,
                        onPressed: dataError && docenti.length==0 ? getData : docenti.length == 0
                            ? null
                            : dropdownValue == null ? null : userChosen,
                        icon: new Icon(
                            dataError && docenti.length==0 ? Icons.refresh : docenti.length == 0
                                ? Icons.watch_later
                                : Icons.done)
                    ),
                  ),
                ],
              ),
            )
        );
      }
    }
  }
}