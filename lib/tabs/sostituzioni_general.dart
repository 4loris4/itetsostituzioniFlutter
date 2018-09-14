import 'package:flutter/material.dart';
import '../globals.dart';
import '../main.dart';
import './sostituzione_details.dart';

class SostituzioniGeneral extends StatefulWidget{
  @override
  SostituzioniGeneralState createState() => new SostituzioniGeneralState();
}

class SostituzioniGeneralState extends State<SostituzioniGeneral>{

  @override
  Widget build(BuildContext context) {
    if(settings["role"]=="Studente") { //Modalità studente
      return new Scaffold(
          body: new Stack(
            children: <Widget>[
              new RefreshIndicator(
                  child: new ListView.builder(
                    itemCount: (sostituzioniClassi == null || noSostituzioni || dataError) ? 0
                        : sostituzioniClassi.length * 2 + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index.isEven)
                        return new Divider(height: 8.0);
                      return new ListTile(
                        trailing: sostituzioniClassi[index ~/ 2].classe ==
                            settings["user"] ? new Icon(Icons.person) : null,
                        title: new Text(sostituzioniClassi[index ~/ 2].classe),
                        subtitle: new Text(
                            sostituzioniClassi[index ~/ 2].length == 1 ? "(" +
                                sostituzioniClassi[index ~/ 2].length.toString() +
                                " sostituzione)" : "(" +
                                sostituzioniClassi[index ~/ 2].length.toString() +
                                " sostituzioni)"),
                        onTap: () {
                          if (sostituzioniClassi[index ~/ 2].classe ==
                              settings["user"])
                            controller.animateTo(0);
                          else
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new SostituzioneDetails(index ~/ 2)));
                        },
                      );
                    },
                  ),
                  onRefresh: () async {
                    await getData();
                  }
              ),
              noSostituzioni ? new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Nessuna sostituzione trovata",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                      new Padding(padding: new EdgeInsets.only(top: 5.0)),
                      new Text("Non sono previste sostituzioni!",
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0)),
                    ],
                  )
              ) : new Center(),
              dataError ? new Center(
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
              ) : new Center(),
            ],
          )
      );
    }
    else { //Modalità docente
      return new Scaffold(
          body: new Stack(
            children: <Widget>[
              new RefreshIndicator(
                  child: new ListView.builder(
                    itemCount: (sostituzioni == null || noSostituzioni || dataError)
                        ? 0
                        : sostituzioni.length * 2 + 1,
                    itemBuilder: (BuildContext context, int index) {
                      if (index.isEven)
                        return new Divider(height: 8.0,);
                      return new ListTile(
                        trailing: sostituzioni[index ~/ 2].profSostituto ==
                            settings["user"] ? new Icon(Icons.person) : null,
                        title: new Text(sostituzioni[index ~/ 2].profSostituto),
                        subtitle: new Text(
                            sostituzioni[index ~/ 2].length == 1 ? "(" +
                                sostituzioni[index ~/ 2].length.toString() +
                                " sostituzione)" : "(" +
                                sostituzioni[index ~/ 2].length.toString() +
                                " sostituzioni)"),
                        onTap: () {
                          if (sostituzioni[index ~/ 2].profSostituto ==
                              settings["user"])
                            controller.animateTo(0);
                          else
                            Navigator.of(context).push(new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new SostituzioneDetails(index ~/ 2)));
                        },
                      );
                    },
                  ),
                  onRefresh: () async {
                    await getData();
                  }
              ),
              noSostituzioni ? new Center(
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text("Nessuna sostituzione trovata",
                          textAlign: TextAlign.center,
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20.0)),
                      new Padding(padding: new EdgeInsets.only(top: 5.0)),
                      new Text("Non sono previste sostituzioni!",
                          textAlign: TextAlign.center,
                          style: new TextStyle(fontSize: 14.0)),
                    ],
                  )
              ) : new Center(),
              dataError ? new Center(
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
              ) : new Center(),
            ],
          )
      );
    }
  }
}