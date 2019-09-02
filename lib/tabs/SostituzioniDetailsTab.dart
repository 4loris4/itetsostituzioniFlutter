import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:itetsostituzioni/Globals.dart';
import 'package:itetsostituzioni/Utils/CustomExpansionTile.dart';
import 'package:itetsostituzioni/Utils/ReactiveRefreshIndicator.dart';
import 'package:itetsostituzioni/Utils/Sostituzione.dart';
import 'package:itetsostituzioni/Utils/SostituzioniUser.dart';
import 'package:itetsostituzioni/main.dart';

class SostituzioniDetailsTab extends StatelessWidget {

  final AppState app;
  final bool personal;
  final String user;

  const SostituzioniDetailsTab({Key key, @required this.app, @required this.personal, this.user}) : super(key: key);

  CustomExpansionTile sostituzioneTile(Sostituzione sostituzione) {
    List<Widget> children = List();

    if(settings["docente"] == false) {
      children = [
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.perm_identity),
          title: Text(sostituzione.docenteAssente),
          trailing: Text("Assente", style: TextStyle(fontSize: 10.0)),
          dense: true,
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.person),
          title: sostituzione.docenteSostituto != "" ? Text(sostituzione.docenteSostituto) : Text("Nessun sostituto", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
          trailing: Text("Sostituto", style: TextStyle(fontSize: 10.0)),
          dense: true,
        ),
      ];
    }
    else {
      children = [
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.person),
          title: Text(sostituzione.docenteAssente),
          trailing: Text("Assente", style: TextStyle(fontSize: 10.0)),
          dense: true,
        ),
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.room),
          title: Text(sostituzione.classe),
          trailing: Text("Classe", style: TextStyle(fontSize: 10.0)),
          dense: true,
        ),
      ];
    }

    if(sostituzione.note != "") {
      children.addAll([
        Divider(height: 1),
        ListTile(
          leading: Icon(Icons.assignment),
          title: Text(sostituzione.note),
          trailing: Text("Note", style: TextStyle(fontSize: 10.0)),
          dense: true,
        )
      ]);
    }

    return CustomExpansionTile(
      title: Text(sostituzione.ora),
      subtitle: Text(sostituzione.orario),
      children: children,
      expandedColor: blue,
    );
  }

  void userChosen(String user) {
    settings["user"] = user;
    app.reloadSostituzioni();

    writeFile(settingsFileName, jsonEncode(settings));
    updateDatabaseInformation();
  }

  @override
  Widget build(BuildContext context) {
    String user = (this.user != null ? this.user : settings["user"]);

    //User not selected yet
    if(user == null) {
      return Scaffold(
        body: ReactiveRefreshIndicator(
          child: Stack(
            children: <Widget>[
              ListView(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(settings["docente"] == false ? "Quale classe frequenti?" : "Chi sei?", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    Divider(height: 20, color: Colors.transparent),
                    Text(
                      "Prima di poter utilizzare questa sezione,\ndevi selezionare ${settings["docente"] == false ? "la tua classe" : "il tuo nome"} dalla lista qui sotto!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(height: 12.5, color: Colors.transparent),
                    DropdownButton(
                      items: (settings["docente"] == false ? classi : docenti).map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      hint: (settings["docente"] == false ? classi : docenti).length == 0 && downloadError ?
                        Text("Impossibile scaricare la lista de${settings["docente"] == false ? "lle classi" : "i docenti"}.", style: TextStyle(color: Colors.red)) :
                        Text("Scegli un${settings["docente"] == false ? "a classe" : " docente"}..."),
                      onChanged: (user) => userChosen(user),
                    ),
                    Divider(height: 12.5, color: Colors.transparent),
                    Text("Potrai cambiare nuovamente questa opzione\nnelle impostazioni (in alto a destra).", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          onRefresh: () => app.mainLoadSostituzioni(),
          isRefreshing: isRefreshing,
        ),
      );
    }


    SostituzioniUser sostituzioniUser = (sostituzioni.indexWhere((a) => a.user == user) != -1 ? sostituzioni.firstWhere((a) => a.user == user) : null);

    String title = user != "" ? "Sostituzioni ${settings["docente"] == false ? "della classe" : "di"} $user" : "Sostituzioni non assegnate";
    AppBar appBar = AppBar(
      centerTitle: personal,
      title: FittedBox(
        child: Text(title),
        fit: BoxFit.scaleDown,
      ),
      backgroundColor: blue,
      leading: !personal ? IconButton(icon: Icon(Icons.arrow_back), tooltip: "Indietro", onPressed: () => Navigator.of(context).pop()) : null,
    );


    //Something to show
    if(sostituzioniUser != null && sostituzioniUser.length > 0) {
      ListView listView = ListView.builder(
        itemCount: sostituzioniUser.length * 2 + 1,
        itemBuilder: (BuildContext context, int i) {
          if(i.isEven || i == sostituzioniUser.length * 2) {
            return Divider(height: 12);
          }
          return sostituzioneTile(sostituzioniUser[i ~/ 2]);
        },
      );
      return Scaffold(
        appBar: appBar,
        body: !personal ? listView : ReactiveRefreshIndicator(
          child: listView,
          onRefresh: () => app.mainLoadSostituzioni(),
          isRefreshing: isRefreshing,
        )
      );
    }


    //Nothing to show
    Widget child = Stack(
      children: <Widget>[
        ListView(),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Text("Nessuna sostituzione trovata", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Divider(height: 5, color: Colors.transparent),
              Text("Non sono previste sostituzioni per ${settings["docente"] == false ? "la tua classe" : "te"}!", style: TextStyle(fontSize: 14))
            ]
          ),
        )
      ],
    );
    return Scaffold(
      appBar: appBar,
      body: !personal ? child : ReactiveRefreshIndicator(
        child: child,
        onRefresh: () => app.mainLoadSostituzioni(),
        isRefreshing: isRefreshing,
      )
    );
  }
}