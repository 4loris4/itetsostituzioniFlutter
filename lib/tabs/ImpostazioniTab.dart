import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itetsostituzioni/Globals.dart';

class ImpostazioniTab extends StatefulWidget {

  @override
  ImpostazioniTabState createState() => ImpostazioniTabState();
}

class ImpostazioniTabState extends State<ImpostazioniTab> {

  void settingsChosen(bool docente, String user) {
    setState(() {
      settings["docente"] = docente;
      settings["user"] = user;
      loadSostituzioni(false);
    });

    writeFile(settingsFileName, jsonEncode(settings));
    updateDatabaseInformation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Impostazioni"),
        backgroundColor: blue,
        leading: IconButton(icon: Icon(Icons.arrow_back), tooltip: "Indietro", onPressed: () => Navigator.of(context).pop()),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("Ruolo", style: TextStyle(fontSize: 17.5)),
                  flex: 2,
                ),
                Expanded(
                  child: DropdownButton(
                    hint: Text("Scegli un ruolo..."),
                    isExpanded: true,
                    items: <String>["Docente", "Studente"].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: FittedBox(child: Text(value), fit: BoxFit.scaleDown),
                      );
                    }).toList(),
                    value: settings["docente"] == false ? "Studente" : "Docente",
                    onChanged: (docente) => settingsChosen(docente == "Docente", null),
                  ),
                  flex: 3,
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, top: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(settings["docente"] == false ? "Classe" : "Docente", style: TextStyle(fontSize: 17.5)),
                  flex: 2,
                ),
                Expanded(
                  child: DropdownButton(
                    hint: FittedBox(
                      child: (settings["docente"] == false ? classi : docenti).length == 0 && downloadError ?
                        Text("Impossibile scaricare la lista de${settings["docente"] == false ? "lle classi" : "i docenti"}.", style: TextStyle(color: Colors.red)) :
                        Text("Scegli un${settings["docente"] == false ? "a classe" : " docente"}..."),
                      fit: BoxFit.scaleDown,
                    ),
                    isExpanded: true,
                    items: (settings["docente"] == false ? classi : docenti).map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: FittedBox(child: Text(value), fit: BoxFit.scaleDown),
                      );
                    }).toList(),
                    value: settings["user"],
                    onChanged: (user) => settingsChosen(settings["docente"], user),
                  ),
                  flex: 3,
                )
              ],
            ),
          ),
        ],
      )
    );
  }
}