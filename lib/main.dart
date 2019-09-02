import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:itetsostituzioni/Globals.dart';
import 'package:itetsostituzioni/Tabs/ImpostazioniTab.dart';
import 'package:itetsostituzioni/Tabs/SostituzioniTab.dart';
import 'package:itetsostituzioni/Tabs/SostituzioniDetailsTab.dart';

void main() => runApp(MaterialApp(home: App()));

class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class AppState extends State<App> with SingleTickerProviderStateMixin {
  TabController tabController;

  void docenteChosen(bool docente) {
    settings["docente"] = docente;
    reloadSostituzioni();

    writeFile(settingsFileName, jsonEncode(settings));
    updateDatabaseInformation();
  }

  void reloadSostituzioni() {
    loadSostituzioni(false).then((_) {
      setState(() {});
    });
  }

  Future<bool> mainLoadSostituzioni() {
    setState(() { isRefreshing = true; });
    Future<bool> loading = loadSostituzioni(true);
    loading.then((error) {
      setState(() {
        isRefreshing = false;
        downloadError = error;
      });
      if(error && settings["docente"] != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Impossibile aggiornare i dati.\nVerifica la tua connessione ad Internet o riprova più tardi."),
            duration: Duration(milliseconds: 4000)
        ));
      }
    });
    return loading;
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.index = 1;

    loadData().then((_) {
      tabController.index = settings["user"] != null ? 0 : tabController.index;
      hasLoaded = true;
      mainLoadSostituzioni();
      updateDatabaseInformation();
    });

    messaging.configure( onMessage: (Map<String, dynamic> msg) async => mainLoadSostituzioni());
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
      appBar: AppBar(
        title: FittedBox(
          child: Text(sostituzioniDate),
          fit: BoxFit.scaleDown,
        ),
        backgroundColor: blue,
        actions: <Widget>[
          IconButton(
            tooltip: "Impostazioni",
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ImpostazioniTab())),
          )
        ],
        bottom: TabBar(
          controller: tabController,
          indicatorColor: Colors.white,
          tabs: <Widget>[
            Tab(text: settings["docente"] == false ? "LA MIA CLASSE" : "LE MIE SOSTITUZIONI"),
            Tab(text: settings["docente"] == false ? "TUTTE LE CLASSI" : "TUTTE LE SOSTITUZIONI"),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          TabBarView(
            controller: tabController,
            children: <Widget>[
              SostituzioniDetailsTab(app: this, personal: true),
              SostituzioniTab(app: this),
            ],
          ),
          IgnorePointer(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              key: scaffoldKey,
            ),
          )
        ]
      ),
      bottomNavigationBar: sostituzioniTimestamp != "" ? Material(
        color: blue,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.5),
          child: RichText(
            text: TextSpan(children: <TextSpan>[
              TextSpan(text: downloadError ? "Le sostituzioni potrebbero non essere aggiornate\n" : "", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              TextSpan(text: sostituzioniTimestamp, style: TextStyle(color: Colors.white)),
            ]),
            textAlign: TextAlign.center,
          ),
        ),
      ) : null,
    );

    if(settings["docente"] == null) {
      child = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Benvenuto nell'app!",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              Divider(height: 20, color: Colors.transparent),
              Text(
                  "Prima di iniziare, scegli se vuoi utilizzare l'app\ncome studente o come docente.",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              Divider(height: 15, color: Colors.transparent),
              Text(
                  "Potrai cambiare nuovamente questa opzione\nnelle impostazioni (in alto a destra).",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
              Divider(height: 60, color: Colors.transparent),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    RaisedButton(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      child: Text("Sono un docente"),
                      onPressed: () => docenteChosen(true),
                    ),
                    Divider(height: 15, color: Colors.transparent),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      child: Text("Sono uno studente"),
                      onPressed: () => docenteChosen(false),
                    ),
                  ],
                ),
              ),
            ],
          )
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          child,
          AnimatedOpacity(
            opacity: hasLoaded ? 0 : 1,
            duration: Duration(milliseconds: 500),
            child: IgnorePointer(
              ignoring: hasLoaded,
              child: Stack(
                children: <Widget>[
                  Column(children: <Widget>[Expanded(child: Container(color: Colors.white))]),
                  Center(child: Image.asset("images/logo.png", width: 250, fit: BoxFit.scaleDown))
                ],
              ),
            )
          )
        ],
      ),
    );
  }
}
