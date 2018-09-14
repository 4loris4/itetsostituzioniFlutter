import 'package:flutter/material.dart';
import '../globals.dart';

class SostituzioneDetails extends StatefulWidget{

  final int index;

  SostituzioneDetails(this.index);

  @override
  StateSostituzioneDetails createState() => new StateSostituzioneDetails();
}

class StateSostituzioneDetails extends State<SostituzioneDetails> {

  String dropdownValue;

  @override
  Widget build(BuildContext context) {
    if(settings["role"]=="Studente") { //Modalità studente
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blueGrey,
          title: new Text(
              "Sostituzioni della classe " + sostituzioniClassi[widget.index].classe),
        ),
        body: new Stack(
          children: <Widget>[
            new ListView.builder(
              itemCount: sostituzioniClassi[widget.index].length * 2 + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i.isEven)
                  return new Divider(height: 8.0);
                return new ExpansionTile(
                  title: new ListTile(
                    title: new Text(sostituzioniClassi[widget.index]
                        .sostituzione(i ~/ 2)
                        .ora),
                    subtitle: new Text(sostituzioniClassi[widget.index]
                        .sostituzione(i ~/ 2)
                        .orario),
                  ),
                  children: <Widget>[
                    new Divider(height: 0.0),
                    new ListTile(
                      dense: true,
                      leading: new Icon(Icons.perm_identity),
                      title: new Text(sostituzioniClassi[widget.index]
                          .sostituzione(i ~/ 2)
                          .profAssente),
                      trailing: new Text("Assente", style: new TextStyle(fontSize: 10.0)),
                    ),
                    new Divider(height: 0.0),
                    new ListTile(
                      dense: true,
                      leading: new Icon(Icons.person),
                      title: new Text(sostituzioniClassi[widget.index]
                          .sostituzione(i ~/ 2)
                          .profSostituto),
                      trailing: new Text("Sostituto", style: new TextStyle(fontSize: 10.0)),
                    ),
                    new Divider(height: 0.0),
                    sostituzioniClassi[widget.index]
                        .sostituzione(i ~/ 2)
                        .note == "" ? new Column() :
                    new ListTile(
                      dense: true,
                      leading: new Icon(Icons.assignment),
                      title: new Text(sostituzioniClassi[widget.index]
                          .sostituzione(i ~/ 2)
                          .note),
                    ),
                    new Divider(height: 0.0),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }
    else{ //Modalità docente
      return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.blueGrey,
          title: new Text(
              "Sostituzioni di " + sostituzioni[widget.index].profSostituto),
        ),
        body: new Stack(
          children: <Widget>[
            new ListView.builder(
              itemCount: sostituzioni[widget.index].length * 2 + 1,
              itemBuilder: (BuildContext context, int i) {
                if (i.isEven)
                  return new Divider(height: 8.0);
                return new ExpansionTile(
                  title: new ListTile(
                    title: new Text(sostituzioni[widget.index]
                        .sostituzione(i ~/ 2)
                        .ora),
                    subtitle: new Text(sostituzioni[widget.index]
                        .sostituzione(i ~/ 2)
                        .orario),
                  ),
                  children: <Widget>[
                    new Divider(height: 0.0),
                    new ListTile(
                      dense: true,
                      leading: new Icon(Icons.person),
                      title: new Text(sostituzioni[widget.index]
                          .sostituzione(i ~/ 2)
                          .profAssente),
                    ),
                    new Divider(height: 0.0),
                    new ListTile(
                      dense: true,
                      leading: new Icon(Icons.room),
                      title: new Text(sostituzioni[widget.index]
                          .sostituzione(i ~/ 2)
                          .classe),
                    ),
                    new Divider(height: 0.0),
                    sostituzioni[widget.index]
                        .sostituzione(i ~/ 2)
                        .note == "" ? new Column() :
                    new ListTile(
                      dense: true,
                      leading: new Icon(Icons.assignment),
                      title: new Text(sostituzioni[widget.index]
                          .sostituzione(i ~/ 2)
                          .note),
                    ),
                    new Divider(height: 0.0),
                  ],
                );
              },
            ),
          ],
        ),
      );
    }
  }
}