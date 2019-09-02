import 'package:flutter/material.dart';
import 'package:itetsostituzioni/Globals.dart';
import 'package:itetsostituzioni/Tabs/SostituzioniDetailsTab.dart';
import 'package:itetsostituzioni/Utils/CustomExpansionTile.dart';
import 'package:itetsostituzioni/Utils/ReactiveRefreshIndicator.dart';
import 'package:itetsostituzioni/main.dart';

class SostituzioniTab extends StatelessWidget {

  final AppState app;

  const SostituzioniTab({Key key, @required this.app}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if(sostituzioni.length > 1 || (sostituzioni.length == 1 && sostituzioni[0].length > 0) || itp1 != "" || itp2 != "") {
      return Scaffold(
        body: ReactiveRefreshIndicator(
          child: ListView.builder(
            itemCount: (sostituzioni.length + (itp1 != "" || itp2 != "" ? 1 : 0)) * 2 + 1,
            itemBuilder: (BuildContext context, int i) {
              if (i.isEven || i == (sostituzioni.length + (itp1 != "" || itp2 != "" ? 1 : 0)) * 2) {
                return Divider(height: 12);
              }
              else if(i ~/ 2 < sostituzioni.length) {
                bool isSelectedUser = sostituzioni[i ~/ 2].user == settings["user"];
                return ListTile(
                  title: sostituzioni[i ~/ 2].user != "" ? Text(sostituzioni[i ~/ 2].user) : Text("Nessun sostituto", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                  subtitle: Text(sostituzioni[i ~/ 2].length.toString() + (sostituzioni[i ~/ 2].length == 1 ? " sostituzione" : " sostituzioni")),
                  trailing: isSelectedUser ? Icon(Icons.person) : null,
                  onTap: () {
                    if (isSelectedUser) {
                      app.tabController.animateTo(0);
                    }
                    else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SostituzioniDetailsTab(app: app, user: sostituzioni[i ~/ 2].user, personal: false)));
                    }
                  },
                );
              }
              else {
                List<Widget> children = List();

                if(itp1 != "") {
                  children.addAll([
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.perm_identity),
                      title: Text(itp1),
                      trailing: Text("ITP Assenti", style: TextStyle(fontSize: 10.0)),
                      dense: true,
                    )
                  ]);
                }
                if(itp2 != "") {
                  children.addAll([
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.perm_identity),
                      title: Text(itp2),
                      trailing: Text("Coperti da ITP", style: TextStyle(fontSize: 10.0)),
                      dense: true,
                    )
                  ]);
                }

                return CustomExpansionTile(
                  title: Text("ITP"),
                  children: children,
                  expandedColor: blue,
                );
              }
            },
          ),
          onRefresh: () => app.mainLoadSostituzioni(),
          isRefreshing: isRefreshing,
        ),
      );
    }

    //Nothing to show
    Widget child;
    if(downloadError && !noSostituzioni) {
      child = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text("Problema di connessione", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
            Divider(height: 5, color: Colors.transparent),
            Text("Impossibile scaricare le sostituzioni.", style: TextStyle(fontSize: 14))
          ]
      );
    }
    else {
      child = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text("Nessuna sostituzione trovata", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Divider(height: 5, color: Colors.transparent),
            Text("Non sono previste sostituzioni per questa giornata!", style: TextStyle(fontSize: 14))
          ]
      );
    }

    return Scaffold(
      body: ReactiveRefreshIndicator(
        child: Stack(
          children: <Widget>[
            ListView(),
            Center(
              child: child
            )
          ],
        ),
        onRefresh: () => app.mainLoadSostituzioni(),
        isRefreshing: isRefreshing,
      )
    );
  }
}