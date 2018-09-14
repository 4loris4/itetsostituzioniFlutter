import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import './tabs/sostituzioni_general.dart';
import './tabs/sostituzioni_personal.dart';
import './tabs/settings.dart';
import 'globals.dart';

void main() => runApp(new MaterialApp(home: new MyTabs()));

MyTabsState appState = new MyTabsState();

class MyTabs extends StatefulWidget{
  @override
  MyTabsState createState() => appState;
}

TabController controller;

class MyTabsState extends State<MyTabs> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 2, vsync: this);
    controller.index=1;
    controller.addListener((){
      if(controller.index==0)
        personalVisited = true;
    });

    loadData().then((onValue){
      getData();
      if(docenteExists(settings["user"]))
        Future.delayed(new Duration(milliseconds: 250)).then((onValue){
          controller.animateTo(0);
        });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(settings["role"]==null){
      return new Scaffold(
          body: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("Benvenuto nell'app!", textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 30.0)),
                new Padding(padding: new EdgeInsets.only(top: 20.0)),
                new Text(
                    "Prima di iniziare, scegli se vuoi utilizzare l'app\ncome studente o come docente.",
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 16.0)
                ),
                new Padding(
                  padding: new EdgeInsets.symmetric(vertical: 7.5),
                ),
                new Text(
                    "Potrai cambiare nuovamente questa\nopzione nelle impostazioni.",
                    textAlign: TextAlign.center,
                    style: new TextStyle(fontSize: 13.0)),
                new Padding(
                  padding: new EdgeInsets.symmetric(vertical: 30.0),
                ),
                new RaisedButton(
                  child: new Text("Sono uno studente", style: new TextStyle(fontSize: 16.0)),
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  onPressed: (){
                    setState(() {
                      settings["role"]="Studente";
                      saveToFile(settingsFile, json.encode(settings));
                    });
                  }
                ),
                new Padding(
                  padding: new EdgeInsets.symmetric(vertical: 7.5),
                ),
                new RaisedButton(
                  child: new Text("Sono un docente", style: new TextStyle(fontSize: 16.0)),
                  padding: EdgeInsets.symmetric(horizontal: 37.0, vertical: 15.0),
                  onPressed: (){
                    setState(() {
                      settings["role"]="Docente";
                      saveToFile(settingsFile, json.encode(settings));
                    });
                  }
                )
              ],
            ),
          )
      );
    }
    else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(day, style: new TextStyle(fontSize: 18.0)),
          backgroundColor: Colors.blueGrey,
          bottom: new TabBar(
            indicatorColor: Colors.lightBlueAccent,
            controller: controller,
            tabs: <Tab>[
              new Tab(text: settings["role"] == "Studente"
                  ? "LA MIA CLASSE"
                  : "LE MIE SOSTITUZIONI"),
              new Tab(text: settings["role"] == "Studente"
                  ? "TUTTE LE CLASSI"
                  : "TUTTE LE SOSTITUZIONI"),
            ],
          ),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.settings),
              onPressed: () =>
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new Settings())),
            )
          ],
        ),
        body: new TabBarView(
            controller: controller,
            children: <Widget>[
              new SostituzioniPersonal(),
              new SostituzioniGeneral(),
            ]
        ),
        bottomNavigationBar: new Builder(builder: (BuildContext context2) {
          snackbarContext = context2;
          return new Material(
            child: new Padding(
              padding: EdgeInsets.symmetric(vertical: 2.5),
              child: new RichText(
                textAlign: TextAlign.center,
                  text: new TextSpan(
                    children: [
                      new TextSpan(text: updateDay),
                      downloadError ? new TextSpan(text: "\nLe sostituzioni potrebbero non essere aggiornate", style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.red)) : new TextSpan(),
                    ]
                  ),
              ),
            ),
            color: Colors.blueGrey,
          );
        }),
      );
    }
  }
}